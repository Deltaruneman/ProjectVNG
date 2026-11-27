class_name CameraRig
extends Node3D
## Single fixed action camera. Legacy API data/signatures are inert compatibility only.
## Stage retains the target / Camera3D / snap_to_target contract.
## Walls retain normal depth; only walls covering Player fade locally.

enum ViewMode { TOP_DOWN, TPS, FPS }
var view_mode: ViewMode = ViewMode.TOP_DOWN
var top_down_pitch_degrees := 50.0
var top_down_yaw_degrees := -45.0
var top_down_distance := 22.0
var eye_height := 1.35

@export var target: Node3D
var focus_offset := Vector3(0.0, 1.3, 0.0)
var orbit_distance := 5.5
var min_zoom := 3.0
var max_zoom := 14.0
var camera_fov := 35.0
var min_pitch_degrees := -30.0
var max_pitch_degrees := 70.0
var initial_pitch_degrees := 10.0
var tps_focus_height := 1.7
var mouse_sensitivity := 0.12
var invert_y := false
var collision_radius := 0.24
@export_flags_3d_physics var collision_mask := 1
var collision_padding := 0.06
var recovery_speed := 4.0
var vertical_follow_speed := 10.0
var max_vertical_lag := 0.4
var teleport_snap_distance := 6.0
var aim_distance := 5.8
var aim_shoulder_offset := 2.0
var aim_transition_speed := 12.0

@onready var camera: Camera3D = $Camera3D
var yaw := 0.0
var pitch := 0.0
var current_distance := 0.0
var _initialized := false
var _last_target_position := Vector3.ZERO
var _snap_pending := true
var _focused := true
var _cursor_released := false
var _owns_mouse := false
var _previous_mouse_mode := Input.MOUSE_MODE_VISIBLE
var _fade_target: Node3D
var _faded_sprites: Dictionary = {}
var _foreground_sprites: Dictionary = {}
var _shape := SphereShape3D.new()
var _query := PhysicsShapeQueryParameters3D.new()
var _aim_requested := false
var aim_blend := 0.0
var _saved_pitches: Dictionary = {}
var _saved_yaws: Dictionary = {}
var _fps_weapon: Control
var _fps_visuals: Dictionary = {}
var _fps_target: Node3D
var _overlay: Control
var _aim_pointer := Vector2.ZERO
var _aim_pointer_valid := false
var _follow_height := 0.0
var _wall_occlusion: Node

## Compatibility only: old callers cannot revive removed camera implementations.
func set_view_mode(_mode: ViewMode) -> void:
	_apply_fixed_view()
	snap_to_target()

func is_first_person() -> bool:
	return false

func set_aim_mode(_enabled: bool) -> void:
	pass # Aiming never changes the fixed camera.

func get_aim_screen_point() -> Vector2:
	return _aim_pointer if _aim_pointer_valid else get_viewport().get_mouse_position()

func top_down_aim_point() -> Vector3:
	if not is_instance_valid(target):
		return global_position
	var point := get_aim_screen_point()
	var hit: Variant = Plane(Vector3.UP, target.global_position.y + 0.65).intersects_ray(
		camera.project_ray_origin(point), camera.project_ray_normal(point))
	return hit if hit is Vector3 else target.global_position

func facing_vector() -> Vector3:
	return target.forward() if is_instance_valid(target) and target.has_method("forward") else Vector3.FORWARD

func _focus_offset() -> Vector3:
	return focus_offset

func _apply_fixed_view() -> void:
	view_mode = ViewMode.TOP_DOWN
	top_down_pitch_degrees = 50.0
	top_down_yaw_degrees = -45.0
	top_down_distance = 22.0
	yaw = deg_to_rad(top_down_yaw_degrees)
	pitch = deg_to_rad(top_down_pitch_degrees)
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_physics_priority = 100
	process_priority = 100
	_apply_fixed_view()
	camera.fov = 35.0
	camera.near = 0.05
	_query.shape = _shape
	_query.collide_with_areas = false
	_wall_occlusion = preload("res://scenes/camera/wall_occlusion.gd").new()
	_wall_occlusion.rig = self
	add_child(_wall_occlusion)
	snap_to_target()

func _can_control() -> bool:
	return is_instance_valid(target) and not get_tree().paused and camera.is_current() \
		and (not target.has_method("can_control_camera") or target.call("can_control_camera"))

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_aim_pointer = event.position
		_aim_pointer_valid = true

func _unhandled_input(_event: InputEvent) -> void:
	pass # Inputs belong to existing gameplay and menus.

func movement_vector(input: Vector2) -> Vector3:
	return Vector3(input.x, 0.0, input.y).rotated(Vector3.UP, deg_to_rad(-45.0))

func snap_to_target() -> void:
	if not is_instance_valid(target):
		return
	_apply_fixed_view()
	global_position = target.global_position + focus_offset
	_follow_height = global_position.y
	current_distance = top_down_distance
	camera.near = 0.05
	_place_camera()
	reset_physics_interpolation()

func _process(delta: float) -> void:
	if not get_tree().paused and is_instance_valid(target) and camera.is_current():
		var focus := target.get_global_transform_interpolated().origin + focus_offset
		if absf(focus.y - _follow_height) > teleport_snap_distance:
			_follow_height = focus.y
		else:
			_follow_height = lerpf(_follow_height, focus.y, 1.0 - exp(-vertical_follow_speed * delta))
			_follow_height = clampf(_follow_height, focus.y - max_vertical_lag, focus.y + max_vertical_lag)
		global_position = Vector3(focus.x, _follow_height, focus.z)
		_place_camera()
	_restore_foreground_visibility()
	if _can_control():
		_update_foreground_visibility()
	if camera.is_current():
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(_delta: float) -> void:
	if get_tree().paused or not is_instance_valid(target) or not camera.is_current():
		return
	_apply_fixed_view()
	# Keep real wall depth. The presentation helper fades only Player occluders.
	current_distance = top_down_distance
	camera.near = 0.05
	_place_camera()

func _safe_fraction(origin: Vector3, motion: Vector3) -> float:
	_query.transform = Transform3D(Basis.IDENTITY, origin)
	_query.motion = Vector3.ZERO
	var space := get_world_3d().direct_space_state
	if not space.intersect_shape(_query, 1).is_empty():
		return 0.0
	if motion.length_squared() < 0.000001:
		return 1.0
	_query.motion = motion
	return space.cast_motion(_query)[0]

func _boom_direction() -> Vector3:
	return Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch))

func _place_camera(_check_shoulder_collision: bool = false) -> void:
	var boom := _boom_direction()
	camera.global_position = global_position + boom * current_distance
	camera.global_basis = Basis.looking_at(-boom)

func _release_mouse() -> void:
	_owns_mouse = false

func _restore_target_visibility() -> void:
	pass # The fixed view never hides the Player.

func _restore_first_person_visibility() -> void:
	pass # The fixed view never hides equipment or renders an FPS layer.

func _exit_tree() -> void:
	_restore_foreground_visibility()

func _restore_foreground_visibility() -> void:
	for instance in _foreground_sprites:
		if is_instance_valid(instance):
			instance.modulate.a = _foreground_sprites[instance].alpha
			instance.alpha_cut = _foreground_sprites[instance].alpha_cut
	_foreground_sprites.clear()

func _update_foreground_visibility() -> void:
	# Checkpoint markers are non-solid Areas, so collision sweeps intentionally ignore
	# them. Fade only their presentation near the lens; keep interaction/tint intact.
	for point: Node in get_tree().get_nodes_in_group("spawn_points"):
		if not get_parent().is_ancestor_of(point):
			continue
		var marker := point.get_node_or_null("AnimatedSprite3D") as SpriteBase3D
		if marker == null or not marker.is_visible_in_tree():
			continue
		var center := marker.global_transform * marker.get_aabb().get_center()
		var view_position := camera.to_local(center)
		var depth := -view_position.z
		var fade_start := 1.0
		var fade_end := 3.2
		if depth < -0.2 or depth >= fade_end or Vector2(view_position.x, view_position.y).length() > 2.5:
			continue
		_foreground_sprites[marker] = {"alpha": marker.modulate.a, "alpha_cut": marker.alpha_cut}
		marker.modulate.a *= smoothstep(fade_start, fade_end, depth)
		marker.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
