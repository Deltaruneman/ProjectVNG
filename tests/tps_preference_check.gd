extends "res://tests/weapon_combo_check.gd"
var rig: CameraRig

func _ready() -> void:
	if not ("ArcanaInventory" in OS.get_user_data_dir() or "ArcanaCameraDefaults-" in OS.get_user_data_dir()):
		get_tree().quit(2)
		return
	SaveSystem.save_path = "user://tps-fixture-save.json"
	GameManager.reset()
	GameSettings.settings_path = "user://tps-fixture-settings.cfg"
	GameSettings.settings_path = "user://tps-missing-settings.cfg"
	GameSettings.load_settings()
	check(GameSettings.camera_view_mode == CameraRig.ViewMode.TPS, "missing settings default to TPS")
	GameSettings.settings_path = "user://tps-fixture-settings.cfg"
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("35445a")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color.WHITE
	add_child(env)
	_obstacle(Vector3(0,-0.12,0), Vector3(40,0.2,40))
	await fresh("starter_blade")
	rig = preload("res://scenes/camera/camera_rig.tscn").instantiate()
	rig.target = player
	add_child(rig)
	rig.set_process_input(false) # Native cursor recenter events must not perturb synthetic look tests.
	check(rig.view_mode == CameraRig.ViewMode.TPS, "fresh actual rig starts TPS")
	rig.set_view_mode(CameraRig.ViewMode.TPS)
	await frames(8)
	check(rig.orbit_distance == 5.5 and is_equal_approx(rad_to_deg(rig.pitch), 10.0), "closer low-pitch TPS framing")
	for angle in [0.0, PI * 0.5, -PI * 0.5]:
		rig.yaw = angle
		for action in ["up", "down", "left", "right"]:
			Input.action_press(action)
			await frames(5)
			Input.action_release(action)
			check(player.forward().dot(rig.facing_vector()) > 0.99, "rear-facing TPS " + action + " yaw " + str(angle))
		await frames(2)
		check(player._view_direction() == "up", "body presents its back after mouse yaw")
		var weapon := player.get_node("Direction/Blade") as Node3D
		check((weapon.global_position - player.global_position).dot(player.forward()) < 0.0, "resting weapon stays behind Player")
	check(not rig._overlay.visible, "no TPS view banner")
	rig.yaw = 0.0
	player.global_position = Vector3.ZERO
	rig.snap_to_target()
	await frames(8)
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://tps-preference-preview.png")
	var wall := _obstacle(Vector3(0,2,2.5), Vector3(4,4,0.2))
	await frames(8)
	check(rig.current_distance < 2.5, "rear TPS camera retracts before wall")
	wall.queue_free()
	await frames(3)
	for mode in [CameraRig.ViewMode.TPS, CameraRig.ViewMode.FPS, CameraRig.ViewMode.TOP_DOWN]:
		rig.set_view_mode(mode)
		check(GameSettings.camera_view_mode == mode, "view preference updated " + str(mode))
		check(GameSettings.save_settings() == OK, "view preference written " + str(mode))
		GameSettings.camera_view_mode = -1
		GameSettings.load_settings()
		check(GameSettings.camera_view_mode == mode, "view preference reload " + str(mode))
		rig.queue_free()
		await frames(2)
		rig = preload("res://scenes/camera/camera_rig.tscn").instantiate()
		rig.target = player
		add_child(rig)
		rig.set_process_input(false) # Native cursor recenter events must not perturb synthetic look tests.
		await frames(3)
		check(rig.view_mode == mode, "replacement rig retains mode " + str(mode))
	rig.set_view_mode(CameraRig.ViewMode.TPS)
	GameManager.reset()
	rig.queue_free()
	await frames(2)
	rig = preload("res://scenes/camera/camera_rig.tscn").instantiate()
	rig.target = player
	add_child(rig)
	rig.set_process_input(false) # Native cursor recenter events must not perturb synthetic look tests.
	await frames(3)
	check(rig.view_mode == CameraRig.ViewMode.TPS, "progress reset does not reset camera preference")
	for mode in [CameraRig.ViewMode.FPS, CameraRig.ViewMode.TOP_DOWN, CameraRig.ViewMode.TPS]:
		rig._focused = true
		var event := InputEventKey.new()
		event.keycode = KEY_F2
		event.pressed = true
		rig._unhandled_input(event)
		await frames(2)
		check(rig.view_mode == mode and GameSettings.camera_view_mode == mode, "F2 cycles and remembers mode " + str(mode))
		check(rig._overlay.visible == (mode == CameraRig.ViewMode.FPS), "banner absent with only FPS reticle " + str(mode))
	var invalid := ConfigFile.new()
	invalid.set_value("meta", "version", 1)
	invalid.set_value("camera", "view_mode", 99)
	invalid.save(GameSettings.settings_path)
	GameSettings.load_settings()
	check(GameSettings.camera_view_mode == CameraRig.ViewMode.TPS, "invalid view setting defaults to TPS")
	await _top_down_wheel()
	print("TPS_RESULT ", checks-failures, "/", checks)
	get_tree().quit(0 if failures == 0 else 1)

func _obstacle(at: Vector3, size: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	body.add_child(collider)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = size
	mesh.mesh = box
	body.add_child(mesh)
	body.position = at
	add_child(body)
	return body

func _wheel(button: MouseButton) -> void:
	rig._focused = true
	var event := InputEventMouseButton.new()
	event.button_index = button
	event.pressed = true
	get_viewport().push_input(event)

func _top_down_wheel() -> void:
	rig.set_view_mode(CameraRig.ViewMode.TOP_DOWN)
	rig.set_process(false)
	await frames(3)
	var distance := rig.top_down_distance
	var basis := rig.camera.global_basis
	var tps_distance := rig.orbit_distance
	_wheel(MOUSE_BUTTON_WHEEL_UP)
	await frames(3)
	check(rig.top_down_distance < distance and is_equal_approx(rig.current_distance,rig.top_down_distance), "real wheel up moves Top-down closer")
	check(rig.camera.global_basis.is_equal_approx(basis) and rig.orbit_distance == tps_distance, "Top-down wheel preserves angle and independent TPS zoom")
	_wheel(MOUSE_BUTTON_WHEEL_DOWN)
	await frames(3)
	check(is_equal_approx(rig.top_down_distance,distance), "real wheel down moves Top-down farther")
	player.start_talk()
	_wheel(MOUSE_BUTTON_WHEEL_UP)
	check(rig.top_down_distance == distance, "dialogue blocks Top-down zoom")
	player.finish_talk()
	get_tree().paused = true
	_wheel(MOUSE_BUTTON_WHEEL_UP)
	check(rig.top_down_distance == distance, "pause blocks Top-down zoom")
	get_tree().paused = false
	var health := player.health
	player.health = 0
	_wheel(MOUSE_BUTTON_WHEEL_UP)
	check(rig.top_down_distance == distance, "dead Player blocks Top-down zoom")
	player.health = health
	for i in 30: _wheel(MOUSE_BUTTON_WHEEL_UP)
	await frames(3)
	check(is_equal_approx(rig.top_down_distance,rig.min_zoom), "Top-down near zoom clamps at minimum")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("user://topdown-near.png")
	for i in 30: _wheel(MOUSE_BUTTON_WHEEL_DOWN)
	await frames(3)
	check(is_equal_approx(rig.top_down_distance,rig.max_zoom), "Top-down far zoom clamps at maximum")
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("user://topdown-far.png")
	var selected := rig.top_down_distance
	rig.set_view_mode(CameraRig.ViewMode.TPS)
	await frames(3)
	check(rig.orbit_distance == tps_distance, "TPS keeps its own zoom after Top-down adjustment")
	rig.set_view_mode(CameraRig.ViewMode.FPS)
	_wheel(MOUSE_BUTTON_WHEEL_UP)
	check(rig.top_down_distance == selected and rig.orbit_distance == tps_distance, "FPS ignores wheel for both stored zooms")
	rig.set_view_mode(CameraRig.ViewMode.TOP_DOWN)
	await frames(3)
	check(rig.top_down_distance == selected and is_equal_approx(rig.current_distance,selected), "return to Top-down retains selected zoom")
