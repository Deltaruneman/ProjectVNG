extends SceneTree
## Run with a renderer (not --headless) in a disposable minimal project containing
## this script and camera_rig.gd; mouse capture needs a real window.
## No production autoload or save system is loaded by this fixture.
const Rig = preload("res://camera_rig.gd")
var stage: Node3D
var target: CharacterBody3D
var rig: Node3D
var failures := 0
var checks := 0

func _initialize() -> void:
	_run.call_deferred()

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
	print("PASS " if ok else "FAIL ", label)

func ticks(count: int = 3) -> void:
	for i in count:
		await physics_frame
		await process_frame

func box(at: Vector3, size: Vector3, layer: int = 1) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.collision_layer = layer
	var shape := CollisionShape3D.new()
	var cube := BoxShape3D.new()
	cube.size = size
	shape.shape = cube
	body.add_child(shape)
	var visual := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	body.add_child(visual)
	stage.add_child(body)
	body.position = at
	return body

func _run() -> void:
	stage = Node3D.new()
	root.add_child(stage)
	target = CharacterBody3D.new()
	target.collision_layer = 2
	var capsule := CollisionShape3D.new()
	capsule.shape = CapsuleShape3D.new()
	capsule.position.y = 1.0
	target.add_child(capsule)
	var sprite := Sprite3D.new()
	sprite.name = "Sprite3D"
	target.add_child(sprite)
	stage.add_child(target)
	rig = Rig.new()
	check(rig.view_mode == Rig.ViewMode.TPS, "new rig defaults to TPS")
	rig.view_mode = Rig.ViewMode.TPS
	var camera := Camera3D.new()
	camera.name = "Camera3D"
	rig.add_child(camera)
	rig.target = target
	stage.add_child(rig)
	# No OS mouse capture during unattended physics tests.
	rig.set_process(false)
	rig.pitch = 0.0
	await ticks()
	check(rig.current_distance > 8.8, "unobstructed distance and target exclusion")
	var normal_camera_position: Vector3 = rig.camera.global_position
	rig.set_aim_mode(true)
	await ticks(35)
	check(rig.aim_blend > 0.99 and rig.current_distance < 6.1, "aim camera moves closer without changing saved orbit zoom")
	check((rig.camera.global_position - normal_camera_position).dot(rig.camera.global_basis.x) > 1.2, "aim camera shifts to the right shoulder")
	var target_screen: Vector2 = rig.camera.unproject_position(target.global_position + Vector3.UP)
	check(target_screen.x < root.get_visible_rect().size.x * 0.5 - 40.0, "aim framing moves Player left of center")
	for sample_yaw in [PI / 2.0, PI, -PI / 2.0]:
		rig.yaw = sample_yaw
		rig.pitch = deg_to_rad(35.0)
		await ticks(4)
		target_screen = rig.camera.unproject_position(target.global_position + Vector3.UP)
		check(target_screen.x > 0.0 and target_screen.x < root.get_visible_rect().size.x * 0.5 - 40.0, "aim keeps Player left across yaw %.2f" % sample_yaw)
	rig.yaw = 0.0
	rig.pitch = 0.0
	rig.orbit_distance = 3.0
	await ticks(20)
	target_screen = rig.camera.unproject_position(target.global_position + Vector3.UP)
	check(target_screen.x > 0.0 and target_screen.x < root.get_visible_rect().size.x * 0.5 - 30.0, "minimum zoom keeps aimed Player visible left of center")
	rig.orbit_distance = 9.0
	await ticks(90)
	var shoulder_wall := box(Vector3(1.2, 2.0, 3.0), Vector3(0.1, 5.0, 6.0))
	await ticks(3)
	var lens_query := PhysicsShapeQueryParameters3D.new()
	var lens_sphere := SphereShape3D.new()
	lens_sphere.radius = rig._shape.radius
	lens_query.shape = lens_sphere
	lens_query.collision_mask = 1
	lens_query.transform = Transform3D(Basis.IDENTITY, rig.camera.global_position)
	check(stage.get_world_3d().direct_space_state.intersect_shape(lens_query, 1).is_empty(), "shoulder lens stays outside lateral wall")
	shoulder_wall.queue_free()
	rig.set_aim_mode(false)
	await ticks(90)
	check(rig.aim_blend < 0.001 and rig.camera.global_position.distance_to(normal_camera_position) < 0.15, "release restores normal camera framing")
	for angle in [0.0, PI / 2, PI, -PI / 2]:
		rig.yaw = angle
		check(rig.movement_vector(Vector2.UP).dot(-Vector3(sin(angle), 0, cos(angle))) > 0.999, "forward follows yaw %.2f" % angle)
	rig.yaw = 0.0
	var wall := box(Vector3(0, 2, 3), Vector3(10, 5, 0.1))
	await ticks()
	check(rig.camera.global_position.z < 2.72, "thin wall contracts before surface")
	check(rig.current_distance < rig.min_zoom, "collision may contract below user zoom minimum")
	var blocked_distance: float = rig.current_distance
	wall.queue_free()
	await ticks(1)
	check(rig.current_distance < 8.5, "obstruction recovery does not pop outward")
	await ticks(90)
	check(rig.current_distance > 8.8 and rig.current_distance > blocked_distance, "obstruction recovery reaches desired zoom")
	var floor_body := box(Vector3(0, -0.25, 0), Vector3(40, 0.5, 40))
	rig.pitch = deg_to_rad(-30)
	await ticks()
	check(rig.camera.global_position.y > 0.24, "downward orbit stays above floor")
	var ceiling := box(Vector3(0, 3, 0), Vector3(40, 0.2, 40))
	rig.pitch = deg_to_rad(70)
	await ticks()
	check(rig.camera.global_position.y < 2.66, "upward orbit stays below ceiling")
	ceiling.queue_free()
	rig.pitch = 0.0
	var corner_a := box(Vector3(2, 2, 0), Vector3(0.1, 5, 10))
	var corner_b := box(Vector3(0, 2, 2), Vector3(10, 5, 0.1))
	await ticks()
	for i in 72:
		rig.yaw = float(i) * TAU / 72.0
		await ticks(1)
		var probe := PhysicsShapeQueryParameters3D.new()
		probe.shape = rig._shape
		probe.transform.origin = rig.camera.global_position
		probe.collision_mask = 1
		check(stage.get_world_3d().direct_space_state.intersect_shape(probe, 1).is_empty(), "corner orbit clearance %d" % i)
	corner_a.queue_free()
	corner_b.queue_free()
	rig.yaw = 0.0
	var ignored := box(Vector3(0, 2, 2), Vector3(5, 4, 0.5), 8)
	rig.snap_to_target()
	await ticks()
	check(rig.current_distance > 8.8, "enemy layer does not obstruct camera")
	ignored.queue_free()
	var enclosure := box(Vector3(0, 1.3, 0), Vector3(1, 1, 1))
	await ticks()
	check(rig.current_distance == 0.0 and rig.camera.global_basis.is_finite(), "initial overlap fails closed with valid orientation")
	check(sprite.modulate.a < 0.01, "close camera fades target sprite")
	enclosure.queue_free()
	target.position = Vector3(30, 7, 20)
	await ticks()
	check(rig.global_position.distance_to(target.position + rig.focus_offset) < 0.001, "teleport auto-snaps pivot")
	check(rig.current_distance > 8.8, "teleport recalculates boom immediately")
	check(sprite.modulate.a == 1.0, "target sprite restores after obstruction")
	target.position += Vector3(0, 2, 0)
	await ticks(1)
	check(absf(rig.global_position.y - target.position.y - rig.focus_offset.y) <= rig.max_vertical_lag + 0.001, "jump vertical lag bounded")
	paused = true
	var saved: Transform3D = rig.camera.global_transform
	rig.camera.position += Vector3(2, 1, 0)
	var cinematic: Transform3D = rig.camera.global_transform
	await ticks()
	check(rig.camera.global_transform.is_equal_approx(cinematic), "paused cutscene owns camera transform")
	paused = false
	rig.camera.global_transform = saved
	await ticks()
	check(not rig.camera.global_transform.is_equal_approx(cinematic), "camera resumes after pause")
	# Dispatch motion through the scene input system with explicit capture ownership.
	rig._focused = true
	rig._owns_mouse = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	var motion := InputEventMouseMotion.new()
	motion.screen_relative = Vector2(150, 100000)
	var old_yaw: float = rig.yaw
	root.push_input(motion)
	await process_frame
	check(not is_equal_approx(rig.yaw, old_yaw), "mouse input rotates yaw")
	check(is_equal_approx(rig.pitch, deg_to_rad(rig.max_pitch_degrees)), "mouse pitch upper clamp")
	motion = InputEventMouseMotion.new()
	motion.screen_relative = Vector2(0, -100000)
	root.push_input(motion)
	await process_frame
	check(is_equal_approx(rig.pitch, deg_to_rad(rig.min_pitch_degrees)), "mouse pitch lower clamp")
	for i in 30:
		var wheel := InputEventMouseButton.new()
		wheel.button_index = MOUSE_BUTTON_WHEEL_UP
		wheel.pressed = true
		root.push_input(wheel)
	check(is_equal_approx(rig.orbit_distance, rig.min_zoom), "wheel zoom clamps at minimum")
	for i in 40:
		var wheel := InputEventMouseButton.new()
		wheel.button_index = MOUSE_BUTTON_WHEEL_DOWN
		wheel.pressed = true
		root.push_input(wheel)
	check(is_equal_approx(rig.orbit_distance, rig.max_zoom), "wheel zoom clamps at maximum")
	var marker_point := Node3D.new()
	stage.add_child(marker_point)
	marker_point.add_to_group("spawn_points")
	var marker := Sprite3D.new()
	marker.name = "AnimatedSprite3D"
	marker.modulate.a = 0.7
	marker.alpha_cut = SpriteBase3D.ALPHA_CUT_DISCARD
	marker_point.add_child(marker)
	marker_point.global_position = rig.camera.global_position - rig.camera.global_basis.z * 0.5
	rig._process(0.016)
	check(marker.modulate.a < 0.01, "non-solid checkpoint marker fades near lens")
	marker_point.position += Vector3(30, 0, 0)
	rig._process(0.016)
	check(is_equal_approx(marker.modulate.a, 0.7) and marker.alpha_cut == SpriteBase3D.ALPHA_CUT_DISCARD, "checkpoint marker alpha and cut mode restore")
	marker_point.queue_free()
	var escape := InputEventKey.new()
	escape.keycode = KEY_ESCAPE
	escape.pressed = true
	Input.parse_input_event(escape)
	await process_frame
	check(not rig._owns_mouse and rig._cursor_released, "Escape releases cursor")
	rig._cursor_released = false
	rig._process(0.016)
	check(rig._owns_mouse, "gameplay captures cursor")
	rig._focused = false
	rig._process(0.016)
	check(rig._focused == rig.get_window().has_focus() and rig._owns_mouse, "embedded window focus clears stale application focus")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	rig._process(0.016)
	check(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED, "gameplay recovers external cursor release")
	paused = true
	rig._process(0.016)
	check(not rig._owns_mouse and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED, "pause releases cursor")
	paused = false
	rig._process(0.016)
	rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not rig._owns_mouse, "focus loss releases cursor")
	rig._notification(Node.NOTIFICATION_APPLICATION_FOCUS_IN)
	rig._process(0.016)
	rig.set_view_mode(Rig.ViewMode.TOP_DOWN)
	await ticks()
	check(is_equal_approx(rig.pitch, deg_to_rad(60.0)), "Top-down starts at steep pitch")
	rig._process(0.016)
	check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Top-down releases pointer")
	var orbit_button := InputEventMouseButton.new()
	orbit_button.button_index = MOUSE_BUTTON_MIDDLE
	orbit_button.pressed = true
	root.push_input(orbit_button)
	check(not rig._owns_mouse, "fixed Top-down never captures MMB orbit")
	var drag := InputEventMouseMotion.new()
	drag.screen_relative = Vector2(80, -100000)
	drag.position = Vector2(400, 200)
	var overhead_yaw: float = rig.yaw
	root.push_input(drag)
	check(rig.get_aim_screen_point().is_equal_approx(drag.position), "Top-down input routes pointer position without orbit")
	check(is_equal_approx(overhead_yaw, rig.yaw) and is_equal_approx(rig.pitch, deg_to_rad(60.0)), "Top-down pointer motion leaves angle fixed")
	orbit_button.pressed = false
	root.push_input(orbit_button)
	check(not rig._owns_mouse, "MMB release restores pointer")
	orbit_button.button_index = MOUSE_BUTTON_RIGHT
	orbit_button.pressed = true
	root.push_input(orbit_button)
	check(not rig._owns_mouse, "RMB remains available for parry")
	var overhead_zoom: float = rig.top_down_distance
	orbit_button.button_index = MOUSE_BUTTON_WHEEL_UP
	root.push_input(orbit_button)
	check(rig.top_down_distance < overhead_zoom, "Top-down wheel moves closer")
	await ticks()
	var overhead_offset: Vector3 = rig.camera.global_position - target.global_position
	var max_follow_error := 0.0
	for sample in 24:
		target.position += Vector3(0.12, 0.01, -0.03)
		await ticks(1)
		rig._process(0.016)
		max_follow_error = maxf(max_follow_error, (rig.camera.global_position - target.global_position).distance_to(overhead_offset))
	check(max_follow_error < 0.001, "Top-down render offset stays fixed during horizontal and vertical movement")
	var fixed_basis: Basis = rig.camera.global_basis
	var fixed_distance: float = rig.current_distance
	var obstruction := box(target.global_position + Vector3(0, 3.0, 0), Vector3(20, 0.2, 20))
	await ticks(4)
	check(is_equal_approx(rig.current_distance, fixed_distance) and rig.camera.global_basis.is_equal_approx(fixed_basis), "Top-down obstruction never changes fixed zoom or angle")
	check(rig.camera.near > 0.05, "Top-down cuts away obstructing foreground geometry")
	obstruction.queue_free()
	await ticks(3)
	check(is_equal_approx(rig.current_distance, fixed_distance), "Top-down obstacle removal does not pump camera distance")
	var saved_top_pitch: float = rig.pitch
	var switch_view := InputEventKey.new()
	switch_view.keycode = KEY_F2
	switch_view.pressed = true
	root.push_input(switch_view)
	check(rig.view_mode == Rig.ViewMode.TPS, "F2 Top-down to TPS")
	check(is_equal_approx(rig.camera.near, 0.05), "TPS restores original near plane after fixed Top-down")
	switch_view.echo = true
	root.push_input(switch_view)
	check(rig.view_mode == Rig.ViewMode.TPS, "F2 echo ignored")
	switch_view.echo = false
	root.push_input(switch_view)
	await ticks()
	check(rig.view_mode == Rig.ViewMode.FPS and rig.current_distance == 0.0, "F2 TPS to FPS with no boom")
	check(rig.camera.global_position.distance_to(target.global_position + Vector3.UP * rig.eye_height) < 0.001, "FPS at eye height")
	check(sprite.layers == 0, "FPS hides body without changing animation visibility")
	check(rig.get_aim_screen_point().is_equal_approx(root.get_visible_rect().size * 0.5), "FPS centered aim")
	target.position.y += 0.3
	await ticks(1)
	check(rig.camera.global_position.distance_to(target.global_position + Vector3.UP * rig.eye_height) < 0.001, "FPS jump follow has no lag")
	var fps_zoom: float = rig.orbit_distance
	var scroll := InputEventMouseButton.new()
	scroll.button_index = MOUSE_BUTTON_WHEEL_UP
	scroll.pressed = true
	root.push_input(scroll)
	check(rig.orbit_distance == fps_zoom, "FPS ignores wheel zoom")
	rig.set_aim_mode(true)
	await ticks(30)
	check(rig.aim_blend == 0.0, "FPS does not shift to shoulder")
	var fps_marker_point := Node3D.new()
	stage.add_child(fps_marker_point)
	fps_marker_point.add_to_group("spawn_points")
	var fps_marker := Sprite3D.new()
	fps_marker.name = "AnimatedSprite3D"
	fps_marker.modulate.a = 0.65
	fps_marker_point.add_child(fps_marker)
	fps_marker.global_position = rig.camera.global_position - rig.camera.global_basis.z * 3.5
	rig._process(0.016)
	check(fps_marker.modulate.a < 0.01, "FPS fades nearby checkpoint billboard out of sightline")
	fps_marker.global_position += Vector3(30, 0, 0)
	rig._process(0.016)
	check(is_equal_approx(fps_marker.modulate.a, 0.65), "FPS restores checkpoint opacity away from sightline")
	fps_marker.global_position = rig.camera.global_position - rig.camera.global_basis.z * 3.5
	rig._process(0.016)
	fps_marker_point.queue_free()
	await ticks()
	rig._process(0.016)
	check(rig._foreground_sprites.is_empty(), "freed foreground marker clears without invalid assignment")
	var expired_visual := Sprite3D.new()
	target.add_child(expired_visual)
	await ticks()
	check(rig._fps_visuals.has(expired_visual), "temporary FPS visual is cached before deletion")
	expired_visual.queue_free()
	await ticks()
	paused = true
	rig._process(0.016)
	check(rig._fps_visuals.is_empty() and sprite.layers == 1, "pause skips freed FPS visual and restores surviving body")
	root.push_input(switch_view)
	check(rig.view_mode == Rig.ViewMode.FPS, "paused F2 blocked")
	paused = false
	root.push_input(switch_view)
	await ticks()
	check(rig.view_mode == Rig.ViewMode.TOP_DOWN, "F2 FPS wraps to Top-down")
	check(is_equal_approx(rig.pitch, saved_top_pitch), "mode switch restores Top-down pitch")
	check(sprite.layers == 1 and sprite.modulate.a > 0.99, "body render layers and opacity restored")
	check(rig.aim_blend == 0.0, "Top-down aiming preserves overhead framing")
	rig.set_aim_mode(false)
	var direction_node := Node3D.new()
	direction_node.name = "Direction"
	target.add_child(direction_node)
	var blade_node := Node3D.new()
	blade_node.name = "Blade"
	direction_node.add_child(blade_node)
	var expired_blade := Sprite3D.new()
	expired_blade.name = "Sprite3D"
	blade_node.add_child(expired_blade)
	rig._restore_target_visibility()
	await ticks()
	check(rig._faded_sprites.has(expired_blade), "temporary third-person blade is cached before deletion")
	expired_blade.queue_free()
	await ticks()
	rig._restore_target_visibility()
	check(rig._faded_sprites.is_empty() and sprite.modulate.a == 1.0, "fade update and restoration skip freed blade")
	for cleanup in ["switch", "remove"]:
		rig.set_view_mode(Rig.ViewMode.FPS)
		expired_visual = Sprite3D.new()
		target.add_child(expired_visual)
		await ticks()
		check(rig._fps_visuals.has(expired_visual), "temporary FPS visual cached for " + cleanup)
		expired_visual.queue_free()
		await ticks()
		if cleanup == "switch":
			rig.set_view_mode(Rig.ViewMode.TOP_DOWN)
			check(rig._fps_visuals.is_empty() and sprite.layers == 1, "switch skips freed FPS visual and restores surviving body")
	rig.queue_free()
	await ticks()
	check(Input.mouse_mode != Input.MOUSE_MODE_CAPTURED, "removal restores cursor")
	check(sprite.layers == 1, "removing FPS rig restores body layers")
	floor_body.queue_free()
	print("RESULT checks=%d failures=%d" % [checks, failures])
	quit(1 if failures else 0)
