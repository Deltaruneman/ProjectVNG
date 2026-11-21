extends Node3D
## Rendered actual Player/HUD fixture; only run in isolated ArcanaViews user data.
var rig: CameraRig
var player: Player
var checks := 0
var failures := 0

func check(ok: bool, label: String) -> void:
	checks += 1
	failures += 0 if ok else 1
	print("PASS " if ok else "FAIL ", label)

func ticks(count: int = 3) -> void:
	for i in count:
		await get_tree().physics_frame
		await get_tree().process_frame
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw

func f2(echo: bool = false) -> void:
	rig._focused = true
	var event := InputEventKey.new()
	event.keycode = KEY_F2
	event.physical_keycode = KEY_F2
	event.pressed = true
	event.echo = echo
	get_viewport().push_input(event)

func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	# Run normal late camera presentation after checkpoint marker updates.
	rig.set_process(true)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("user://views-" + label + ".png")
	rig.set_process(false)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not "ArcanaViews-20261119" in OS.get_user_data_dir():
		push_error("Requires isolated ArcanaViews user directory")
		get_tree().quit(2)
		return
	SaveSystem.save_path = "user://camera-views-fixture.json"
	GameManager.reset()
	var stage := preload("res://levels/level_1/basement_full.tscn").instantiate()
	add_child(stage)
	player = stage.get_node("Player")
	rig = stage.get_node("CameraRig")
	player.invincible = true
	await ticks(35)
	check(rig.view_mode == CameraRig.ViewMode.TOP_DOWN, "actual stage defaults to Top-down")
	check(rig.target == player and rig.camera.is_current(), "existing Stage camera contract preserved")
	await capture("basement-topdown")
	# Keep OS focus changes from making synthetic input nondeterministic.
	rig.set_process(false)
	f2()
	await ticks(5)
	check(rig.view_mode == CameraRig.ViewMode.TPS, "actual HUD routes F2 to TPS")
	await capture("basement-tps")
	f2()
	await ticks(5)
	check(rig.is_first_person(), "actual HUD routes F2 to FPS")
	await capture("basement-fps")
	var body := player.get_node("Sprite3D") as Sprite3D
	var blade := player.get_node("Direction/Blade/Sprite3D") as Sprite3D
	check(body.layers == 0 and blade.layers == 0, "FPS hides actual body and equipped weapon")
	var platform := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(60, 1, 60)
	collision.shape = box
	platform.add_child(collision)
	var mesh := MeshInstance3D.new()
	var cube := BoxMesh.new()
	cube.size = box.size
	mesh.mesh = cube
	platform.add_child(mesh)
	stage.add_child(platform)
	platform.global_position = Vector3(1000, 9.5, 1000)
	player.global_position = Vector3(1000, 10.1, 1000)
	player.velocity = Vector3.ZERO
	rig.yaw = PI / 2.0
	rig.snap_to_target()
	await ticks(15)
	check(rig.camera.global_position.distance_to(player.global_position + Vector3.UP * rig.eye_height) < 0.01, "FPS teleport and grounded eye position")
	for action in ["up", "down", "left", "right"]:
		var at := player.global_position
		Input.action_press(action)
		await ticks(15)
		Input.action_release(action)
		var direction := {"up": Vector2.UP, "down": Vector2.DOWN, "left": Vector2.LEFT, "right": Vector2.RIGHT}
		var expected := rig.movement_vector(direction[action])
		check((player.global_position - at).dot(expected) > 0.5, "FPS actual movement " + action)
		check(player.forward().dot(Vector3.LEFT) > 0.99, "FPS facing stays on view during " + action)
		await ticks(3)
	check(player.get_skill_aim_direction().dot(Vector3.LEFT) > 0.99, "FPS quick skill keeps forward direction")
	player._refresh_skill_aim_point()
	var screen := rig.camera.unproject_position(player._skill_aim_point)
	check(screen.distance_to(rig.get_aim_screen_point()) < 1.0, "FPS skill ray matches centered reticle")
	Input.action_press("jump")
	await ticks(3)
	Input.action_release("jump")
	check(rig.camera.global_position.distance_to(player.global_position + Vector3.UP * rig.eye_height) < 0.01, "FPS actual jumping keeps exact eye follow")
	await ticks(70)
	var dynamic_sprite := Sprite3D.new()
	player.add_child(dynamic_sprite)
	dynamic_sprite.layers = 5
	await ticks()
	check(dynamic_sprite.layers == 0, "FPS hides newly spawned Player presentation")
	f2()
	await ticks()
	check(body.layers == 1 and blade.layers == 1 and dynamic_sprite.layers == 5, "exiting FPS restores original render layers")
	# Isolate projection/facing from native OS mouse recenter events after FPS capture.
	rig.set_process_input(false)
	var point := player.global_position + Vector3(4, 0.65, 3)
	var pointer := InputEventMouseMotion.new()
	pointer.position = rig.camera.unproject_position(point)
	rig._input(pointer)
	await ticks()
	check(rig.top_down_aim_point().distance_to(point) < 0.1, "Top-down pointer projects onto Player-height aim plane")
	var toward := Vector3(4, 0, 3).normalized()
	check(player.forward().dot(toward) > 0.99, "Top-down idle faces pointer")
	player._refresh_skill_aim_point()
	check(player._skill_aim_point.distance_to(point) < 0.1, "Top-down held skill uses same pointer target")
	player._cast_aim_point_valid = true
	check(player.get_skill_aim_direction().dot(toward) > 0.99, "Top-down permits aim behind screen center")
	pointer = InputEventMouseMotion.new()
	pointer.position = get_viewport().get_mouse_position() + Vector2(100, 0)
	rig._input(pointer)
	player.get_skill_aim_direction()
	check(player.forward().dot(toward) > 0.99, "released cast keeps snapshot facing after pointer moves")
	player.clear_skill_cast_aim()
	rig.set_process_input(true)
	var saved_mode := rig.view_mode
	player.start_talk()
	f2()
	check(rig.view_mode == saved_mode and not player.can_control_camera(), "dialogue blocks switching")
	player.finish_talk()
	get_node("/root/PauseMenu").open_menu()
	f2()
	rig._process(0.016)
	check(rig.view_mode == saved_mode and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "real pause menu blocks F2 and releases mouse")
	get_node("/root/PauseMenu").close_menu()
	await ticks(5)
	var hp := player.health
	player.health = 0
	f2()
	check(rig.view_mode == saved_mode, "dead Player blocks F2")
	player.health = hp
	f2()
	await ticks()
	check(rig.view_mode == CameraRig.ViewMode.TPS, "gameplay switches again after menu/dialogue")
	rig.yaw = 0.0
	Input.action_press("right")
	await ticks(10)
	Input.action_release("right")
	check(player.forward().dot(Vector3.RIGHT) > 0.99, "TPS retains movement-facing behavior")
	await exercise_fps_weapons()
	print("RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(1 if failures else 0)

func exercise_fps_weapons() -> void:
	rig.set_view_mode(CameraRig.ViewMode.FPS)
	await ticks(4)
	var view: Control = rig._fps_weapon
	for kind: String in ["starter_blade", "sword", "axe", "spear", "dagger"]:
		player.fsm.change_state(player.fsm.states.idle)
		var uid := GameManager.grant_item(kind)
		check(GameManager.equip_item(uid), "equip FPS " + kind)
		await ticks(8)
		var source := player.get_node("Direction/Blade/Sprite3D") as Sprite3D
		check(view.visible and view.weapon.texture == source.texture, "FPS shows equipped art " + kind)
		var rest: Vector2 = view.weapon.position
		await capture("fps-" + kind + "-idle")
		Input.action_press("attack")
		await ticks(3)
		Input.action_release("attack")
		var moved := false
		var actual_hit_window := false
		var captured: Dictionary = {}
		var matched := true
		var legacy_frames: Dictionary = {}
		var state: Node = player.get_node("States/Attack")
		for frame in 125:
			await ticks(1)
			if view.visible:
				moved = moved or view.weapon.position.distance_to(rest) > 6.0
				if view.presentation.get("phase", "") == "strike":
					actual_hit_window = actual_hit_window or state.get("_hit_active")
					var strike := int(view.presentation.strike)
					if kind != "starter_blade":
						matched = matched and view.presentation.grip.is_equal_approx(state.get("_last_grip")) and view.presentation.tip.is_equal_approx(state.get("_last_tip"))
					else:
						var body := player.get_node("Sprite3D") as Sprite3D
						var actual_frame := clampi(int(body.frame / body.hframes) - 11, 0, 3)
						matched = matched and int(view.presentation.legacy_frame) == actual_frame and view.weapon.texture is AtlasTexture
						legacy_frames[actual_frame] = true
					if not captured.has(strike) and float(view.presentation.get("progress", 0.0)) > 0.35:
						await capture("fps-" + kind + "-strike-" + str(strike))
						captured[strike] = true
			if player.fsm.current_state == state and state.get("_phase") == 7:
				Input.action_press("attack")
				await ticks(2)
				Input.action_release("attack")
			if not captured.is_empty() and player.fsm.current_state != state:
				break
		var expected := 4 if kind == "spear" else (1 if kind == "dagger" else 3)
		check(moved and captured.size() == expected, "FPS complete combo motion " + kind)
		check(matched, "FPS matches live combat paths or original Blade frames " + kind)
		if kind == "starter_blade":
			check(legacy_frames.size() == 4, "FPS renders all four original Blade attack frames")
		check(actual_hit_window, "FPS animation accompanies real hit window " + kind)
		check(view.visible, "FPS held weapon restores after attack " + kind)
	# Hold/release exercises charge and interruption without altering hit timing.
	GameManager.equip_item(GameManager.grant_item("sword"))
	player.fsm.change_state(player.fsm.states.idle)
	Input.action_press("attack")
	await ticks(28)
	check(view.presentation.get("phase", "") == "charge", "FPS shows actual held charge")
	Input.action_release("attack")
	await ticks(7)
	check(view.presentation.get("phase", "") == "heavy", "FPS shows actual charged strike")
	await capture("fps-sword-heavy")
	player.fsm.change_state(player.fsm.states.idle)
	await ticks(4)
	check(view.presentation.get("phase", "") == "idle", "FPS interruption returns to held pose")
	GameManager.equip_item(GameManager.grant_item("starter_blade"))
	player.stamina = 100.0
	Input.action_press("attack")
	await ticks(28)
	Input.action_release("attack")
	await ticks(7)
	check(view.presentation.get("phase", "") == "heavy" and view.presentation.has("legacy_frame") and view.weapon.texture is AtlasTexture, "charged legacy Blade also uses original attack frames")
	await capture("fps-starter_blade-heavy")
	player.fsm.change_state(player.fsm.states.idle)
	await ticks(4)
	get_node("/root/PauseMenu").open_menu()
	await ticks(2)
	check(not view.visible, "FPS weapon hidden behind open menu")
	get_node("/root/PauseMenu").close_menu()
	await ticks(3)
	rig.set_view_mode(CameraRig.ViewMode.TOP_DOWN)
	await ticks(6)
	check(not view.visible, "FPS weapon overlay removed in Top-down")
	var screen_origin := rig.camera.unproject_position(player.global_position + rig.focus_offset)
	var screen_error := 0.0
	rig.set_process(true)
	Input.action_press("right")
	for frame in 45:
		await ticks(1)
		screen_error = maxf(screen_error, rig.camera.unproject_position(player.global_position + rig.focus_offset).distance_to(screen_origin))
	Input.action_release("right")
	check(screen_error < 0.25 and is_zero_approx(rig.yaw), "actual Player Top-down follow keeps fixed screen anchor and yaw")
	print("TOP_DOWN_SCREEN_ERROR ", screen_error)
