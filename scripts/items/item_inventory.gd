extends RefCounted
signal changed
const Catalog := preload("res://scripts/items/item_catalog.gd")
const SLOTS := {"weapon": "Vũ khí", "armor": "Giáp", "talisman": "Bùa"}
const MAX_STACK := 99
const LEGACY_IDS := {
	"training_blade": "iron_sword", "duelist_blade": "parry_dagger",
	"traveler_armor": "leather_tunic", "swift_charm": "traveler_boots",
	"healing_draught": "minor_health_potion", "ember_draught": "ember_tonic",
	"swift_draught": "swift_tonic",
}
var counts: Dictionary = {}
var equipped: Dictionary = {}
var quick_item := ""

func reset_with_samples() -> void:
	counts = Catalog.SAMPLES.duplicate()
	equipped.clear()
	quick_item = "minor_health_potion"
	changed.emit()

func grant(id: String, amount: int = 1) -> bool:
	if not Catalog.ITEMS.has(id) or amount <= 0:
		return false
	var limit := 1 if Catalog.ITEMS[id].kind == "equipment" else MAX_STACK
	var total := mini(int(counts.get(id, 0)) + mini(amount, MAX_STACK), limit)
	if total == int(counts.get(id, 0)):
		return false
	counts[id] = total
	changed.emit()
	return true

func equip(id: String) -> bool:
	var data := Catalog.item(id)
	if int(counts.get(id, 0)) <= 0 or data.get("kind") != "equipment":
		return false
	if equipped.get(data.slot, "") == id:
		return false
	equipped[data.slot] = id
	changed.emit()
	return true

func unequip(slot: String) -> bool:
	if not equipped.has(slot):
		return false
	equipped.erase(slot)
	changed.emit()
	return true

func select_quick(id: String) -> bool:
	if int(counts.get(id, 0)) <= 0 or Catalog.item(id).get("kind") != "consumable":
		return false
	quick_item = id
	changed.emit()
	return true

func use_quick(player: Node) -> bool:
	if not is_instance_valid(player) or int(counts.get(quick_item, 0)) <= 0:
		return false
	if not player.has_method("apply_inventory_consumable") or not player.apply_inventory_consumable(quick_item, Catalog.item(quick_item)):
		return false
	counts[quick_item] = int(counts[quick_item]) - 1
	# Keep the selected empty stack visible so it cannot silently switch to another consumable.
	changed.emit()
	return true

func bonuses() -> Dictionary:
	var result := {"attack": 0, "health": 0, "speed": 0.0, "parry": 0.0}
	for id: String in equipped.values():
		for effect: String in Catalog.ITEMS[id].effects:
			result[effect] += Catalog.ITEMS[id].effects[effect]
	return result

func serialize() -> Dictionary:
	return {"version": 2, "counts": counts.duplicate(), "equipped": equipped.duplicate(), "quick_item": quick_item}

func restore(value: Variant) -> void:
	counts.clear()
	equipped.clear()
	quick_item = ""
	if value is Dictionary and int(value.get("version", 0)) in [1, 2]:
		var saved_counts: Variant = value.get("counts", {})
		if saved_counts is Dictionary:
			for raw_id: String in saved_counts:
				var id := str(LEGACY_IDS.get(raw_id, raw_id))
				if not Catalog.ITEMS.has(id):
					continue
				var amount: Variant = saved_counts[raw_id]
				if (amount is int or amount is float) and is_finite(float(amount)):
					var cap := 1 if Catalog.ITEMS[id].kind == "equipment" else MAX_STACK
					counts[id] = mini(cap, int(counts.get(id, 0)) + int(clampf(float(amount), 0.0, float(cap))))
		var saved_equipped: Variant = value.get("equipped", {})
		if saved_equipped is Dictionary:
			for slot: String in SLOTS:
				var id := str(saved_equipped.get(slot, ""))
				id = str(LEGACY_IDS.get(id, id))
				if int(counts.get(id, 0)) > 0 and Catalog.item(id).get("slot") == slot:
					equipped[slot] = id
		var selected := str(value.get("quick_item", ""))
		selected = str(LEGACY_IDS.get(selected, selected))
		if Catalog.item(selected).get("kind") == "consumable":
			quick_item = selected
	changed.emit()
