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
	rig.queue_free()
	await ticks()
	check(Input.mouse_mode != Input.MOUSE_MODE_CAPTURED, "removal restores cursor")
	floor_body.queue_free()
	print("RESULT checks=%d failures=%d" % [checks, failures])
	quit(1 if failures else 0)
