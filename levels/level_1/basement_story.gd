extends Node
## Scene-local narrative adapter; combat systems keep their own state machines.
const TIMELINES := "res://dialog/timelines/"
var busy := false
var _needs_possession := false
var _stage: Stage
var _old_mode := Node.PROCESS_MODE_INHERIT
var _owns_dialogue := false
var _done := false
var _accepted := false
var _active := ""
var _camera: Camera3D
var _camera_transform := Transform3D.IDENTITY
var _camera_fov := 60.0
var _rig_mode := Node.PROCESS_MODE_ALWAYS
var _camera_tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_stage = get_parent() as Stage
	_needs_possession = _stage.has_node("B1") and GameManager.checkpoint_id.is_empty() and GameManager.player_level == 1 and GameManager.experience == 0 and not GameManager.is_door_unlocked("b1_split_cleared")
	Dialogic.signal_event.connect(_on_story_signal)

func _process(_delta: float) -> void:
	if busy or _stage == null or GameManager.current_stage != _stage or GameManager.is_changing() or get_tree().paused:
		return
	if not _stage.player.can_interact() or Dialogic.current_timeline != null:
		return
	if _stage.has_node("B1") and not GameManager.flags.get("story_possession", false):
		# Existing progressed saves retain their current body and start point.
		if not _needs_possession:
			GameManager.flags["story_possession"] = true
			GameManager.save_game()
		else:
			play_event("possession", "story_possession")
		return
	if _stage.has_node("B1") and not GameManager.flags.get("story_b1_clear", false) and _b1_cleared():
		play_event("b1_clear", "story_b1_clear")

func _b1_cleared() -> bool:
	if GameManager.is_door_unlocked("b1_split_cleared"):
		return true
	var zones := _stage.get_node_or_null("B1/EnemyZones")
	if zones == null or zones.get_child_count() == 0:
		return false
	for zone: Node in zones.get_children():
		if zone is EnemyZone and not zone.is_cleared():
			return false
	return true

func wants_boss_story(kind: StringName) -> bool:
	return not GameManager.flags.get("story_dark_fairy_" + str(kind), false)

func play_boss_story(kind: StringName) -> void:
	while busy or Dialogic.current_timeline != null or get_tree().paused:
		await get_tree().process_frame
	await play_event("dark_fairy_" + str(kind), "story_dark_fairy_" + str(kind))

func play_event(event: String, seen_flag: String = "") -> void:
	if busy or Dialogic.current_timeline != null or not is_instance_valid(_stage.player) or _stage.player.health <= 0:
		return
	busy = true
	_done = false
	_accepted = false
	_active = event
	_old_mode = _stage.process_mode
	_stage.player.start_talk()
	_stage.process_mode = Node.PROCESS_MODE_DISABLED
	_rig_mode = _stage.camera_rig.process_mode
	_stage.camera_rig.process_mode = Node.PROCESS_MODE_DISABLED
	_camera = get_viewport().get_camera_3d()
	if is_instance_valid(_camera):
		_camera_transform = _camera.global_transform
		_camera_fov = _camera.fov
	Dialogic.Choices.use_input_action = true
	_owns_dialogue = true
	Dialogic.start(TIMELINES + event + ".dtl")
	await Dialogic.timeline_ended
	_owns_dialogue = false
	_restore()
	if _done and (event != "possession" or _accepted) and seen_flag != "":
		GameManager.flags[seen_flag] = true
		GameManager.save_game()
	_active = ""
	busy = false

func _on_story_signal(argument: String) -> void:
	if not busy:
		return
	if argument == "story_done":
		_done = true
	elif argument == "story_accept":
		_accepted = true
	elif argument == "story_ladder":
		_focus_ladder()

func _focus_ladder() -> void:
	var ladder := _stage.get_node_or_null("B1/LadderSpot_B1_B2") as Node3D
	if ladder == null or not is_instance_valid(_camera):
		return
	# A fixed downward shot stays above the authored opening; original view is restored exactly.
	var focus := ladder.global_position + Vector3.UP
	var pose := Transform3D(Basis.IDENTITY, focus + Vector3(0, 7, 5)).looking_at(focus, Vector3.UP)
	_camera_tween = create_tween()
	_camera_tween.set_parallel(true)
	_camera_tween.tween_property(_camera, "global_transform", pose, 0.65).set_trans(Tween.TRANS_SINE)
	_camera_tween.tween_property(_camera, "fov", 42.0, 0.65)

func _restore() -> void:
	if is_instance_valid(_camera_tween):
		_camera_tween.kill()
	if is_instance_valid(_camera):
		_camera.global_transform = _camera_transform
		_camera.fov = _camera_fov
	if is_instance_valid(_stage):
		_stage.process_mode = _old_mode
		if is_instance_valid(_stage.camera_rig):
			_stage.camera_rig.process_mode = _rig_mode
		if is_instance_valid(_stage.player):
			_stage.player.finish_talk()

func _exit_tree() -> void:
	if _owns_dialogue:
		Dialogic.end_timeline(true)
	if busy:
		_restore()
