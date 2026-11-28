extends Node

## Everything that has to outlive a stage change: where the fox appears in the next stage, the last
## checkpoint, world flags (an unlocked door), and the fox's health while it walks through a door.
##
## There is ONE way to switch stages — change_stage(stage, spawn) — used by doors, by respawning
## after death and by continuing a saved game. The new stage calls register_stage() from its
## _ready(), and that is the only place that decides where the fox appears.

## Emitted once a stage has loaded and the fox is in place.
signal stage_changed(stage: Stage)

## The game's main scene. A new game starts here, and so does a fox that dies before touching any
## checkpoint.
const MAIN_MENU := "res://ui/main_menu.tscn"
const SCENE_LOADING := preload("res://ui/scene_loading.gd")
signal scene_change_failed
var _scene_loading: CanvasLayer

const FIRST_STAGE := "res://levels/level_1/basement_full.tscn"
const BASEMENT_UID := "uid://mjb8sv4t2f20"
const BASEMENT_CHECKPOINTS := {
	"b1_start": {"floor": "b1", "rank": 1},
	"b2_start": {"floor": "b2", "rank": 2},
	"b3_start": {"floor": "b3", "rank": 3},
}
const LEGACY_BASEMENT_CHECKPOINTS := {
	"res://levels/level_1/basement_b1.tscn": "b1_start",
	"uid://ut8i8xxf74gj": "b1_start",
	"res://levels/level_1/basement_b2.tscn": "b2_start",
	"uid://b7bnu12tjc0e8": "b2_start",
}
const B3_STAGE := "res://levels/level_1/basement_b3.tscn"
const B3_REFERENCES := [B3_STAGE, "uid://d12u1s460ag67"]
const B3_CHECKPOINT_CONTRACT := "explicit_b3_v1"

var current_stage: Stage = null
## Where the next stage puts the fox: a door id or a checkpoint id. "" = the stage's default spot
## (wherever the Player node sits in the scene).
var pending_spawn := ""
## The last checkpoint the fox touched. Both "" = none yet.
var checkpoint_stage := ""
var checkpoint_id := ""
## World flags that survive stage changes and go into the save file, e.g. {"gate": true}.
var flags: Dictionary = {}
## The fox's health carried through a door; -1 = start with full health.
var player_health := -1.0
var _pending_brimstone_respawn := false
## Skill points live in one pool. Allocations are stored by node id so a free reset can return
## every spent point without changing the number earned from the world.
const PROGRESSION := preload("res://scripts/skill_progression.gd")
signal level_gained(level: int)
signal skill_progress_changed
var player_level := 1
var experience := 0
var skill_spending: Dictionary = {}
const INVENTORY_STATE := preload("res://scripts/inventory_state.gd")
const POISON_POTION := preload("res://scenes/objects/poison_potion.gd")
signal inventory_changed
signal healing_potion_used
signal potion_use_rejected(reason: String)
var inventory := INVENTORY_STATE.new()
var skill_points := 0
var skill_allocations: Dictionary = {}
var weapon_form := ""
var unlocked_skills: Array[String] = []
var collected_exp_points: Array[String] = []
var selected_ultimate_skill := ""

var _changing := false
var _booted := false
## Retain unknown fields; SaveSystem's version-1 serializer remains unchanged.
var _loaded_payload: Dictionary = {}
## XP and inventory copied at the most recently accepted checkpoint.
var _checkpoint_progress: Dictionary = {}


func _ready() -> void:
	load_game()
	get_tree().scene_changed.connect(_on_scene_changed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("new_game") and is_instance_valid(current_stage):
		get_viewport().set_input_as_handled()
		new_game()


## The only way to switch stages. `spawn_name` is a door id or a checkpoint id in the new stage
## ("" = the stage's default spot). `keep_health` = false for respawning and new games: full
## health.
func change_stage(stage_path: String, spawn_name: String = "", keep_health: bool = true, brimstone_respawn: bool = false) -> void:
	# Refuse before dialogue/health/loading state changes. No recovery fallback is chosen.
	if stage_path in B3_REFERENCES and not is_door_unlocked("b2_cleared"):
		push_warning("B3 load refused until the B2 enemy zones are cleared; saved progress preserved.")
		return
	if is_basement_reference(stage_path):
		# Door arrival is separate from checkpoint progress; B3 checkpoints live in B3.
		if spawn_name not in ["", "b1_start", "b2_start", "b2_up"]:
			push_warning("Unknown basement spawn refused; no default fallback selected.")
			return
		stage_path = FIRST_STAGE
	if is_changing():
		return    # already switching — a second press of F, for example
	if not ResourceLoader.exists(stage_path):
		# A typo in a door's target_stage, or a save file from an older version of the game. Refuse
		# it here: once _changing is set, nothing would clear it again.
		push_error("No stage at '%s'" % stage_path)
		return
	var health := -1.0
	if keep_health and current_stage != null and is_instance_valid(current_stage):
		health = current_stage.player.health
		if health <= 0:
			return    # a dead fox goes nowhere: respawn() takes it from here, with full health
	_pending_brimstone_respawn = brimstone_respawn and inventory.id_for_slot("charm") == "brimstone_rune"
	_end_dialogue()
	_changing = true
	pending_spawn = spawn_name
	player_health = health
	# Deferred: this usually runs inside a signal fired mid physics step (an Area3D, an animation);
	# swapping the scene right there would free nodes the engine is still walking.
	_begin_scene_change(stage_path)


## A conversation must not follow the fox into the next stage: Dialogic's dialogue box lives under
## the root, not in the stage, so a scene change alone doesn't close it. Looked up by path — the
## addon is optional (it is installed in part 6).
func _end_dialogue() -> void:
	var dialogic := get_node_or_null("/root/Dialogic")
	if dialogic != null and dialogic.current_timeline != null:
		dialogic.end_timeline(true)


func is_changing() -> bool:
	return _changing or (is_instance_valid(_scene_loading) and _scene_loading.busy)


func _ensure_scene_loading() -> void:
	if not is_instance_valid(_scene_loading):
		_scene_loading = SCENE_LOADING.new()
		add_child(_scene_loading)
		_scene_loading.finished.connect(_scene_load_finished)


func set_pause_safely(value: bool) -> void:
	_ensure_scene_loading()
	await _scene_loading.set_pause_safely(value, true)


func _begin_scene_change(path: String) -> void:
	_ensure_scene_loading()
	_scene_loading.start(path)


func _scene_load_finished(success: bool) -> void:
	_changing = false
	if not success:
		pending_spawn = ""
		_pending_brimstone_respawn = false
		player_health = -1.0
		scene_change_failed.emit()


func return_to_main_menu() -> void:
	if is_changing(): return
	_end_dialogue()
	_changing = true
	pending_spawn = ""
	_pending_brimstone_respawn = false
	player_health = -1.0
	_begin_scene_change(MAIN_MENU)


func continue_game() -> void:
	if is_changing(): return
	load_game()
	if has_checkpoint_conflict(): return
	_booted = true
	var path := checkpoint_stage if checkpoint_id != "" else FIRST_STAGE
	change_stage(path, checkpoint_id, false)


## Called by Stage._ready(). The Player is ready by then: Godot runs _ready() on children before
## their parent.
func register_stage(stage: Stage) -> void:
	current_stage = stage
	_changing = false
	stage.player.died.connect(respawn)
	if not _booted:
		_booted = true
		# F6 supplies --scene even when the selected scene is also the configured main scene.
		# Treat that explicit scene launch as an isolated test: don't restore a saved stage or
		# checkpoint spawn. F5 omits --scene and keeps the normal continue-from-save behavior.
		var is_running_explicit_scene := OS.get_cmdline_args().has("--scene")
		if not is_running_explicit_scene:
			if stage.scene_file_path == FIRST_STAGE and has_checkpoint_conflict():
				push_warning("Checkpoint continuation blocked; unsupported progress preserved without fallback.")
				return
			if checkpoint_id != "" and stage.scene_file_path == FIRST_STAGE:
				if not is_basement_reference(checkpoint_stage):
					change_stage(checkpoint_stage, checkpoint_id, false)
					return
				pending_spawn = checkpoint_id
	if player_health > 0:
		stage.player.health = player_health
	if _pending_brimstone_respawn:
		_pending_brimstone_respawn = false
		if inventory.consume_equipped_charm("brimstone_rune"):
			stage.player.health = 2
			notify_inventory_changed()
	if pending_spawn != "":
		stage.place_player_at(pending_spawn)
		pending_spawn = ""
	stage_changed.emit(stage)
	_restore_thrown_weapon.call_deferred(stage)


## A scene that isn't a Stage (the test yard, a menu) never calls register_stage(), so nothing else
## would clear _changing — and doors and respawning would be refused from then on.
func _on_scene_changed() -> void:
	if not (get_tree().current_scene is Stage):
		current_stage = null
		_changing = false


## The fox died: back to the last checkpoint with full health — by RELOADING its stage, even when
## it's the stage the fox is in, so everything half-done is cleared: a carried mushroom, bullets in
## flight, crabs mid-chase. No checkpoint yet: the start of the game.
func respawn() -> void:
	if has_checkpoint_conflict():
		push_warning("Respawn blocked: unresolved checkpoint reference; progress preserved.")
		return
	_restore_checkpoint_progress()
	save_game()
	if checkpoint_id != "":
		change_stage(checkpoint_stage, checkpoint_id, false, true)
	else:
		change_stage(FIRST_STAGE, "", false, true)


## A checkpoint was touched: remember it and save the game right away.
func set_checkpoint(stage_path: String, id: String) -> void:
	if is_basement_reference(stage_path) or stage_path in B3_REFERENCES:
		activate_basement_checkpoint(stage_path, id)
		return
	if has_checkpoint_conflict():
		return
	if LEGACY_BASEMENT_CHECKPOINTS.has(stage_path):
		var canonical_id := str(LEGACY_BASEMENT_CHECKPOINTS[stage_path])
		if id != canonical_id:
			push_warning("Standalone basement checkpoint '%s' refused for mismatched id '%s'." % [stage_path, id])
			return
		if is_checkpoint_reference(checkpoint_stage, checkpoint_id) \
				and basement_checkpoint_rank(canonical_id) <= basement_checkpoint_rank(checkpoint_id):
			return
		checkpoint_stage = FIRST_STAGE
		checkpoint_id = canonical_id
		_checkpoint_progress = _capture_checkpoint_progress()
		save_game()
		return
	checkpoint_stage = stage_path
	checkpoint_id = id
	_checkpoint_progress = _capture_checkpoint_progress()
	save_game()


func is_basement_reference(stage_path: String) -> bool:
	return stage_path == FIRST_STAGE or stage_path == BASEMENT_UID


## Ranks come only from this definition table, never from a saved/caller rank.
func basement_checkpoint_rank(id: String) -> int:
	return int(BASEMENT_CHECKPOINTS.get(id, {}).get("rank", 0))


func is_checkpoint_reference(stage_path: String, id: String) -> bool:
	return (is_basement_reference(stage_path) and id in ["b1_start", "b2_start"]) \
		or (stage_path in B3_REFERENCES and id == "b3_start")


func has_supported_b3_checkpoint() -> bool:
	return checkpoint_stage in B3_REFERENCES and checkpoint_id == "b3_start" \
		and _loaded_payload.get("basement_checkpoint_contract", "") == B3_CHECKPOINT_CONTRACT \
		and is_door_unlocked("b2_cleared")


func checkpoint_matches(stage_path: String, id: String) -> bool:
	if checkpoint_id != id or not is_checkpoint_reference(stage_path, id):
		return false
	if id == "b3_start":
		return has_supported_b3_checkpoint()
	return is_basement_reference(checkpoint_stage)


## accepted = one progression write; unchanged/rejected = no write or success feedback.
func activate_basement_checkpoint(stage_path: String, id: String) -> String:
	if not is_checkpoint_reference(stage_path, id) or not is_instance_valid(current_stage) \
			or _changing or has_checkpoint_conflict():
		return "rejected"
	var canonical_stage := B3_STAGE if id == "b3_start" else FIRST_STAGE
	if current_stage.scene_file_path != canonical_stage \
			or (id == "b3_start" and not is_door_unlocked("b2_cleared")):
		return "rejected"
	# The declaration must belong to this active Stage, not an inherited foreign root.
	var declared := 0
	for point: Node in get_tree().get_nodes_in_group("spawn_points"):
		if current_stage.is_ancestor_of(point) and point.get("id") == id:
			if point.owner != current_stage or not point.get_node_or_null("Spawn") is Marker3D:
				return "rejected"
			declared += 1
	if declared != 1:
		return "rejected"
	if is_checkpoint_reference(checkpoint_stage, checkpoint_id):
		if basement_checkpoint_rank(id) < basement_checkpoint_rank(checkpoint_id):
			return "rejected"
		if id == checkpoint_id:
			return "unchanged"
	checkpoint_stage = canonical_stage
	checkpoint_id = id
	_checkpoint_progress = _capture_checkpoint_progress()
	if id == "b3_start":
		# Only a fresh, validated activation creates this discriminator. Old pairs stay held.
		_loaded_payload["basement_checkpoint_contract"] = B3_CHECKPOINT_CONTRACT
	save_game()
	return "accepted"


## Unknown references are held for explicit case review, never folded into legacy B1/B2.
func has_checkpoint_conflict() -> bool:
	if checkpoint_stage in B3_REFERENCES:
		return not has_supported_b3_checkpoint()
	if is_basement_reference(checkpoint_stage):
		return checkpoint_id not in ["", "b1_start", "b2_start"]
	if LEGACY_BASEMENT_CHECKPOINTS.has(checkpoint_stage):
		return true # exact known pairs were already normalized by load_game()
	if checkpoint_stage == "" and checkpoint_id == "":
		return false
	return checkpoint_stage == "" or checkpoint_id == "" or not ResourceLoader.exists(checkpoint_stage)


func unlock_door(flag: String) -> void:
	flags[flag] = true
	save_game()


func is_door_unlocked(flag: String) -> bool:
	return flags.get(flag, false)


func enemy_zone_defeated_slots(zone_key: String) -> Array[int]:
	var defeated_by_zone: Variant = flags.get("enemy_zone_defeated_slots", {})
	var saved_slots: Variant = defeated_by_zone.get(zone_key, []) if defeated_by_zone is Dictionary else []
	var result: Array[int] = []
	if saved_slots is Array:
		for raw_slot: Variant in saved_slots:
			var slot := int(raw_slot)
			if slot >= 0 and not result.has(slot):
				result.append(slot)
	return result


func record_enemy_zone_defeat(zone_key: String, slot: int) -> void:
	if zone_key.is_empty() or slot < 0:
		return
	var defeated_by_zone: Variant = flags.get("enemy_zone_defeated_slots", {})
	var stored: Dictionary = defeated_by_zone.duplicate(true) if defeated_by_zone is Dictionary else {}
	var defeated_slots: Variant = stored.get(zone_key, [])
	var slots: Array = defeated_slots.duplicate() if defeated_slots is Array else []
	if slots.has(slot):
		return
	slots.append(slot)
	stored[zone_key] = slots
	flags["enemy_zone_defeated_slots"] = stored
	save_game()


## Writes everything to disk. Starts from _loaded_payload so unknown fields in the save file are
## kept, then overwrites the fields this script owns.
func save_game() -> void:
	if has_checkpoint_conflict():
		push_warning("Save held: unresolved checkpoint reference; existing file preserved.")
		return
	var payload := _loaded_payload.duplicate(true)
	payload["stage"] = checkpoint_stage
	payload["checkpoint"] = checkpoint_id
	var merged_flags: Dictionary = {}
	if payload.get("flags") is Dictionary:
		merged_flags = payload["flags"].duplicate(true)
	merged_flags.merge(flags, true)
	payload["flags"] = merged_flags
	payload["player_level"] = player_level
	payload["experience"] = experience
	payload["skill_spending"] = skill_spending
	payload["skill_points"] = skill_points
	payload["skill_allocations"] = skill_allocations
	payload["weapon_form"] = weapon_form
	payload["unlocked_skills"] = unlocked_skills
	payload["collected_exp_points"] = collected_exp_points
	payload["checkpoint_progress"] = _checkpoint_progress.duplicate(true)
	payload.erase("collected_skill_points")
	payload["selected_ultimate_skill"] = selected_ultimate_skill
	payload["inventory"] = inventory.serialize()
	SaveSystem.save_data(payload)
	_loaded_payload = payload


func exp_to_next_level() -> int:
	return PROGRESSION.exp_to_next_level(player_level)


func award_experience(amount: int, source_id: String = "") -> bool:
	if amount <= 0 or (source_id != "" and collected_exp_points.has(source_id)):
		return false
	if source_id != "":
		collected_exp_points.append(source_id)
	experience += amount
	while experience >= exp_to_next_level():
		experience -= exp_to_next_level()
		player_level += 1
		skill_points += PROGRESSION.SKILL_POINTS_PER_LEVEL
		level_gained.emit(player_level)
	skill_progress_changed.emit()
	save_game()
	return true


func _capture_checkpoint_progress() -> Dictionary:
	var enemy_slots: Variant = flags.get("enemy_zone_defeated_slots", {})
	return {
		"player_level": player_level,
		"experience": experience,
		"collected_exp_points": collected_exp_points.duplicate(),
		"inventory": inventory.serialize(),
		"enemy_zone_defeated_slots": enemy_slots.duplicate(true) if enemy_slots is Dictionary else {},
	}


func _restore_checkpoint_progress() -> void:
	if _checkpoint_progress.is_empty():
		_checkpoint_progress = _capture_checkpoint_progress()
	player_level = maxi(1, int(_checkpoint_progress.get("player_level", player_level)))
	experience = maxi(0, int(_checkpoint_progress.get("experience", experience)))
	var saved_collectibles: Variant = _checkpoint_progress.get("collected_exp_points", collected_exp_points)
	collected_exp_points.clear()
	if saved_collectibles is Array:
		for collectible: Variant in saved_collectibles:
			collected_exp_points.append(str(collectible))
	inventory.restore(_checkpoint_progress.get("inventory", inventory.serialize()))
	var checkpoint_enemy_slots: Variant = _checkpoint_progress.get("enemy_zone_defeated_slots", {})
	if checkpoint_enemy_slots is Dictionary:
		flags["enemy_zone_defeated_slots"] = checkpoint_enemy_slots.duplicate(true)
	inventory_changed.emit()
	skill_progress_changed.emit()


# Compatibility adapter for existing enemy/chest reward integrations.
func award_exp_point(source_id: String = "") -> bool:
	return award_experience(PROGRESSION.EXP_PER_POINT, source_id)


func reward_mini_boss(boss_id: String) -> bool:
	return award_experience(PROGRESSION.EXP_PER_POINT, "mini_boss:%s" % boss_id)


func reward_floor_clear(stage_id: String) -> bool:
	return award_experience(PROGRESSION.EXP_PER_POINT, "floor_clear:%s" % stage_id)


func reward_hidden_chest(chest_id: String) -> bool:
	return award_experience(PROGRESSION.EXP_PER_POINT, "hidden_chest:%s" % chest_id)


func skill_point_cost(node_id: String) -> int:
	var data := PROGRESSION.definition(node_id)
	if data.is_empty():
		return 0
	return mini(5, int(data.cost) + (int(skill_allocations.get(node_id, 0)) if data.get("scaling", false) else 0))


func can_purchase_skill(node_id: String) -> bool:
	var data := PROGRESSION.definition(node_id)
	if data.is_empty() or int(skill_allocations.get(node_id, 0)) >= int(data.max):
		return false
	if skill_points < skill_point_cost(node_id) or total_skill_points() < int(data.gate):
		return false
	if data.has("choose_form") and weapon_form != "":
		return false
	if data.has("form") and weapon_form != str(data.form):
		return false
	return not data.has("requires") or unlocked_skills.has(str(data.requires))


func spend_skill_point(node_id: String, form: String = "") -> bool:
	if not can_purchase_skill(node_id):
		return false
	var data := PROGRESSION.definition(node_id)
	if form != "" and str(data.get("choose_form", "")) != form:
		return false
	var cost := skill_point_cost(node_id)
	if data.has("choose_form"):
		weapon_form = str(data.choose_form)
	skill_points -= cost
	skill_spending[node_id] = int(skill_spending.get(node_id, 0)) + cost
	skill_allocations[node_id] = int(skill_allocations.get(node_id, 0)) + 1
	if node_id.begins_with("active_") or node_id.begins_with("ultimate_"):
		if not unlocked_skills.has(node_id):
			unlocked_skills.append(node_id)
	skill_progress_changed.emit()
	save_game()
	return true


func select_ultimate_skill(skill_id: String) -> bool:
	if not skill_id.begins_with("ultimate_") or not unlocked_skills.has(skill_id):
		return false
	selected_ultimate_skill = skill_id
	skill_progress_changed.emit()
	save_game()
	return true


func reset_skill_tree() -> void:
	skill_points += allocated_skill_points()
	skill_allocations.clear()
	inventory.resonance_upgrades.clear()
	skill_spending.clear()
	weapon_form = ""
	unlocked_skills.clear()
	selected_ultimate_skill = ""
	skill_progress_changed.emit()
	save_game()


func allocated_skill_points() -> int:
	var total := 0
	for node_id: Variant in skill_allocations:
		total += int(skill_spending.get(node_id, skill_allocations[node_id]))
	return total


func total_skill_points() -> int:
	return skill_points + allocated_skill_points() + inventory.enchant_spent + maxi(0, int(flags.get("farm_seed_spent", 0)))


## Reads the save file into memory. Doesn't move the fox — register_stage() does that for the
## first stage of the session. Known old B1/B2 pairs retain their checkpoint identity.
## Unsupported references are retained for review, not deleted or redirected.
func load_game() -> void:
	var data := SaveSystem.load_data()
	_loaded_payload = data.duplicate(true)
	checkpoint_stage = str(data.get("stage", ""))
	checkpoint_id = str(data.get("checkpoint", ""))
	var saved_flags: Variant = data.get("flags", {})
	inventory.restore(data.get("inventory", {}))
	player_level = maxi(1, int(data.get("player_level", 1)))
	experience = maxi(0, int(data.get("experience", 0)))
	var saved_spending: Variant = data.get("skill_spending", {})
	skill_spending = saved_spending.duplicate(true) if saved_spending is Dictionary else {}
	skill_points = maxi(0, int(data.get("skill_points", 0)))
	var saved_allocations: Variant = data.get("skill_allocations", {})
	skill_allocations = saved_allocations.duplicate(true) if saved_allocations is Dictionary else {}
	# Legacy purchases cost one SP per rank. Preserve that basis for future refunds.
	for node_id: Variant in skill_allocations:
		if not skill_spending.has(node_id):
			skill_spending[node_id] = int(skill_allocations[node_id])
	# Retired aerial-jump upgrade: return exactly the recorded spending once.
	if skill_allocations.has("char_double_jump"):
		skill_points += maxi(0, int(skill_spending.get("char_double_jump", 0)))
		skill_allocations.erase("char_double_jump")
		skill_spending.erase("char_double_jump")
	weapon_form = str(data.get("weapon_form", ""))
	var saved_skills: Variant = data.get("unlocked_skills", [])
	unlocked_skills.clear()
	if saved_skills is Array:
		for skill: Variant in saved_skills:
			unlocked_skills.append(str(skill))
	selected_ultimate_skill = str(data.get("selected_ultimate_skill", ""))
	if not unlocked_skills.has(selected_ultimate_skill):
		selected_ultimate_skill = ""
	var saved_collectibles: Variant = data.get("collected_exp_points", data.get("collected_skill_points", []))
	collected_exp_points.clear()
	if saved_collectibles is Array:
		for collectible: Variant in saved_collectibles:
			collected_exp_points.append(str(collectible))
	flags = saved_flags.duplicate(true) if saved_flags is Dictionary else {}
	if LEGACY_BASEMENT_CHECKPOINTS.get(checkpoint_stage, "") == checkpoint_id \
			and LEGACY_BASEMENT_CHECKPOINTS.has(checkpoint_stage):
		checkpoint_stage = FIRST_STAGE
	elif is_basement_reference(checkpoint_stage) and checkpoint_id in ["", "b1_start", "b2_start"]:
		checkpoint_stage = FIRST_STAGE
	elif has_supported_b3_checkpoint():
		checkpoint_stage = B3_STAGE
	var saved_checkpoint_progress: Variant = data.get("checkpoint_progress", {})
	if saved_checkpoint_progress is Dictionary and saved_checkpoint_progress.has("inventory"):
		_checkpoint_progress = saved_checkpoint_progress.duplicate(true)
	else:
		# Older saves have no checkpoint snapshot; treat their loaded progress as the baseline.
		_checkpoint_progress = _capture_checkpoint_progress()


## F9 starts over only when no transition owns the scene and save state.
func new_game() -> void:
	if is_changing(): return
	SaveSystem.delete_save()
	reset()
	_booted = true    # nothing left to continue
	change_stage(FIRST_STAGE, "", false)


## Forgets everything held in memory, as if the game had just started without a save file.
func reset() -> void:
	current_stage = null
	pending_spawn = ""
	checkpoint_stage = ""
	checkpoint_id = ""
	_checkpoint_progress = {}
	flags = {}
	player_level = 1
	experience = 0
	skill_spending.clear()
	skill_points = 0
	skill_allocations = {}
	weapon_form = ""
	unlocked_skills.clear()
	selected_ultimate_skill = ""
	collected_exp_points.clear()
	inventory = INVENTORY_STATE.new()
	inventory_changed.emit()
	player_health = -1
	_changing = false
	_booted = false
	_loaded_payload = {}
	_checkpoint_progress = _capture_checkpoint_progress()





func notify_inventory_changed() -> void:
	inventory_changed.emit()
	skill_progress_changed.emit()
	save_game()

func grant_item(definition: String, count: int = 1) -> String:
	var uid := inventory.grant(definition, count)
	if uid != "":
		notify_inventory_changed()
	return uid

func equip_item(uid: String) -> bool:
	if not flags.get("thrown_main_weapon", {}).is_empty() and inventory.items.has(uid) and str(INVENTORY_STATE.CATALOG.item(inventory.items[uid].definition).get("slot", "")) == "main":
		return false
	if not inventory.equip(uid):
		return false
	notify_inventory_changed()
	return true

func unequip_item(slot: String) -> bool:
	if not inventory.equipped.has(slot) or inventory.equipped[slot] == "":
		return false
	inventory.equipped[slot] = ""
	notify_inventory_changed()
	return true

func use_quick_item() -> bool:
	if get_tree().paused:
		return false
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or not player.can_interact():
		return false
	return use_inventory_item(str(inventory.equipped.get("consumable", "")))


func use_inventory_item(uid: String) -> bool:
	if not inventory.items.has(uid) or int(inventory.items[uid].count) <= 0:
		return false
	var definition := str(inventory.items[uid].definition)
	if INVENTORY_STATE.CATALOG.item(definition).get("slot") != "consumable":
		return false
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null:
		return false
	var reason := _throw_poison_potion(player) if definition == "venom_potion" else player.apply_potion(definition)
	if not reason.is_empty():
		potion_use_rejected.emit(reason)
		return false
	inventory.items[uid].count -= 1
	if inventory.items[uid].count <= 0:
		inventory.items.erase(uid)
		if inventory.equipped.get("consumable", "") == uid:
			inventory.equipped.consumable = ""
	notify_inventory_changed()
	if definition == "healing_potion":
		healing_potion_used.emit()
	return true


func _throw_poison_potion(player: Player) -> String:
	if get_tree().paused or is_changing() or not player.can_interact():
		return "Dùng phím Q để ném khi đang chơi."
	if has_checkpoint_conflict() or not is_instance_valid(current_stage) or current_stage.player != player:
		return "Chưa thể ném bình tại đây."
	var effects := current_stage.get_node_or_null(POISON_POTION.NODE_NAME)
	if effects == null:
		effects = POISON_POTION.new()
		effects.name = POISON_POTION.NODE_NAME
		current_stage.add_child(effects)
	if not effects.throw_from_camera():
		return "Không tìm thấy điểm đáp cho bình độc."
	return ""


func enchant_weapon(uid: String, choice: int, epoch: int) -> bool:
	var cost := inventory.apply_enchant(uid, choice, skill_points, epoch)
	if cost <= 0:
		return false
	skill_points -= cost
	notify_inventory_changed()
	return true

func prepare_enchants(uid: String) -> Array[Dictionary]:
	var result := inventory.roll_enchants(uid)
	if not result.is_empty():
		save_game()
	return result

func buy_offhand_resonance(_form: String) -> bool:
	return false

func _restore_thrown_weapon(stage: Stage) -> void:
	var record: Dictionary = flags.get("thrown_main_weapon", {})
	if not is_instance_valid(stage) or record.is_empty() or str(record.get("stage", "")) != stage.scene_file_path:
		return
	var uid := str(record.get("uid", ""))
	var point: Array = record.get("position", [])
	if not inventory.items.has(uid) or point.size() != 3:
		return
	for node in get_tree().get_nodes_in_group("thrown_weapons"):
		if stage.is_ancestor_of(node):
			return
	var drop = load("res://scenes/player/thrown_weapon.gd").new()
	drop.item_uid = uid
	drop.definition = str(inventory.items[uid].definition)
	drop.target = Vector3(float(point[0]), float(point[1]), float(point[2]))
	# Old flight records could be embedded in ceilings. Recover those at spawn.
	if int(record.get("flight_version", 0)) < 2:
		drop.target = stage.player.global_position
		record["position"] = [drop.target.x, drop.target.y, drop.target.z]
		record["flight_version"] = 2
		flags["thrown_main_weapon"] = record
		save_game()
	drop.landed = true
	stage.add_child(drop)
	drop.global_position = drop.target
