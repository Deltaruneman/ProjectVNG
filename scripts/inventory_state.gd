extends RefCounted
## Serializable inventory, kept by GameManager across stage changes.
const CATALOG := preload("res://scripts/item_catalog.gd")
var items: Dictionary = {}
var equipped: Dictionary = {"main": "", "offhand": "", "consumable": "", "armor": "", "charm": ""}
var next_id := 1
var resonance_upgrades: Dictionary = {}
var enchant_spent := 0
var offers: Array[Dictionary] = []
var offer_weapon := ""
var offer_epoch := 0

func _init() -> void:
	equip(grant("starter_blade"))

func grant(definition: String, count: int = 1) -> String:
	definition = CATALOG.canonical_id(definition)
	var data := CATALOG.item(definition)
	if data.is_empty() or count <= 0:
		return ""
	if data.slot == "consumable":
		for uid: String in items:
			if items[uid].definition == definition:
				items[uid].count += count
				return uid
	var uid := "item_%d" % next_id
	next_id += 1
	items[uid] = {"definition": definition, "count": count if data.slot == "consumable" else 1, "enchants": {}, "inactive_enchants": {}}
	return uid

func equip(uid: String) -> bool:
	if not items.has(uid):
		return false
	var slot := str(CATALOG.item(items[uid].definition).get("slot", ""))
	if slot == "offhand" or not equipped.has(slot):
		return false
	equipped[slot] = uid
	return true

func definition_for_slot(slot: String) -> Dictionary:
	var uid := str(equipped.get(slot, ""))
	return CATALOG.item(items[uid].definition) if items.has(uid) else {}

func id_for_slot(slot: String) -> String:
	var uid := str(equipped.get(slot, ""))
	return str(items[uid].definition) if items.has(uid) else ""

func enchant_rank(slot: String, enchant: String) -> int:
	# Legacy offhands remain serialized but never contribute stats.
	if slot == "offhand":
		return 0
	var uid := str(equipped.get(slot, ""))
	return int(items[uid].enchants.get(enchant, 0)) if items.has(uid) else 0

func serialize() -> Dictionary:
	return {"items": items.duplicate(true), "equipped": equipped.duplicate(), "next_id": next_id,
		"resonance_upgrades": resonance_upgrades.duplicate(), "enchant_spent": enchant_spent,
		"offers": offers.duplicate(true), "offer_weapon": offer_weapon, "offer_epoch": offer_epoch}

func restore(payload: Variant) -> void:
	items.clear()
	equipped = {"main": "", "offhand": "", "consumable": "", "armor": "", "charm": ""}
	next_id = 1
	resonance_upgrades.clear()
	enchant_spent = 0
	offers.clear()
	offer_weapon = ""
	if not payload is Dictionary or not payload.has("items"):
		equip(grant("starter_blade"))
		return
	var saved: Variant = payload.get("items", {})
	if saved is Dictionary:
		for raw_uid: Variant in saved:
			var uid := str(raw_uid)
			var entry: Variant = saved[raw_uid]
			if not entry is Dictionary or CATALOG.item(str(entry.get("definition", ""))).is_empty():
				continue
			var definition := CATALOG.canonical_id(str(entry.definition))
			var count := maxi(0, int(entry.get("count", 1)))
			if count == 0:
				continue
			items[uid] = {"definition": definition, "count": count if CATALOG.item(definition).slot == "consumable" else 1, "enchants": {}, "inactive_enchants": {}}
			for source: String in ["enchants", "inactive_enchants"]:
				var saved_ranks: Variant = entry.get(source, {})
				if not saved_ranks is Dictionary:
					continue
				for enchant: String in CATALOG.ENCHANTS:
					var rank := maxi(0, int(saved_ranks.get(enchant, 0)))
					if not CATALOG.item(definition).get("unlimited_enchants", false):
						rank = mini(rank, int(CATALOG.ENCHANTS[enchant].max))
					if rank <= 0:
						continue
					var destination := "inactive_enchants" if CATALOG.ENCHANTS[enchant].get("elemental", false) and str(CATALOG.item(definition).get("resonance", "")) == "" else "enchants"
					if destination == "enchants" and not CATALOG.item(definition).get("unlimited_enchants", false) and not items[uid].enchants.has(enchant) and items[uid].enchants.size() >= 3:
						destination = "inactive_enchants"
					items[uid][destination][enchant] = maxi(rank, int(items[uid][destination].get(enchant, 0)))
			if uid.begins_with("item_"):
				next_id = maxi(next_id, int(uid.trim_prefix("item_")) + 1)
	var starter_uid := ""
	for uid: String in items:
		if items[uid].definition == "starter_blade":
			starter_uid = uid
			break
	if starter_uid == "":
		starter_uid = grant("starter_blade")
	if payload.get("equipped") is Dictionary:
		for slot: String in equipped:
			var uid := str(payload.equipped.get(slot, ""))
			if items.has(uid) and CATALOG.item(items[uid].definition).slot == slot:
				equipped[slot] = uid
	if equipped.main == "" and starter_uid != "":
		equipped.main = starter_uid
	if payload.get("resonance_upgrades") is Dictionary:
		for element: String in CATALOG.ELEMENTS:
			if payload.resonance_upgrades.get(element, false) == true:
				resonance_upgrades[element] = true
	enchant_spent = maxi(0, int(payload.get("enchant_spent", 0)))

	offer_epoch = maxi(0, int(payload.get("offer_epoch", 0)))
	var saved_offers: Variant = payload.get("offers", [])
	offer_weapon = str(payload.get("offer_weapon", ""))
	if saved_offers is Array and not saved_offers.is_empty() and saved_offers.size() <= 3 and items.has(offer_weapon):
		var used: Dictionary = {}
		for offer: Variant in saved_offers:
			if not offer is Dictionary or not eligible_enchants(offer_weapon).has(str(offer.get("id", ""))) or used.has(str(offer.get("id", ""))):
				offers.clear()
				break
			var id := str(offer.id)
			var rank := int(items[offer_weapon].enchants.get(id, 0)) + 1
			if int(offer.get("rank", 0)) != rank or int(offer.get("cost", 0)) != rank:
				offers.clear()
				break
			used[id] = true
			offers.append({"id": id, "rank": rank, "cost": rank})
	if not saved_offers is Array or offers.size() != saved_offers.size() or offers.is_empty():
		offers.clear()
		offer_weapon = ""

func eligible_enchants(uid: String) -> Array[String]:
	var pool: Array[String] = []
	if not items.has(uid):
		return pool
	var data := CATALOG.item(items[uid].definition)
	if str(data.get("slot", "")) != "main":
		return pool
	for id: String in CATALOG.ENCHANTS:
		var enchant: Dictionary = CATALOG.ENCHANTS[id]
		var unlimited := bool(data.get("unlimited_enchants", false))
		if not unlimited:
			if not items[uid].enchants.has(id) and items[uid].enchants.size() >= 3:
				continue
			if int(items[uid].enchants.get(id, 0)) >= int(enchant.max):
				continue
		if enchant.get("elemental", false) and str(data.get("resonance", "")) == "":
			continue
		pool.append(id)
	return pool

func roll_enchants(uid: String) -> Array[Dictionary]:
	if uid == offer_weapon and not offers.is_empty():
		var eligible := eligible_enchants(uid)
		var valid := true
		for offer: Dictionary in offers:
			if not eligible.has(str(offer.id)) or int(items[uid].enchants.get(offer.id, 0)) + 1 != int(offer.rank):
				valid = false
		if valid:
			return offers.duplicate(true)
		offers.clear()
		offer_weapon = ""
	var pool := eligible_enchants(uid)
	if pool.is_empty():
		return []
	pool.shuffle()
	offer_epoch += 1
	offers.clear()
	offer_weapon = uid
	for index in mini(3, pool.size()):
		var id := pool[index]
		var rank := int(items[uid].enchants.get(id, 0)) + 1
		offers.append({"id": id, "rank": rank, "cost": rank})
	return offers.duplicate(true)

func apply_enchant(uid: String, index: int, available_sp: int, epoch: int) -> int:
	if epoch != offer_epoch:
		return 0
	if uid != offer_weapon or offers.is_empty() or index < 0 or index >= offers.size():
		return 0
	var offer := offers[index]
	if not eligible_enchants(uid).has(str(offer.id)) or available_sp < int(offer.cost):
		return 0
	if int(items[uid].enchants.get(offer.id, 0)) + 1 != int(offer.rank):
		return 0
	items[uid].enchants[offer.id] = int(offer.rank)
	var cost := int(offer.cost)
	enchant_spent += cost
	offers.clear()
	offer_weapon = ""
	return cost
