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
const FIRST_STAGE := "res://levels/level_1/basement_full.tscn"
const BASEMENT_UID := "uid://mjb8sv4t2f20"
const BASEMENT_CHECKPOINTS := {
	"b1_start": {"floor": "b1", "rank": 1},
	"b2_start": {"floor": "b2", "rank": 2},
}
const LEGACY_BASEMENT_CHECKPOINTS := {
	"res://levels/level_1/basement_b1.tscn": "b1_start",
	"uid://ut8i8xxf74gj": "b1_start",
	"res://levels/level_1/basement_b2.tscn": "b2_start",
	"uid://b7bnu12tjc0e8": "b2_start",
}
const B3_REFERENCES := ["res://levels/level_1/basement_b3.tscn", "uid://d12u1s460ag67"]

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
var player_health := -1
## Skill points live in one pool. Allocations are stored by node id so a free reset can return
## every spent point without changing the number earned from the world.
signal skill_progress_changed
var skill_points := 0
var skill_allocations: Dictionary = {}
var weapon_form := ""
var unlocked_skills: Array[String] = []
var collected_skill_points: Array[String] = []
var selected_ultimate_skill := ""

var _changing := false
var _booted := false
## Retain unknown fields; SaveSystem's version-1 serializer remains unchanged.
var _loaded_payload: Dictionary = {}


func _ready() -> void:
	load_game()
	get_tree().scene_changed.connect(_on_scene_changed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("new_game"):
		get_viewport().set_input_as_handled()
		new_game()


## The only way to switch stages. `spawn_name` is a door id or a checkpoint id in the new stage
## ("" = the stage's default spot). `keep_health` = false for respawning and new games: full
## health.
func change_stage(stage_path: String, spawn_name: String = "", keep_health: bool = true) -> void:
	# Refuse before dialogue/health/loading state changes. No recovery fallback is chosen.
	if stage_path in B3_REFERENCES and not is_door_unlocked("b2_cleared"):
		push_warning("B3 load refused until the B2 enemy zones are cleared; saved progress preserved.")
		return
	if is_basement_reference(stage_path):
		if spawn_name != "" and not BASEMENT_CHECKPOINTS.has(spawn_name):
			push_warning("Unknown basement spawn refused; no default fallback selected.")
			return
		stage_path = FIRST_STAGE
	if _changing:
		return    # already switching — a second press of F, for example
	if not ResourceLoader.exists(stage_path):
		# A typo in a door's target_stage, or a save file from an older version of the game. Refuse
		# it here: once _changing is set, nothing would clear it again.
		push_error("No stage at '%s'" % stage_path)
		return
	var health := -1
	if keep_health and current_stage != null and is_instance_valid(current_stage):
		health = current_stage.player.health
		if health <= 0:
			return    # a dead fox goes nowhere: respawn() takes it from here, with full health
	_end_dialogue()
	_changing = true
	pending_spawn = spawn_name
	player_health = health
	# Deferred: this usually runs inside a signal fired mid physics step (an Area3D, an animation);
	# swapping the scene right there would free nodes the engine is still walking.
	get_tree().change_scene_to_file.call_deferred(stage_path)


## A conversation must not follow the fox into the next stage: Dialogic's dialogue box lives under
## the root, not in the stage, so a scene change alone doesn't close it. Looked up by path — the
## addon is optional (it is installed in part 6).
func _end_dialogue() -> void:
	var dialogic := get_node_or_null("/root/Dialogic")
	if dialogic != null and dialogic.current_timeline != null:
		dialogic.end_timeline(true)


func is_changing() -> bool:
	return _changing


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
	if pending_spawn != "":
		stage.place_player_at(pending_spawn)
		pending_spawn = ""
	stage_changed.emit(stage)


## A scene that isn't a Stage (the test yard, a menu) never calls register_stage(), so nothing else
## would clear _changing — and doors and respawning would be refused from then on.
func _on_scene_changed() -> void:
	if not (get_tree().current_scene is Stage):
		_changing = false


## The fox died: back to the last checkpoint with full health — by RELOADING its stage, even when
## it's the stage the fox is in, so everything half-done is cleared: a carried mushroom, bullets in
## flight, crabs mid-chase. No checkpoint yet: the start of the game.
func respawn() -> void:
	if has_checkpoint_conflict():
		push_warning("Respawn blocked: unresolved checkpoint reference; progress preserved.")
		return
	if checkpoint_id != "":
		change_stage(checkpoint_stage, checkpoint_id, false)
	else:
		change_stage(FIRST_STAGE, "", false)


## A checkpoint was touched: remember it and save the game right away.
func set_checkpoint(stage_path: String, id: String) -> void:
	if is_basement_reference(stage_path):
		activate_basement_checkpoint(stage_path, id)
		return
	if stage_path in B3_REFERENCES or has_checkpoint_conflict():
		return
	if LEGACY_BASEMENT_CHECKPOINTS.has(stage_path):
		var canonical_id := str(LEGACY_BASEMENT_CHECKPOINTS[stage_path])
		if id != canonical_id:
			push_warning("Standalone basement checkpoint '%s' refused for mismatched id '%s'." % [stage_path, id])
			return
		checkpoint_stage = FIRST_STAGE
		checkpoint_id = canonical_id
		save_game()
		return
	checkpoint_stage = stage_path
	checkpoint_id = id
	save_game()


func is_basement_reference(stage_path: String) -> bool:
	return stage_path == FIRST_STAGE or stage_path == BASEMENT_UID


## Ranks come only from this definition table, never from a saved/caller rank.
func basement_checkpoint_rank(id: String) -> int:
	return int(BASEMENT_CHECKPOINTS.get(id, {}).get("rank", 0))


## accepted = one progression write; unchanged/rejected = no write or success feedback.
func activate_basement_checkpoint(stage_path: String, id: String) -> String:
	if not is_basement_reference(stage_path) or not BASEMENT_CHECKPOINTS.has(id) \
			or not is_instance_valid(current_stage) or current_stage.scene_file_path != FIRST_STAGE \
			or _changing or has_checkpoint_conflict():
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
	if is_basement_reference(checkpoint_stage):
		if basement_checkpoint_rank(id) < basement_checkpoint_rank(checkpoint_id):
			return "rejected"
		if id == checkpoint_id:
			return "unchanged"
	checkpoint_stage = FIRST_STAGE
	checkpoint_id = id
	save_game()
	return "accepted"


## Unknown references are held for explicit case review, never folded into legacy B1/B2.
func has_checkpoint_conflict() -> bool:
	if checkpoint_stage in B3_REFERENCES:
		return true
	if is_basement_reference(checkpoint_stage):
		return checkpoint_id != "" and not BASEMENT_CHECKPOINTS.has(checkpoint_id)
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
	payload["skill_points"] = skill_points
	payload["skill_allocations"] = skill_allocations
	payload["weapon_form"] = weapon_form
	payload["unlocked_skills"] = unlocked_skills
	payload["collected_skill_points"] = collected_skill_points
	payload["selected_ultimate_skill"] = selected_ultimate_skill
	SaveSystem.save_data(payload)
	_loaded_payload = payload


func award_skill_point(source_id: String = "") -> bool:
	if source_id != "" and collected_skill_points.has(source_id):
		return false
	if source_id != "":
		collected_skill_points.append(source_id)
	skill_points += 1
	skill_progress_changed.emit()
	save_game()
	return true


func reward_mini_boss(boss_id: String) -> bool:
	return award_skill_point("mini_boss:%s" % boss_id)


func reward_floor_clear(stage_id: String) -> bool:
	return award_skill_point("floor_clear:%s" % stage_id)


func reward_hidden_chest(chest_id: String) -> bool:
	return award_skill_point("hidden_chest:%s" % chest_id)


func spend_skill_point(node_id: String, form: String = "") -> bool:
	if skill_points <= 0:
		return false
	if form != "":
		if weapon_form != "" and weapon_form != form:
			return false
		weapon_form = form
	skill_points -= 1
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
	for rank: Variant in skill_allocations.values():
		skill_points += int(rank)
	skill_allocations.clear()
	weapon_form = ""
	unlocked_skills.clear()
	selected_ultimate_skill = ""
	skill_progress_changed.emit()
	save_game()


func allocated_skill_points() -> int:
	var total := 0
	for rank: Variant in skill_allocations.values():
		total += int(rank)
	return total


func total_skill_points() -> int:
	return skill_points + allocated_skill_points()


## Reads the save file into memory. Doesn't move the fox — register_stage() does that for the
## first stage of the session. Only the exact approved old B1/B2 pairs are reset.
## Unsupported references are retained for review, not deleted or redirected.
func load_game() -> void:
	var data := SaveSystem.load_data()
	_loaded_payload = data.duplicate(true)
	checkpoint_stage = str(data.get("stage", ""))
	checkpoint_id = str(data.get("checkpoint", ""))
	var saved_flags: Variant = data.get("flags", {})
	skill_points = maxi(0, int(data.get("skill_points", 0)))
	var saved_allocations: Variant = data.get("skill_allocations", {})
	skill_allocations = saved_allocations if saved_allocations is Dictionary else {}
	weapon_form = str(data.get("weapon_form", ""))
	var saved_skills: Variant = data.get("unlocked_skills", [])
	unlocked_skills.clear()
	if saved_skills is Array:
		for skill: Variant in saved_skills:
			unlocked_skills.append(str(skill))
	selected_ultimate_skill = str(data.get("selected_ultimate_skill", ""))
	if not unlocked_skills.has(selected_ultimate_skill):
		selected_ultimate_skill = ""
	var saved_collectibles: Variant = data.get("collected_skill_points", [])
	collected_skill_points.clear()
	if saved_collectibles is Array:
		for collectible: Variant in saved_collectibles:
			collected_skill_points.append(str(collectible))
	if checkpoint_stage == "" or checkpoint_id == "" or not ResourceLoader.exists(checkpoint_stage):
		checkpoint_stage = ""
	flags = saved_flags.duplicate(true) if saved_flags is Dictionary else {}
	if LEGACY_BASEMENT_CHECKPOINTS.get(checkpoint_stage, "") == checkpoint_id \
			and LEGACY_BASEMENT_CHECKPOINTS.has(checkpoint_stage):
		checkpoint_stage = FIRST_STAGE
		checkpoint_id = ""
		save_game()
	elif is_basement_reference(checkpoint_stage) and (checkpoint_id == "" or BASEMENT_CHECKPOINTS.has(checkpoint_id)):
		checkpoint_stage = FIRST_STAGE


## F9: forget the save file and start over in stage 1 — even in the middle of a stage change.
func new_game() -> void:
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
	flags = {}
	skill_points = 0
	skill_allocations = {}
	weapon_form = ""
	unlocked_skills.clear()
	selected_ultimate_skill = ""
	collected_skill_points.clear()
	player_health = -1
	_changing = false
	_booted = false
	_loaded_payload = {}
