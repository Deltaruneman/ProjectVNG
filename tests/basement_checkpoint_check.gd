extends SceneTree

## T013/T025/T026. Run ONLY in a fresh disposable project with pre-autoload
## isolation verified as described in validation.md. Never use real save fixtures.
const FULL := "res://levels/level_1/basement_full.tscn"
const FULL_UID := "uid://mjb8sv4t2f20"
const B3 := "res://levels/level_1/basement_b3.tscn"
const B3_UID := "uid://d12u1s460ag67"
var passed := 0
var failed := 0
var lane := "fixtures"
var registrations := 0
var manager: Node
var save_system: Node
var registered_position := Vector3.ZERO
var registered_camera := Vector3.ZERO


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var expected := OS.get_environment("ARCANA_EXPECTED_USERDATA").replace("\\", "/")
	if expected.is_empty() or OS.get_user_data_dir().replace("\\", "/") != expected \
			or not OS.get_cmdline_user_args().has("--isolated-copy") \
			or not str(ProjectSettings.get_setting("application/config/custom_user_dir_name", "")).begins_with("ArcanaCheckpoint-"):
		print("BLOCKED: verified pre-autoload disposable isolation required")
		quit(2)
		return
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--lane="):
			lane = arg.trim_prefix("--lane=")
	manager = root.get_node("GameManager")
	save_system = root.get_node("SaveSystem")
	DirAccess.make_dir_recursive_absolute(expected + "/fixtures")
	save_system.save_path = "user://fixtures/" + str(Time.get_ticks_usec()) + ".json"
	manager.stage_changed.connect(func(stage: Node):
		registrations += 1
		registered_position = stage.player.global_position
		registered_camera = stage.camera_rig.global_position)
	_check(manager.has_method("activate_basement_checkpoint"), "checkpoint request API exists")
	if failed == 0:
		match lane:
			"fixtures": await _fixtures()
			"interaction": await _interaction()
			"recovery": await _recovery()
			_: _check(false, "known independent lane")
	print("CHECKPOINT RESULT [", lane, "]: ", passed, " passed, ", failed, " failed")
	print("BLOCKED [old-B3 recovery]: policy not selected; refusal tested separately")
	print("NOT RUN [real waves]: no provider/interface implementation in this slice")
	if current_scene != null:
		current_scene.queue_free()
		await process_frame
	quit(1 if failed > 0 else 0)


func _check(condition: bool, label: String) -> void:
	if condition:
		passed += 1
		print("PASSED [", lane, "]: ", label)
	else:
		failed += 1
		print("FAILED [", lane, "]: ", label)


func _fixture(stage_path: String = "", id: String = "") -> Dictionary:
	return {"stage": stage_path, "checkpoint": id, "sentinel": {"inventory": ["keep", 7]},
		"flags": {"unrelated": true, "basement_b1_cleared": true, "basement_parkour_unlocked": true},
		"arbitrary_saved_rank": 999}


func _load_fixture(data: Dictionary) -> void:
	save_system.save_data(data)
	manager.reset()
	manager.load_game()


func _open_stage() -> Node:
	var result := change_scene_to_file(FULL)
	_check(result == OK, "combined PackedScene load requested")
	await scene_changed
	await process_frame
	var stage := current_scene as Node
	# Fixture-only deterministic isolation from unrelated combat, not wave acceptance.
	for timer in stage.find_children("*", "Timer", true, false):
		if timer.get_parent().get_script() != null and timer.get_parent().get_script().resource_path == "res://levels/objects/enemy_zone/enemy_zone.gd":
			timer.stop()
	stage.player.set_physics_process(false)
	stage.player.set_process_input(false)
	stage.player.set_process_unhandled_input(false)
	return stage


func _fixtures() -> void:
	_load_fixture(_fixture())
	var stage := await _open_stage()
	_check(manager.FIRST_STAGE == FULL, "manager default agrees with combined stage")
	_check(str(ProjectSettings.get_setting("application/run/main_scene")) in [FULL, FULL_UID], "project startup is combined stage")
	_check(manager.activate_basement_checkpoint(FULL, "b1_start") == "accepted", "B1 explicit acceptance")
	_check(manager.checkpoint_id == "b1_start", "trusted B1 identity ignores arbitrary saved rank")
	var bytes := FileAccess.get_file_as_string(save_system.save_path)
	_check(manager.activate_basement_checkpoint(FULL_UID, "b1_start") == "unchanged", "UID same-current idempotence")
	_check(FileAccess.get_file_as_string(save_system.save_path) == bytes, "same-current causes no save write")
	_check(manager.activate_basement_checkpoint(FULL, "b2_start") == "accepted", "B1 advances to B2")
	bytes = FileAccess.get_file_as_string(save_system.save_path)
	_check(manager.activate_basement_checkpoint(FULL, "b1_start") == "rejected", "B2 rejects B1")
	_check(manager.activate_basement_checkpoint(B3, "b3_start") == "rejected", "foreign stage rejected")
	_check(manager.activate_basement_checkpoint(FULL, "unknown") == "rejected", "undeclared ID rejected")
	manager.set_checkpoint(FULL, "b1_start")
	_check(manager.checkpoint_id == "b2_start", "stock setter cannot bypass basement rank")
	_check(FileAccess.get_file_as_string(save_system.save_path) == bytes, "rejections do not save")
	var saved: Dictionary = save_system.load_data()
	_check(saved.get("sentinel") == JSON.parse_string(JSON.stringify(_fixture())).sentinel, "unknown nested payload preserved")
	_check(saved.flags == _fixture().flags, "unrelated flags/earned state preserved")
	_check(saved.version == 1, "serializer version unchanged")
	_load_fixture(_fixture())
	manager.current_stage = stage
	var b1 := stage.get_node("B1/Checkpoint_b1")
	b1.owner = null
	_check(manager.activate_basement_checkpoint(FULL, "b1_start") == "rejected", "foreign owner rejected")
	b1.owner = stage
	var duplicate := b1.duplicate()
	b1.get_parent().add_child(duplicate)
	duplicate.owner = stage
	_check(manager.activate_basement_checkpoint(FULL, "b1_start") == "rejected", "duplicate declaration rejected")
	duplicate.queue_free()
	await process_frame
	manager.set_checkpoint("res://levels/level_1/stage_2.tscn", "dock")
	_check(manager.checkpoint_id == "dock" and save_system.load_data().stage == "res://levels/level_1/stage_2.tscn", "unrelated supported stage stock setter preserved")
	# T087: known standalone B1/B2 pairs retain their equivalent checkpoint, no disk reset.
	for pair in [["res://levels/level_1/basement_b1.tscn", "b1_start"], ["uid://ut8i8xxf74gj", "b1_start"],
			["res://levels/level_1/basement_b2.tscn", "b2_start"], ["uid://b7bnu12tjc0e8", "b2_start"]]:
		_load_fixture(_fixture(pair[0], pair[1]))
		_check(manager.checkpoint_stage == FULL and manager.checkpoint_id == pair[1], "exact legacy identity preserved " + pair[0])
		_check(save_system.load_data().stage == pair[0] and save_system.load_data().checkpoint == pair[1], "legacy disk pair not rewritten " + pair[0])
		_check(save_system.load_data().sentinel == JSON.parse_string(JSON.stringify(_fixture())).sentinel and save_system.load_data().flags == _fixture().flags, "legacy retains sentinel/flags " + pair[0])
	for reference in [FULL, FULL_UID]:
		for id in ["b1_start", "b2_start"]:
			_load_fixture(_fixture(reference, id))
			_check(manager.checkpoint_id == id, "valid combined identity preserved " + reference + "/" + id)
	for pair in [["res://levels/level_1/basement_b1.tscn", "other"], ["res://unknown/basement_b2.tscn", "b2_start"],
			[FULL, "unknown"], [B3, "b3_start"], [B3_UID, "b3_start"]]:
		var data := _fixture(pair[0], pair[1])
		_load_fixture(data)
		bytes = FileAccess.get_file_as_string(save_system.save_path)
		_check(manager.checkpoint_stage == pair[0] and manager.checkpoint_id == pair[1], "out-of-set pair not reset " + pair[0])
		manager.save_game()
		_check(FileAccess.get_file_as_string(save_system.save_path) == bytes, "unresolved pair file preserved " + pair[0])
		manager.respawn()
		await process_frame
		_check(current_scene == stage and not manager.is_changing(), "unresolved pair has no respawn fallback " + pair[0])
	# Guard must reject path and UID before mutating loading/health/dialogue state.
	_load_fixture(_fixture(B3, "b3_start"))
	manager.current_stage = stage
	manager.pending_spawn = "sentinel"
	manager.player_health = 2
	var registration_before := registrations
	for reference in [B3, B3_UID]:
		manager.change_stage(reference, "b3_start", false)
		await process_frame
		_check(current_scene == stage and not manager.is_changing(), "B3 zero-load refusal " + reference)
		_check(manager.pending_spawn == "sentinel" and manager.player_health == 2, "B3 refusal preserves pending/health " + reference)
	manager.respawn()
	await process_frame
	_check(current_scene == stage and registrations == registration_before, "B3 death caller refused with no re-registration")
	_check(manager.activate_basement_checkpoint(FULL, "b1_start") == "rejected", "unresolved B3 cannot be implicitly overwritten")
	# Exercise startup caller independently, without selecting a recovery destination.
	_load_fixture(_fixture(B3_UID, "b3_start"))
	await _open_stage()
	_check(registrations == registration_before and manager.checkpoint_stage == B3_UID, "B3 startup refuses continuation; no success/fallback registration")


func _move(stage: Node, position: Vector3) -> void:
	stage.player.global_position = position
	stage.player.velocity = Vector3.ZERO
	await physics_frame
	await physics_frame
	await process_frame
	await process_frame # process_frame fires before Node._process updates the prompt.


func _press_f(echo: bool = false) -> void:
	var key := InputEventKey.new()
	key.physical_keycode = KEY_F
	key.pressed = true
	key.echo = echo
	Input.parse_input_event(key)
	await process_frame
	key = InputEventKey.new()
	key.physical_keycode = KEY_F
	key.pressed = false
	Input.parse_input_event(key)
	await process_frame


func _interaction() -> void:
	_load_fixture(_fixture())
	var stage := await _open_stage()
	var b1 := stage.get_node_or_null("B1/Checkpoint_b1")
	var b2 := stage.get_node_or_null("B2/Checkpoint_b2")
	_check(b1 != null and b2 != null, "both local checkpoint instances exist")
	if b1 == null or b2 == null:
		return
	for point in [b1, b2]:
		_check(point.owner == stage and point.is_in_group("spawn_points"), "active Stage ownership/group " + point.id)
		_check(point.get_node_or_null("Spawn") is Marker3D, "child Spawn " + point.id)
	await _move(stage, b1.global_position)
	_check(manager.checkpoint_id == "", "arrival alone does not activate B1")
	_check(b1.get_node("Prompt").visible, "nearby F prompt")
	_check(not b1.get_node("ActivationFeedback").visible, "no success on arrival")
	await _press_f(true)
	_check(manager.checkpoint_id == "", "key echo is not a fresh activation")
	await _press_f()
	_check(manager.checkpoint_id == "b1_start", "physical F dispatch activates B1")
	_check(b1.get_node("ActivationFeedback").visible and b1.get_node("ActivationFeedback").text == "Checkpoint activated.", "exact acceptance feedback")
	_check(b1.get_node("AnimatedSprite3D").modulate != Color.WHITE, "accepted marker tint")
	await _capture("b1-accepted")
	var bytes := FileAccess.get_file_as_string(save_system.save_path)
	await _press_f()
	_check(FileAccess.get_file_as_string(save_system.save_path) == bytes, "repeated F is idempotent")
	await _move(stage, b2.global_position)
	_check(manager.checkpoint_id == "b1_start", "B2 arrival alone does not activate")
	var dialogic := root.get_node_or_null("Dialogic")
	if dialogic != null:
		var timeline := DialogicTimeline.new()
		dialogic.current_timeline = timeline
		await _press_f()
		_check(manager.checkpoint_id == "b1_start", "dialogue blocks local activation")
		dialogic.current_timeline = null
	stage.player.health = 0
	await _press_f()
	_check(manager.checkpoint_id == "b1_start", "dead player cannot activate")
	stage.player.health = stage.player.max_health
	await _press_f()
	_check(manager.checkpoint_id == "b2_start", "living F advances B2")
	await _capture("b2-accepted")
	await _move(stage, b1.global_position)
	bytes = FileAccess.get_file_as_string(save_system.save_path)
	await _press_f()
	_check(manager.checkpoint_id == "b2_start" and FileAccess.get_file_as_string(save_system.save_path) == bytes, "lower-floor F no downgrade/write")
	_check(not b1.get_node("ActivationFeedback").visible, "lower-floor F no success feedback")
	await _move(stage, Vector3(0, 20, 0))
	_check(not b1.get_node("Prompt").visible and not b2.get_node("Prompt").visible, "prompt disappears outside range")
	_check(stage.find_children("Hud", "", true, false).size() == 1, "one HUD")
	# Synthetic overlap dispatch: one physical event may activate only one area.
	manager.checkpoint_stage = ""
	manager.checkpoint_id = ""
	b2.global_position = b1.global_position
	await _move(stage, b1.global_position)
	await _press_f()
	var feedback_count := int(b1.get_node("ActivationFeedback").visible) + int(b2.get_node("ActivationFeedback").visible)
	_check(feedback_count == 1, "synthetic overlapping checkpoints consume F once")


func _capture(label: String) -> void:
	if not OS.get_cmdline_user_args().has("--capture") or DisplayServer.get_name() == "headless":
		return
	for frame in range(15):
		await process_frame
	await RenderingServer.frame_post_draw
	var path := "user://fixtures/" + label + ".png"
	print("RENDER_HUD=", str(current_scene.get_node("Hud").visible), "; layer=", current_scene.get_node("Hud").layer)
	_check(root.get_texture().get_image().save_png(path) == OK, "rendered capture " + label)
	print("CAPTURE=", ProjectSettings.globalize_path(path))


func _recovery() -> void:
	for pair in [["", ""], [FULL, "b1_start"], [FULL, "b2_start"], [FULL_UID, "b2_start"],
			["uid://ut8i8xxf74gj", "b1_start"], ["uid://b7bnu12tjc0e8", "b2_start"]]:
		_load_fixture(_fixture(pair[0], pair[1]))
		var stage := await _open_stage()
		var expected: Vector3 = stage.get_node("Spawn").global_position
		if manager.checkpoint_id != "":
			var node_name := "B2/Checkpoint_b2" if manager.checkpoint_id == "b2_start" else "B1/Checkpoint_b1"
			expected = stage.get_node(node_name + "/Spawn").global_position
		_check(registered_position.is_equal_approx(expected), "startup placement at registration " + str(pair))
		_check(stage.camera_rig.target == stage.player and registered_camera.is_equal_approx(expected + stage.camera_rig.focus_offset), "startup orbit camera focus snap " + str(pair))
		if pair[0] == FULL and pair[1] == "b2_start":
			await _capture("b2-recovery")
		# Actual floor ray and capsule settling in the copied scene, no wave acceptance.
		await physics_frame
		var ray := PhysicsRayQueryParameters3D.create(expected + Vector3(0, 0.5, 0), expected - Vector3(0, 1, 0), 1)
		var hit: Dictionary = stage.get_world_3d().direct_space_state.intersect_ray(ray)
		_check(not hit.is_empty() and hit.normal.y > 0.9, "support surface under spawn " + str(pair))
		stage.player.set_physics_process(true)
		for frame in range(30):
			await physics_frame
		_check(stage.player.is_on_floor() and absf(stage.player.global_position.y - expected.y) < 0.4, "capsule settles on supported spawn " + str(pair))
		var expected_level := 1 if manager.checkpoint_id == "b2_start" else 0
		var floor_name := "B2" if expected_level == 1 else "B1"
		_check(stage.current_level() == expected_level and stage.get_node(floor_name).visible, "supported spawn floor visible " + str(pair))
		var before := registrations
		stage.player.fsm.current_state.take_damage(stage.player.max_health)
		await scene_changed
		await process_frame
		stage = current_scene as Node
		_check(registrations == before + 1 and stage.scene_file_path == FULL, "damage/dead state reloads combined Stage once " + str(pair))
		_check(stage.player.global_position.distance_to(expected) < 0.05, "death placement " + str(pair))
		_check(stage.player.health == stage.player.max_health and stage.camera_rig.target == stage.player, "death heals and targets camera " + str(pair))
		_check(stage.current_level() == expected_level and stage.get_node(floor_name).visible, "death recovery floor visible " + str(pair))
		_check(save_system.load_data().sentinel == JSON.parse_string(JSON.stringify(_fixture())).sentinel, "recovery preserves unrelated data " + str(pair))
