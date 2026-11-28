extends Node3D
## Rendered actual-Player regression, restricted to disposable user data.
var checks := 0
var failures := 0
var stage: Node3D
var player: Player
var rig: CameraRig

func check(ok: bool, label: String) -> void:
	checks += 1
	failures += 0 if ok else 1
	print("PASS " if ok else "FAIL ", label)

func frames(count: int = 1) -> void:
	for i in count:
		await get_tree().physics_frame
		await get_tree().process_frame
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw

func capture(label: String) -> void:
	if DisplayServer.get_name() != "headless":
		get_viewport().get_texture().get_image().save_png("user://fixed-" + label + ".png")

func tap(code: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		Input.parse_input_event(event)
		await frames(2)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not "ArcanaFixedCamera-20261126" in OS.get_user_data_dir():
		push_error("Refusing camera playtest without isolated user data")
		get_tree().quit(2)
		return
	_run.call_deferred()

func _run() -> void:
	print("ISOLATED_USER_DATA ", OS.get_user_data_dir())
	SaveSystem.save_path = "user://fixed-camera-fixture.json"
	GameManager.reset()
	GameManager.flags["story_possession"] = true
	if OS.get_cmdline_user_args().has("--stages-only"):
		await _stages()
		print("FIXED_STAGE_RESULT ", checks-failures, "/", checks)
		get_tree().quit(1 if failures else 0)
		return
	stage = load("res://levels/level_1/basement_full.tscn").instantiate()
	add_child(stage)
	player = stage.get_node("Player")
	rig = stage.get_node("CameraRig")
	player.invincible = true
	await frames(30)
	check(rig.target == player and rig.camera.is_current(), "actual basement Stage binds Player and current Camera3D")
	check(is_equal_approx(rig.camera.fov, 35.0) and is_zero_approx(rig.yaw), "single straight action view")
	await capture("basement")
	# Real Stage/Player/HUD on an isolated flat platform for repeatable inputs.
	var platform := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(100, 0.2, 100)
	collider.shape = shape
	platform.add_child(collider)
	var floor_mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = shape.size
	floor_mesh.mesh = box
	platform.add_child(floor_mesh)
	platform.position = Vector3(400, 0, 400)
	stage.add_child(platform)
	player.global_position = Vector3(400, 0.2, 400)
	player.velocity = Vector3.ZERO
	rig.snap_to_target()
	await frames(15)
	if OS.get_cmdline_user_args().has("--mouse-only"):
		await _mouse_skill_checks()
		print("MOUSE_SKILL_RESULT ", checks-failures, "/", checks)
		get_tree().quit(1 if failures else 0)
		return
	var basis := rig.camera.global_basis
	var offset := rig.camera.global_position - rig.global_position
	for code: Key in [KEY_F2, KEY_F2]:
		await tap(code)
	var mouse := InputEventMouseMotion.new()
	mouse.position = Vector2(70, 40)
	mouse.screen_relative = Vector2(240, 150)
	Input.parse_input_event(mouse)
	for button in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN, MOUSE_BUTTON_MIDDLE]:
		var event := InputEventMouseButton.new()
		event.button_index = button
		event.pressed = true
		Input.parse_input_event(event)
		event = event.duplicate()
		event.pressed = false
		Input.parse_input_event(event)
	await frames(5)
	check(rig.camera.global_basis.is_equal_approx(basis) and (rig.camera.global_position-rig.global_position).is_equal_approx(offset), "F2, mouse motion, wheel and MMB cannot change the view")
	check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "pointer stays available")
	var max_anchor_error := 0.0
	for action: String in ["up", "right", "down", "left"]:
		var before := player.global_position
		Input.action_press(action)
		for i in 12:
			await frames()
			var center := rig.camera.unproject_position(player.get_global_transform_interpolated().origin + rig.focus_offset)
			max_anchor_error = maxf(max_anchor_error, center.distance_to(get_viewport().get_visible_rect().size * 0.5))
		Input.action_release(action)
		await frames(3)
		var moved := player.global_position - before
		moved.y = 0.0
		check(moved.length() > 0.2 and player.forward().dot(moved.normalized()) > 0.98, "real movement controls facing " + action)
		var facing := player.forward()
		mouse.position = Vector2(420, 220) if action in ["up", "down"] else Vector2(20, 20)
		Input.parse_input_event(mouse)
		await frames(4)
		player._refresh_skill_aim_point()
		check(player.forward().is_equal_approx(facing), "pointer and held aim leave body facing unchanged " + action)
		await capture("facing-" + action)
	check(max_anchor_error < 0.1, "render follow stays anchored while moving")
	print("MAX_ANCHOR_ERROR_PIXELS ", max_anchor_error)
	var before_jump := player.global_position.y
	Input.action_press("jump")
	await frames(3)
	Input.action_release("jump")
	await frames(8)
	check(player.global_position.y > before_jump + 0.1 and rig.camera.global_basis.is_equal_approx(basis), "jump follows vertically without rotating view")
	await frames(90)
	await _mouse_skill_checks()
	await _default_throw_check()
	# All actual equipped weapons keep the idle grip; combat still owns attack/exit.
	var blade := player.get_node("Direction/Blade")
	for kind: String in ["starter_blade", "sword", "axe", "spear", "dagger"]:
		GameManager.equip_item(GameManager.grant_item(kind))
		player._refresh_equipment_art()
		await frames(4)
		var grip: Vector3 = blade.global_position
		check(grip.distance_to(player.global_position) < 1.0 and rig.camera.unproject_position(grip).y > rig.camera.unproject_position(player.global_position + Vector3.UP * 1.3).y, kind + " grip sits at hand instead of behind back")
		await frames(15)
		check(blade.global_position.distance_to(grip) < 0.01, kind + " no idle float or sway")
		await capture("grip-" + kind)
		Input.action_press("attack")
		await frames(3)
		check(player.fsm.current_state == player.fsm.states.attack, kind + " real attack input enters combat")
		Input.action_release("attack")
		await frames(10)
		await capture("attack-" + kind)
		Input.action_press("dash")
		await frames(2)
		Input.action_release("dash")
		await frames(120)
		check(blade.global_position.distance_to(player.global_position) < 1.0, kind + " attack/dash cleanup restores held grip")
	await capture("held")
	# Collidable foreground keeps depth occlusion and fixed framing.
	var wall := StaticBody3D.new()
	var wall_collision := CollisionShape3D.new()
	var wall_shape := BoxShape3D.new()
	wall_shape.size = Vector3(8, 8, 1)
	wall_collision.shape = wall_shape
	wall.add_child(wall_collision)
	wall.position = player.global_position + Vector3(3, 5, 3)
	stage.add_child(wall)
	await frames(5)
	check(is_equal_approx(rig.camera.near, 0.05) and rig.camera.global_basis.is_equal_approx(basis) and (rig.camera.global_position-rig.global_position).is_equal_approx(offset), "foreground walls keep normal clipping and fixed camera framing")
	wall.queue_free()
	await frames(4)
	check(rig.camera.near < 0.2, "normal near plane persists after obstacle removal")
	player.global_position += Vector3(15, 0, 10)
	rig.snap_to_target()
	await frames(4)
	check(rig.global_position.distance_to(player.get_global_transform_interpolated().origin + rig.focus_offset) < 0.01, "checkpoint-style teleport snaps to Player")
	await tap(KEY_ESCAPE)
	check(get_tree().paused and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "actual pause menu owns pause and visible cursor")
	var pause := get_node("/root/PauseMenu")
	pause.open_settings()
	await frames(3)
	check(not GameSettings.values.has("fov") and not GameSettings.values.has("sensitivity") and not GameSettings.values.has("invert_y"), "camera settings removed from preferences")
	await capture("settings")
	pause._cancel_settings()
	pause.close_menu()
	await frames(4)
	check(not get_tree().paused and player.can_control_camera(), "menu closes and gameplay resumes")
	player.start_talk()
	await frames(3)
	check(not player.can_control_camera() and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "dialogue input gate remains intact")
	player.finish_talk()
	await frames(3)
	check(player.can_control_camera() and rig.camera.global_basis.is_equal_approx(basis), "dialogue restores fixed view and controls")
	# Exercise the real story camera from an obstructed gameplay near plane.
	var story = stage.get_node("BasementStory")
	rig.camera.near = 12.0
	story.play_event("b1_clear")
	await frames(3)
	get_node("/root/Dialogic").signal_event.emit("story_ladder")
	await frames(60)
	var ladder_focus: Vector3 = stage.get_node("B1/LadderSpot_B1_B2").global_position + Vector3.UP * 4.0
	check(rig.camera.near < 0.1 and rig.camera.unproject_position(ladder_focus).distance_to(get_viewport().get_visible_rect().size * 0.5) < 2.0, "ladder story shot centers its target with a clear near plane")
	await capture("ladder-story")
	get_node("/root/Dialogic").end_timeline(true)
	await frames(5)
	check(not player.is_talking and player.can_control_camera() and is_equal_approx(rig.camera.fov, 35.0) and rig.camera.global_basis.is_equal_approx(basis), "story restores fixed framing and controls")
	# Legacy config cannot revive modes/FOV; unrelated preferences survive migration.
	GameSettings.settings_path = "user://legacy-camera-settings.cfg"
	var config := ConfigFile.new()
	config.set_value("meta", "version", 1)
	config.set_value("camera", "view_mode", 2)
	config.set_value("settings", "fov", 85.0)
	config.set_value("settings", "sensitivity", 0.4)
	config.set_value("settings", "invert_y", true)
	config.set_value("settings", "sfx", 0.37)
	config.save(GameSettings.settings_path)
	GameSettings.load_settings()
	GameSettings.apply()
	await frames(3)
	check(is_equal_approx(rig.camera.fov, 35.0) and is_equal_approx(GameSettings.values.sfx, 0.37), "legacy camera config ignored while audio value survives")
	check(GameSettings.save_settings() == OK, "migrated settings save")
	config.clear()
	config.load(GameSettings.settings_path)
	check(not config.has_section("camera") and not config.has_section_key("settings", "fov"), "next save removes legacy camera options")
	await _stages()
	print("FIXED_CAMERA_RESULT ", checks-failures, "/", checks)
	get_tree().quit(1 if failures else 0)

func _stages() -> void:
	# Instantiate the authored Stage variants to verify the shared view survives replacement.
	if is_instance_valid(stage):
		stage.queue_free()
		await frames(4)
	for map_name: String in ["basement_full", "basement_b3", "garden", "castle"]:
		GameManager.flags["story_dark_fairy_intro"] = true
		GameManager.flags["b2_split_cleared"] = true # Old flags must not restore retired B2 routing.
		stage = load("res://levels/level_1/" + map_name + ".tscn").instantiate()
		add_child(stage)
		player = stage.get_node("Player")
		rig = stage.get_node("CameraRig")
		player.invincible = true
		await frames(15)
		check(rig.target == player and rig.camera.is_current(), map_name + " replacement Stage keeps camera contract")
		check(is_equal_approx(rig.yaw, -PI/4.0) and is_equal_approx(rig.camera.fov,35.0) and is_equal_approx(rig.current_distance,22.0), map_name + " uses the same fixed view")
		check(is_equal_approx(rig.camera.near, 0.05), map_name + " keeps wall depth without near-plane cutaway")
		if map_name == "basement_b3":
			check(stage.get_node("B3/Door_b3_down").target_stage == "res://levels/level_1/basement_full.tscn", "legacy clear flag keeps B3 return connected to Basementfull")
		elif map_name == "garden":
			check(stage.get_node("Transitions/Door_from_basement").target_stage == "res://levels/level_1/basement_b3.tscn", "Garden retains B3 connection")
		elif map_name == "castle":
			check(stage.get_node("F1/Transitions/Door_from_garden").target_stage == "res://levels/level_1/garden.tscn", "Castle retains Garden connection")
		await capture(map_name)
		stage.queue_free()
		await frames(4)

func _skill_event(pressed: bool) -> void:
	var event := InputEventAction.new()
	event.action = "skill"
	event.pressed = pressed
	Input.parse_input_event(event)
	Input.flush_buffered_events()

func _pointer_at(point: Vector3) -> void:
	var event := InputEventMouseMotion.new()
	event.position = rig.camera.unproject_position(point)
	rig._input(event)

func _mouse_skill_checks() -> void:
	var state = player.fsm.states.skill
	var facings := [Vector2.RIGHT, Vector2.UP, Vector2.LEFT, Vector2.DOWN]
	var forms := ["fire", "ice", "lightning", "wind"]
	for index in forms.size():
		var form: String = forms[index]
		var id := "active_" + form + "_1"
		GameManager.weapon_form = form
		if not GameManager.unlocked_skills.has(id):
			GameManager.unlocked_skills.append(id)
		player.selected_active_slot = 1
		for hold in [false, true]:
			player.fsm.change_state(player.fsm.states.idle)
			await frames(3)
			player._active_skill_cooldowns.clear()
			player.face_movement(rig.movement_vector(Vector2.DOWN))
			var facing := player.forward()
			var point := player.global_position + rig.movement_vector(facings[index]) * 4.0 + Vector3.UP * 0.65
			_pointer_at(point)
			_skill_event(true)
			await frames(22 if hold else 1)
			_pointer_at(point)
			_skill_event(false)
			# A committed cast must not track later pointer movement.
			_pointer_at(player.global_position - rig.movement_vector(facings[index]) * 4.0 + Vector3.UP * 0.65)
			await frames(2)
			var projectile: Node3D = state.active
			var label := form + (" held" if hold else " tap")
			check(is_instance_valid(projectile), label + " spawns through real skill input")
			if is_instance_valid(projectile):
				var expected := (point - projectile.global_position).normalized()
				print("SKILL_TRACE ", label, " wanted=", point, " snapshot=", player._skill_aim_point, " direction=", projectile.direction, " expected=", expected, " pointer=", rig.get_aim_screen_point())
				check(projectile.direction.dot(expected) > 0.99, label + " uses release-time cursor target, never body facing")
				projectile.queue_free()
				state.active = null
			check(player.forward().is_equal_approx(facing), label + " does not turn movement-facing body")
			player.fsm.change_state(player.fsm.states.idle)
			await frames(3)
	GameManager.weapon_form = "wind"
	if not GameManager.unlocked_skills.has("ultimate_wind_1"):
		GameManager.unlocked_skills.append("ultimate_wind_1")
	player.rage = player.MAX_RAGE
	player._ultimate_cooldown_remaining = 0.0
	var point := player.global_position + rig.movement_vector(Vector2.RIGHT) * 4.0 + Vector3.UP * 0.65
	_pointer_at(point)
	check(player._start_ultimate_cinematic("ultimate_wind_1"), "ultimate starts with pointer aim")
	_pointer_at(player.global_position + rig.movement_vector(Vector2.LEFT) * 4.0)
	await frames(160)
	check(not player._ultimate_cinematic_running and player._skill_aim_point.distance_to(point) < 0.03 and player.rage == 0.0, "ultimate preserves pointer target through paused cinematic")
	# Cursor selection wins over proximity to Player, within the existing8m range.
	var near_enemy := load("res://scenes/enemies/crab/crab.tscn").instantiate() as EnemyCharacter
	var pointer_enemy := load("res://scenes/enemies/crab/crab.tscn").instantiate() as EnemyCharacter
	stage.add_child(near_enemy)
	stage.add_child(pointer_enemy)
	near_enemy.set_physics_process(false)
	pointer_enemy.set_physics_process(false)
	var target_axis := rig.movement_vector(Vector2.RIGHT)
	near_enemy.global_position = player.global_position - target_axis * 1.5
	pointer_enemy.global_position = player.global_position + target_axis * 3.0
	player._skill_aim_point = pointer_enemy.global_position
	check(player._find_nearest_wind_ultimate_target() == pointer_enemy, "Wind ultimate chooses the enemy by cursor rather than body/proximity")
	pointer_enemy.global_position = player.global_position + target_axis * 9.0
	player._skill_aim_point = pointer_enemy.global_position
	check(player._find_nearest_wind_ultimate_target() == near_enemy, "Wind mouse selection keeps the existing8m eligibility limit")
	near_enemy.queue_free()
	pointer_enemy.queue_free()
	player._finish_ultimate_presentation()
	player._ultimate_cooldown_remaining = 0.0
	GameManager.weapon_form = ""
	player._active_skill_cooldowns.clear()
	player.clear_skill_cast_aim()
	player.fsm.change_state(player.fsm.states.idle)
	await frames(3)

func _default_throw_check() -> void:
	GameManager.weapon_form = ""
	player.selected_active_slot = 1
	player._active_skill_cooldowns.clear()
	player.face_movement(rig.movement_vector(Vector2.DOWN))
	var facing := player.forward()
	var aim := rig.movement_vector(Vector2.RIGHT)
	var point := player.global_position + aim * 4.0 + Vector3.UP * 0.65
	_pointer_at(point)
	_skill_event(true)
	await frames(1)
	_pointer_at(point)
	_skill_event(false)
	await frames(2)
	var drops := get_tree().get_nodes_in_group("thrown_weapons")
	check(drops.size() == 1, "default skill launches the actual equipped weapon")
	if drops.is_empty():
		return
	var drop = drops[0]
	var original_uid: String = drop.item_uid
	check((drop.target-drop.origin).normalized().dot(aim) > 0.99 and is_equal_approx(drop.origin.distance_to(drop.target),7.0), "default throw uses mouse direction and7m range")
	check(is_equal_approx(drop.target.y, drop.origin.y) and player.forward().is_equal_approx(facing), "default throw is straight and does not rotate the body")
	await frames(70)
	check(drop.landed and absf(drop.global_position.y-0.1) < 0.03, "default weapon falls and plants on the floor")
	await capture("default-weapon-planted")
	player.global_position = drop.global_position
	rig.snap_to_target()
	await frames(3)
	check(drop.pickup() and GameManager.inventory.equipped.main == original_uid, "planted weapon retains UID and can be picked up")
	await frames(3)
	player._active_skill_cooldowns.clear()
