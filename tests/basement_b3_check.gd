extends Node
## T087 integration. Launch the .tscn ONLY in a disposable project with exact user-data
## path verified before autoload. Boss AI/timer suppression is fixture-only, not boss acceptance.
const FULL := "res://levels/level_1/basement_full.tscn"
const B3 := "res://levels/level_1/basement_b3.tscn"
var stage: Stage
var player: Player
var rig: CameraRig
var checks := 0
var failures := 0
var registrations := 0
var sentinel: Dictionary

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ", label)

func ticks(n: int = 1) -> void:
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if OS.get_user_data_dir().replace("\\", "/") != OS.get_environment("ARCANA_EXPECTED_USERDATA").replace("\\", "/") or not OS.get_cmdline_user_args().has("--isolated-copy"):
		get_tree().quit(2)
		return
	get_tree().current_scene = null
	GameManager.stage_changed.connect(_registered)
	run.call_deferred()

func _registered(next: Stage) -> void:
	registrations += 1
	# Avoid unrelated combat/cinematics before the first physics frame of each destination.
	if next.has_node("DarkFairy"): next.get_node("DarkFairy").set_physics_process(false)
	for timer in next.find_children("*", "Timer", true, false):
		if timer.get_parent() is EnemyZone: timer.stop()

func bind_stage() -> void:
	stage = get_tree().current_scene as Stage
	player = stage.player
	rig = stage.camera_rig
	player.invincible = true

func stop() -> void:
	for action in ["left", "right", "up", "down"]: Input.action_release(action)

func drive(target: Vector3, frames: int = 350) -> void:
	for i in frames:
		var delta := target - player.global_position
		delta.y = 0
		if delta.length() < 0.14: break
		var input := delta.normalized().rotated(Vector3.UP, -rig.yaw)
		stop()
		if absf(input.x) > 0.02: Input.action_press("right" if input.x > 0 else "left", absf(input.x))
		if absf(input.z) > 0.02: Input.action_press("down" if input.z > 0 else "up", absf(input.z))
		await ticks()
	stop()
	await ticks(4)

func setup(at: Vector3) -> void:
	stop()
	player.global_position = at
	player.velocity = Vector3.ZERO
	player.fsm.change_state(player.fsm.states.idle)
	rig.yaw = 0
	rig.snap_to_target()
	await ticks(35)

func tap(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await ticks(2)
	event = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	Input.parse_input_event(event)
	await ticks(5)

func wait_transition(before: int, path: String) -> void:
	for i in 260:
		if registrations > before and get_tree().current_scene != null and get_tree().current_scene.scene_file_path == path:
			bind_stage()
			await ticks(35)
			return
		await ticks()
	check(false, "transition timeout " + path)
	get_tree().quit(2)

func bytes() -> String:
	return FileAccess.get_file_as_string(SaveSystem.save_path)

func preserved(label: String) -> void:
	var data := SaveSystem.load_data()
	check(data.get("sentinel") == sentinel, "unknown nested payload " + label)
	check(int(data.get("skill_points", -1)) == 10 and GameManager.skill_points == 10, "SP preserved " + label)
	check(data.flags.get("unrelated", false) and data.flags.get("b2_cleared", false), "clear/unrelated flags " + label)
	check(data.skill_allocations == JSON.parse_string('{"char_attack":1}') and data.collected_skill_points.has("fixture:0"), "allocations/collected IDs " + label)

func supported(label: String, point: Marker3D, floor_path: String) -> void:
	var q := PhysicsRayQueryParameters3D.create(point.global_position + Vector3.UP * 0.5, point.global_position - Vector3.UP, 1)
	var hit := stage.get_world_3d().direct_space_state.intersect_ray(q)
	check(not hit.is_empty() and hit.normal.y > 0.9, "support under Spawn " + label)
	check(player.is_on_floor() and player.global_position.distance_to(point.global_position) < 0.4, "settled at Spawn " + label)
	check(stage.get_node(floor_path).is_visible_in_tree(), "floor visible " + label)
	check(rig.target == player and rig.camera.is_current() and rig.global_position.distance_to(player.global_position + rig.focus_offset) < 0.05, "orbit focus/target " + label)
	var sq := PhysicsShapeQueryParameters3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = rig.collision_radius
	sq.shape = sphere
	sq.transform = Transform3D(Basis.IDENTITY, rig.camera.global_position)
	sq.collision_mask = 1
	sq.exclude = [player.get_rid()]
	check(stage.get_world_3d().direct_space_state.intersect_shape(sq, 1).is_empty(), "camera lens outside geometry " + label)
	print("B3_TRACE ", label, " player=", player.global_position, " spawn=", point.global_position, " support=", hit.collider.get_path() if not hit.is_empty() else "none", " camera=", rig.camera.global_position, " focus=", rig.global_position, " cp=", GameManager.checkpoint_stage, "/", GameManager.checkpoint_id)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("user://t087-" + label + ".png")

func door_to_b3() -> void:
	var door: Node3D = stage.get_node("B2/Door_b2_up")
	await drive(door.global_position + Vector3(0, 0.2, 2.3))
	check(door.get_node("InteractiveArea3D").get_overlapping_bodies().has(player), "B2 door reached by walking")
	var before := registrations
	await tap(KEY_F)
	await wait_transition(before, B3)
	await supported("b3-door-arrival", stage.get_node("B3/Door_b3_down/Spawn"), "B3/World/Floor")

func door_to_b2() -> void:
	var door: Node3D = stage.get_node("B3/Door_b3_down")
	await drive(door.global_position + Vector3(0, 0.2, 2.3))
	check(door.get_node("InteractiveArea3D").get_overlapping_bodies().has(player), "B3 down reached by walking")
	var saved := bytes()
	var before := registrations
	await tap(KEY_F)
	await wait_transition(before, FULL)
	var target: Marker3D = stage.get_node("B2/Door_b2_up/Spawn")
	await supported("b2-return", target, "B2/World/Floor")
	check(stage.current_level() == 1, "B2 selector on door return")
	check(not stage.get_node("B2/Door_b2_up/InteractiveArea3D").get_overlapping_bodies().has(player), "return Spawn outside door trigger")
	check(player.global_position.distance_to(stage.get_node("B2/Checkpoint_b2/Spawn").global_position) > 3.0, "return point separate from checkpoint")
	check(bytes() == saved, "door does not write checkpoint/save")
	before = registrations
	await tap(KEY_F)
	await ticks(45)
	check(registrations == before and stage.scene_file_path == FULL, "return has no door loop even on F")

func die_to_b3(label: String) -> void:
	var before := registrations
	player.die()
	await wait_transition(before, B3)
	await supported(label, stage.get_node("B3/Checkpoint_b3/Spawn"), "B3/World/Floor")
	check(player.health == player.max_health, "death fully heals " + label)
	check(not stage.get_node("B3/Checkpoint_b3/ActivationFeedback").visible, "recovery does not replay activation " + label)
	preserved(label)

func run() -> void:
	if OS.get_cmdline_user_args().has("--compatibility"):
		await compatibility()
		return
	SaveSystem.save_path = "user://t087-flow.json"
	SaveSystem.save_data({"stage":FULL,"checkpoint":"b2_start","sentinel":{"inventory":["herb",7],"nested":{"keep":true}},"flags":{"unrelated":true},"skill_points":7,"skill_allocations":{"char_attack":1},"collected_skill_points":["fixture:0"]})
	sentinel = SaveSystem.load_data().sentinel
	GameManager.reset()
	GameManager.load_game()
	get_tree().change_scene_to_file(FULL)
	await get_tree().scene_changed
	bind_stage()
	await ticks(35)
	var before := registrations
	GameManager.change_stage(B3, "b3_down")
	await ticks(5)
	check(registrations == before and not GameManager.is_changing() and stage.scene_file_path == FULL, "B3 refuses entry before B2 clear")
	var zone: EnemyZone = stage.get_node("B2/EnemyZones/EnemyZone_A")
	var container: Node = zone.get_parent()
	for kill in 3:
		var old := container.get_children()
		zone._on_timer_timeout()
		await ticks(2)
		var victim: EnemyCharacter
		for child in container.get_children():
			if child is EnemyCharacter and child not in old: victim = child
		check(victim != null, "B2 finite enemy spawned")
		if victim == null:
			get_tree().quit(2)
			return
		victim.get_node("Direction/HurtArea3D").take_damage(Vector3.RIGHT, 999, player)
		await ticks(150)
	check(zone.is_cleared() and GameManager.is_door_unlocked("b2_cleared"), "actual three defeats persist B2 clear")
	for area in stage.find_children("*", "Area3D", true, false):
		if area is SkillPointPickup: area._on_area_entered(player.get_node("Direction/HurtArea3D"))
	await ticks(3)
	preserved("B2-clear")
	var saved := bytes()
	await door_to_b3()
	check(GameManager.checkpoint_id == "b2_start" and bytes() == saved, "B3 entry never activates checkpoint")
	var exit: Node3D = stage.get_node("B3/Door_b3_exit")
	await drive(exit.global_position + Vector3(0, 0.2, 2.3))
	check(not exit.transition_enabled and exit.target_stage.is_empty() and exit.target_door.is_empty(), "exit remains targetless and disabled")
	check(exit.get_node_or_null("InteractiveArea3D") == null and exit.find_children("Prompt", "", true, false).is_empty(), "exit has no F interaction/prompt")
	before = registrations
	exit._on_interacted()
	await tap(KEY_F)
	await ticks(60)
	check(registrations == before and not GameManager.is_changing() and bytes() == saved, "disabled exit never loads or writes")
	await door_to_b2()
	check(GameManager.checkpoint_id == "b2_start", "B3 down preserves B2 checkpoint")
	await door_to_b3()
	var cp: Node3D = stage.get_node("B3/Checkpoint_b3")
	await drive(cp.global_position + Vector3(0, 0.2, 1.1))
	check(cp.get_node("Prompt").visible and GameManager.checkpoint_id == "b2_start" and bytes() == saved, "near B3 shows F without auto activation")
	await tap(KEY_ESCAPE)
	check(PauseMenu.is_open and get_tree().paused, "B3 Esc pauses")
	PauseMenu.open_settings()
	await ticks(3)
	await tap(KEY_ESCAPE)
	await tap(KEY_ESCAPE)
	check(not get_tree().paused and not PauseMenu.is_open, "B3 Settings resumes")
	await tap(KEY_F)
	check(GameManager.checkpoint_stage == B3 and GameManager.checkpoint_id == "b3_start" and GameManager.has_supported_b3_checkpoint(), "F activates new ranked B3 checkpoint")
	check(cp.get_node("ActivationFeedback").visible and cp.get_node("ActivationFeedback").text == "Checkpoint activated.", "B3 exact activation feedback")
	check(is_equal_approx(cp._sprite.modulate.r, cp.ACTIVE_TINT.r), "B3 marker active tint")
	check(SaveSystem.load_data().get("basement_checkpoint_contract") == GameManager.B3_CHECKPOINT_CONTRACT, "new B3 discriminator persisted")
	saved = bytes()
	var modified_time := FileAccess.get_modified_time(SaveSystem.save_path)
	# FileAccess exposes seconds: cross that boundary to catch identical-content rewrites.
	OS.delay_msec(1100)
	await tap(KEY_F)
	check(bytes() == saved and FileAccess.get_modified_time(SaveSystem.save_path) == modified_time and not cp.get_node("ActivationFeedback").visible, "repeat B3 neither writes nor replays feedback")
	await ticks(125)
	OS.delay_msec(1100)
	await tap(KEY_F)
	check(bytes() == saved and FileAccess.get_modified_time(SaveSystem.save_path) == modified_time and not cp.get_node("ActivationFeedback").visible, "later repeat B3 still idempotent")
	await die_to_b3("b3-checkpoint-death")
	FileAccess.open("user://flow-after-b3-death.json", FileAccess.WRITE).store_string(bytes())
	check(bytes() == saved, "B3 death preserves save bytes")
	await door_to_b2()
	check(GameManager.checkpoint_id == "b3_start" and GameManager.checkpoint_stage == B3, "B3 active return still lands B2, checkpoint stays B3")
	for path in ["B2/Checkpoint_b2", "B1/Checkpoint_b1"]:
		cp = stage.get_node(path)
		await setup(cp.global_position + Vector3(0, 0.2, 1.1))
		await tap(KEY_F)
		check(GameManager.checkpoint_id == "b3_start" and bytes() == saved and not cp.get_node("ActivationFeedback").visible, "rank3 rejects " + path)
	GameManager.set_checkpoint("res://levels/level_1/basement_b2.tscn", "b2_start")
	check(GameManager.checkpoint_id == "b3_start" and bytes() == saved, "legacy stock B2 setter cannot downgrade rank3")
	await setup(stage.get_node("B2/Checkpoint_b2/Spawn").global_position)
	await die_to_b3("death-from-b2")
	await door_to_b2()
	preserved("flow-ended-at-B2")
	FileAccess.open("user://flow-ended-at-b2.json", FileAccess.WRITE).store_string(bytes())
	print("B3_FLOW_RESULT checks=", checks, " failures=", failures)
	get_tree().quit(1 if failures else 0)


func compatibility() -> void:
	SaveSystem.save_path = "user://t087-compat.json"
	var cases: Array = [
		{"name":"old-path","stage":B3,"checkpoint":"b3_start"},
		{"name":"old-uid","stage":"uid://d12u1s460ag67","checkpoint":"b3_start"},
		{"name":"future-contract","stage":B3,"checkpoint":"b3_start","basement_checkpoint_contract":"explicit_b3_v2"},
		{"name":"unknown-id","stage":B3,"checkpoint":"old_boss","basement_checkpoint_contract":"explicit_b3_v1"},
		{"name":"missing-clear","stage":B3,"checkpoint":"b3_start","basement_checkpoint_contract":"explicit_b3_v1","no_clear":true},
		{"name":"unknown-stage","stage":"res://unknown/basement_b2.tscn","checkpoint":"b2_start"},
	]
	for data: Dictionary in cases:
		data["flags"] = {"b2_cleared":not data.get("no_clear",false),"unrelated":true}
		data["sentinel"] = {"keep":[1,"untouched"]}
		data["skill_points"] = 13
		SaveSystem.save_data(data)
		var saved := bytes()
		GameManager.reset()
		GameManager.load_game()
		check(GameManager.checkpoint_stage == data.stage and GameManager.checkpoint_id == data.checkpoint, "unsupported pair identity retained " + data.name)
		check(GameManager.has_checkpoint_conflict(), "unsupported B3/unknown reference held " + data.name)
		var before := registrations
		get_tree().change_scene_to_file(FULL)
		await get_tree().scene_changed
		bind_stage()
		await ticks(5)
		check(registrations == before and get_tree().current_scene.scene_file_path == FULL, "no successful continuation/fallback registration " + data.name)
		GameManager.save_game()
		GameManager.respawn()
		await ticks(5)
		check(bytes() == saved and registrations == before and not GameManager.is_changing(), "unsupported save/death leaves disk and scene unchanged " + data.name)
		check(GameManager.skill_points == 13 and GameManager.flags.get("unrelated",false), "unsupported payload remains loaded " + data.name)
		if data.name == "old-path":
			# Explicit scene entry is allowed for testing; it must not silently stamp old progress.
			get_tree().change_scene_to_file(B3)
			await get_tree().scene_changed
			bind_stage()
			var point: Node3D = stage.get_node("B3/Checkpoint_b3")
			await setup(point.global_position + Vector3(0,0.2,1.1))
			await tap(KEY_F)
			check(bytes() == saved and not GameManager.has_supported_b3_checkpoint() and not point.get_node("ActivationFeedback").visible, "F does not migrate unsupported old B3")
	for reference: String in [B3,"uid://d12u1s460ag67"]:
		var data := {"stage":reference,"checkpoint":"b3_start","basement_checkpoint_contract":"explicit_b3_v1","flags":{"b2_cleared":true},"skill_points":13,"arbitrary_saved_rank":999}
		SaveSystem.save_data(data)
		var saved := bytes()
		GameManager.reset()
		GameManager.load_game()
		check(GameManager.has_supported_b3_checkpoint() and not GameManager.has_checkpoint_conflict() and GameManager.checkpoint_stage == B3, "new marked B3 path/UID accepted " + reference)
		check(GameManager.basement_checkpoint_rank("b3_start") == 3, "rank comes from definition, not saved rank")
		var before := registrations
		get_tree().change_scene_to_file(FULL)
		await get_tree().scene_changed
		await wait_transition(before,B3)
		await supported("new-b3-compat",stage.get_node("B3/Checkpoint_b3/Spawn"),"B3/World/Floor")
		check(bytes() == saved and GameManager.skill_points == 13, "marked B3 startup preserves disk bytes/SP")
	print("B3_COMPATIBILITY_RESULT checks=",checks," failures=",failures)
	get_tree().quit(1 if failures else 0)
