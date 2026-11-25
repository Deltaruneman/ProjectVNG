class_name CameraRig
extends Node3D
## Three camera views with shared collision-safe follow. Stage retains the target / Camera3D / snap_to_target contract.
## Physics sweeps include the lens volume, not only a ray through the camera center.

enum ViewMode { TOP_DOWN, TPS, FPS }
const VIEW_OVERLAY = preload("res://scenes/camera/camera_view_overlay.gd")
const FPS_WEAPON = preload("res://scenes/camera/first_person_weapon.gd")
@export var view_mode: ViewMode = ViewMode.TPS
@export var top_down_pitch_degrees := 60.0
@export var top_down_yaw_degrees := 0.0
@export var top_down_distance := 12.0
@export var eye_height := 1.35

@export var target: Node3D
@export var focus_offset := Vector3(0.0, 1.3, 0.0)
@export_range(2.0, 20.0, 0.1) var orbit_distance := 5.5
@export_range(1.0, 10.0, 0.1) var min_zoom := 3.0
@export_range(3.0, 30.0, 0.1) var max_zoom := 14.0
@export var camera_fov := 60.0
@export_range(-80.0, 0.0) var min_pitch_degrees := -30.0
@export_range(0.0, 85.0) var max_pitch_degrees := 70.0
@export var initial_pitch_degrees := 10.0
@export var tps_focus_height := 1.7
@export_range(0.01, 1.0, 0.01) var mouse_sensitivity := 0.12
@export var invert_y := false
@export_range(0.05, 1.0, 0.01) var collision_radius := 0.24
@export_flags_3d_physics var collision_mask := 1
@export_range(0.0, 1.0, 0.01) var collision_padding := 0.06
@export_range(0.1, 30.0, 0.1) var recovery_speed := 4.0
@export_range(0.1, 30.0, 0.1) var vertical_follow_speed := 10.0
@export_range(0.0, 2.0, 0.05) var max_vertical_lag := 0.4
@export var teleport_snap_distance := 6.0
@export_range(2.0, 12.0, 0.1) var aim_distance := 5.8
@export_range(0.0, 3.0, 0.1) var aim_shoulder_offset := 2.0
@export_range(1.0, 30.0, 0.1) var aim_transition_speed := 12.0

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

func set_view_mode(mode: ViewMode) -> void:
	if mode == view_mode:
		return
	_saved_pitches[view_mode] = pitch
	_saved_yaws[view_mode] = yaw
	_restore_target_visibility()
	_restore_first_person_visibility()
	_release_mouse()
	view_mode = mode
	var preferences := get_node_or_null("/root/GameSettings")
	if preferences != null:
		preferences.set_camera_view_mode(int(mode))
	camera.near = 0.05
	_aim_pointer_valid = false
	var default_pitch := top_down_pitch_degrees if mode == ViewMode.TOP_DOWN else (initial_pitch_degrees if mode == ViewMode.TPS else 0.0)
	pitch = float(_saved_pitches.get(mode, deg_to_rad(default_pitch)))
	yaw = float(_saved_yaws.get(mode, yaw))
	_apply_fixed_view()
	_cursor_released = false
	aim_blend = 0.0
	snap_to_target()

func is_first_person() -> bool:
	return view_mode == ViewMode.FPS

func get_aim_screen_point() -> Vector2:
	var size := get_viewport().get_visible_rect().size
	if view_mode == ViewMode.TOP_DOWN:
		return _aim_pointer if _aim_pointer_valid else get_viewport().get_mouse_position()
	return size * (Vector2(0.5, 0.5) if is_first_person() else Vector2(0.5, 0.42))

func top_down_aim_point() -> Vector3:
	var point := get_aim_screen_point()
	var origin := camera.project_ray_origin(point)
	var ray := camera.project_ray_normal(point)
	var plane := Plane(Vector3.UP, target.global_position.y + 0.65)
	var hit: Variant = plane.intersects_ray(origin, ray)
	return hit if hit is Vector3 else target.global_position - Vector3(sin(yaw), 0.0, cos(yaw)) * 5.0

func facing_vector() -> Vector3:
	if view_mode == ViewMode.TOP_DOWN:
		var direction := top_down_aim_point() - target.global_position
		direction.y = 0.0
		return direction.normalized()
	return -Vector3(sin(yaw), 0.0, cos(yaw))

func _focus_offset() -> Vector3:
	if is_first_person():
		return Vector3(0.0, eye_height, 0.0)
	return Vector3(0.0, tps_focus_height, 0.0) if view_mode == ViewMode.TPS else focus_offset

func _apply_fixed_view() -> void:
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_OFF if view_mode == ViewMode.TOP_DOWN else Node.PHYSICS_INTERPOLATION_MODE_ON
	if view_mode == ViewMode.TOP_DOWN:
		yaw = deg_to_rad(top_down_yaw_degrees)
		pitch = deg_to_rad(top_down_pitch_degrees)

func _restore_first_person_visibility() -> void:
	# Cache keys can outlive queued-free sprites; validate before any typed assignment.
	for visual in _fps_visuals:
		if is_instance_valid(visual):
			visual.layers = _fps_visuals[visual]
	_fps_visuals.clear()
	_fps_target = null

func _hide_first_person_visuals() -> void:
	if target != _fps_target:
		_restore_first_person_visibility()
		_fps_target = target
	# Include dynamically created main/offhand sprites without changing their animation visibility.
	for node in target.find_children("*", "GeometryInstance3D", true, false):
		var visual := node as GeometryInstance3D
		if not _fps_visuals.has(visual):
			_fps_visuals[visual] = visual.layers
		visual.layers = 0


func set_aim_mode(enabled: bool) -> void:
	_aim_requested = enabled

func _ready() -> void:
	# Always process cursor cleanup, but never move the camera during a paused cutscene.
	var preferences := get_node_or_null("/root/GameSettings")
	if preferences != null:
		view_mode = clampi(preferences.camera_view_mode, 0, 2) as ViewMode
	process_mode = Node.PROCESS_MODE_ALWAYS
	process_physics_priority = 100
	process_priority = 100
	physics_interpolation_mode = Node.PHYSICS_INTERPOLATION_MODE_ON
	pitch = deg_to_rad(top_down_pitch_degrees if view_mode == ViewMode.TOP_DOWN else (0.0 if is_first_person() else clampf(initial_pitch_degrees, min_pitch_degrees, max_pitch_degrees)))
	_apply_fixed_view()
	orbit_distance = clampf(orbit_distance, min_zoom, max_zoom)
	camera.fov = camera_fov
	camera.near = 0.05
	_query.shape = _shape
	_query.collide_with_areas = false
	var weapon_layer := CanvasLayer.new()
	weapon_layer.layer = 0 # World weapon view behind the existing HUD.
	add_child(weapon_layer)
	_fps_weapon = FPS_WEAPON.new()
	_fps_weapon.rig = self
	weapon_layer.add_child(_fps_weapon)
	var layer := CanvasLayer.new()
	layer.layer = 24
	add_child(layer)
	_overlay = VIEW_OVERLAY.new()
	_overlay.rig = self
	layer.add_child(_overlay)
	_previous_mouse_mode = Input.mouse_mode
	_focused = get_window().has_focus()
	snap_to_target()
	var settings := get_node_or_null("/root/GameSettings")
	if settings != null:
		_apply_user_settings()
		settings.changed.connect(_apply_user_settings)

func _apply_user_settings() -> void:
	get_node("/root/GameSettings").apply_camera(self)

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		_focused = false
		_release_mouse()
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_focused = true
	elif what == NOTIFICATION_PAUSED:
		_release_mouse()

func _exit_tree() -> void:
	_release_mouse()
	_restore_first_person_visibility()
	_restore_target_visibility()
	_restore_foreground_visibility()

func _can_control() -> bool:
	return is_instance_valid(target) and not get_tree().paused and camera.is_current() \
		and (not target.has_method("can_control_camera") or target.call("can_control_camera"))

func _process(_delta: float) -> void:
	# Embedded Game can focus its child window without APPLICATION_FOCUS_IN.
	# Query the window instead of leaving a startup focus-out latched forever.
	_focused = get_window().has_focus()
	if view_mode == ViewMode.TOP_DOWN and not get_tree().paused and is_instance_valid(target) and camera.is_current():
		# Match the Player's render transform, rather than interpolating the camera twice.
		global_position = target.get_global_transform_interpolated().origin + _focus_offset()
		_place_camera()
	_restore_foreground_visibility()
	if _can_control():
		_update_foreground_visibility()
	else:
		_restore_target_visibility()
		_restore_first_person_visibility()
	if view_mode == ViewMode.TOP_DOWN:
		_release_mouse()
		if _focused and (_can_control() or get_tree().paused):
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		return
	if not _can_control() or not _focused or _cursor_released or Input.is_key_pressed(KEY_ALT):
		_release_mouse()
		if get_tree().paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	elif not _owns_mouse or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		if not _owns_mouse:
			_previous_mouse_mode = Input.mouse_mode if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_VISIBLE
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		_owns_mouse = true

func _release_mouse() -> void:
	if _owns_mouse:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = _previous_mouse_mode
		_owns_mouse = false

func _input(event: InputEvent) -> void:
	if view_mode == ViewMode.TOP_DOWN and event is InputEventMouseMotion:
		_aim_pointer = event.position
		_aim_pointer_valid = true
	# Captured look belongs to gameplay even when the pointer overlaps HUD Controls.
	# Released cursor clicks and Escape still go through GUI before unhandled input.
	if not _can_control() or not _focused or _cursor_released or Input.is_key_pressed(KEY_ALT):
		return
	if view_mode == ViewMode.TOP_DOWN:
		return
	if event is InputEventMouseMotion and _owns_mouse and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw = wrapf(yaw - deg_to_rad(event.screen_relative.x * mouse_sensitivity), -PI, PI)
		var sign_y := -1.0 if invert_y else 1.0
		var lower := -85.0 if is_first_person() else min_pitch_degrees
		var upper := 85.0 if is_first_person() else max_pitch_degrees
		pitch = clampf(pitch + deg_to_rad(event.screen_relative.y * mouse_sensitivity * sign_y), deg_to_rad(lower), deg_to_rad(upper))
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if not _can_control() or not _focused:
		return
	if event is InputEventKey and event.pressed and not event.echo and (event.keycode == KEY_F2 or event.physical_keycode == KEY_F2):
		set_view_mode((int(view_mode) + 1) % ViewMode.size() as ViewMode)
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if has_node("/root/PauseMenu"):
			return # Global menu owns Escape; Alt still releases the gameplay cursor.
		_cursor_released = true
		_release_mouse()
		get_viewport().set_input_as_handled()
		return
	if Input.is_key_pressed(KEY_ALT):
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT and _cursor_released:
			_cursor_released = false
			get_viewport().set_input_as_handled()
		elif event.button_index in [MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN]:
			var step := -0.75 if event.button_index == MOUSE_BUTTON_WHEEL_UP else 0.75
			if view_mode == ViewMode.TOP_DOWN:
				top_down_distance = clampf(top_down_distance + step, min_zoom, max_zoom)
			elif view_mode == ViewMode.TPS and _owns_mouse:
				orbit_distance = clampf(orbit_distance + step, min_zoom, max_zoom)
			else:
				return
			get_viewport().set_input_as_handled()

## Positive input Y means backward, matching Input.get_vector's down action.
func movement_vector(input: Vector2) -> Vector3:
	return Vector3(input.x, 0.0, input.y).rotated(Vector3.UP, yaw)

func snap_to_target() -> void:
	if not is_instance_valid(target):
		return
	global_position = target.global_position + _focus_offset()
	_last_target_position = target.global_position
	_initialized = true
	_snap_pending = true
	# No physics query outside a physics tick (Stage calls this during startup).
	current_distance = top_down_distance if view_mode == ViewMode.TOP_DOWN else 0.0
	_place_camera()
	reset_physics_interpolation()

func _physics_process(delta: float) -> void:
	if get_tree().paused or not is_instance_valid(target) or not camera.is_current():
		return
	_apply_fixed_view()
	var shoulder_aim := _aim_requested and view_mode == ViewMode.TPS
	aim_blend = lerpf(aim_blend, 1.0 if shoulder_aim else 0.0,
		1.0 - exp(-aim_transition_speed * delta))
	if absf(aim_blend - (1.0 if shoulder_aim else 0.0)) < 0.001:
		aim_blend = 1.0 if shoulder_aim else 0.0
	if not _initialized or target.global_position.distance_to(_last_target_position) > teleport_snap_distance:
		snap_to_target()
	_last_target_position = target.global_position
	_query.collision_mask = collision_mask
	_query.exclude = [target.get_rid()] if target is CollisionObject3D else []
	# The sphere encloses the near-plane corners even at wide viewport ratios.
	var aspect := get_viewport().get_visible_rect().size.aspect()
	var sweep_near := 0.05 if view_mode == ViewMode.TOP_DOWN else camera.near
	var half_height := sweep_near * tan(deg_to_rad(camera.fov * 0.5))
	_shape.radius = maxf(collision_radius, Vector2(half_height * aspect, half_height).length())
	var anchor := target.global_position + _focus_offset()
	var desired_focus := anchor
	if not _snap_pending and view_mode == ViewMode.TPS:
		desired_focus.y = clampf(lerpf(global_position.y, anchor.y, 1.0 - exp(-vertical_follow_speed * delta)),
			anchor.y - max_vertical_lag, anchor.y + max_vertical_lag)
	# XZ follow is exact: a lagging pivot must never end up on the other side of a wall.
	global_position = anchor + (desired_focus - anchor) * _safe_fraction(anchor, desired_focus - anchor)
	var boom := _boom_direction()
	var desired_distance := lerpf(orbit_distance, minf(orbit_distance, aim_distance), aim_blend)
	if view_mode == ViewMode.TOP_DOWN:
		desired_distance = top_down_distance
	elif is_first_person():
		desired_distance = 0.0
	var safe_distance := maxf(0.0, desired_distance * _safe_fraction(global_position, boom * desired_distance) - collision_padding)
	if view_mode == ViewMode.TOP_DOWN:
		# Fixed overhead framing: cut away foreground geometry instead of pumping the zoom.
		# The physics sweep still measures the clear sightline; only Top-down uses this slice.
		current_distance = top_down_distance
		camera.near = clampf(top_down_distance - safe_distance + collision_padding, 0.05, top_down_distance - 0.3)
		_place_camera()
		_update_target_visibility()
		if _snap_pending:
			reset_physics_interpolation()
		_snap_pending = false
		return
	# Pull in immediately; only recovery is damped. Never enforce min_zoom after collision.
	var contracting := safe_distance < current_distance - 0.001
	if _snap_pending or safe_distance < current_distance:
		current_distance = safe_distance
	else:
		current_distance = lerpf(current_distance, safe_distance, 1.0 - exp(-recovery_speed * delta))
	_place_camera(true)
	_update_target_visibility()
	if _snap_pending or contracting:
		reset_physics_interpolation()
	_snap_pending = false

func _safe_fraction(origin: Vector3, motion: Vector3) -> float:
	_query.transform = Transform3D(Basis.IDENTITY, origin)
	_query.motion = Vector3.ZERO
	var space := get_world_3d().direct_space_state
	# cast_motion ignores initial overlaps; fail closed instead of casting through a wall.
	if not space.intersect_shape(_query, 1).is_empty():
		return 0.0
	if motion.length_squared() < 0.000001:
		return 1.0
	_query.motion = motion
	return space.cast_motion(_query)[0]

func _boom_direction() -> Vector3:
	return Vector3(sin(yaw) * cos(pitch), sin(pitch), cos(yaw) * cos(pitch))

func _place_camera(check_shoulder_collision: bool = false) -> void:
	var boom := _boom_direction()
	var right := Vector3(cos(yaw), 0.0, -sin(yaw))
	var shoulder_scale := minf(1.0, current_distance / maxf(aim_distance, 0.01))
	var camera_motion := boom * current_distance + right * aim_shoulder_offset * aim_blend * shoulder_scale
	if check_shoulder_collision and aim_blend > 0.001:
		camera_motion *= _safe_fraction(global_position, camera_motion)
	camera.global_position = global_position + camera_motion
	# A direction basis stays valid even if an obstruction collapses the boom to zero.
	camera.global_basis = Basis.looking_at(-boom)

func _restore_target_visibility() -> void:
	for instance in _faded_sprites:
		if is_instance_valid(instance):
			instance.modulate.a = _faded_sprites[instance].alpha
			instance.alpha_cut = _faded_sprites[instance].alpha_cut
	_faded_sprites.clear()
	_fade_target = null

func _update_target_visibility() -> void:
	if is_first_person():
		_restore_target_visibility()
		_hide_first_person_visuals()
		return
	_restore_first_person_visibility()
	if target != _fade_target:
		_restore_target_visibility()
		_fade_target = target
		# Sprite alpha works on Compatibility; GeometryInstance transparency does not.
		for path in ["Sprite3D", "Direction/Blade/Sprite3D"]:
			var instance := target.get_node_or_null(path) as Sprite3D
			if instance != null:
				_faded_sprites[instance] = {"alpha": instance.modulate.a, "alpha_cut": instance.alpha_cut}
	for instance in _faded_sprites:
		if not is_instance_valid(instance):
			continue
		# The sword projects behind the pivot; include its actual camera distance.
		var distance := minf(current_distance, camera.global_position.distance_to(instance.global_position))
		var opacity := smoothstep(1.0, 3.2, distance)
		instance.modulate.a = float(_faded_sprites[instance].alpha) * opacity
		instance.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED if opacity < 0.999 else _faded_sprites[instance].alpha_cut
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
		# In FPS a nearby billboard fills most of the view even several metres away.
		var fade_start := 5.0 if is_first_person() else 1.0
		var fade_end := 7.5 if is_first_person() else 3.2
		if depth < -0.2 or depth >= fade_end or Vector2(view_position.x, view_position.y).length() > 2.5:
			continue
		_foreground_sprites[marker] = {"alpha": marker.modulate.a, "alpha_cut": marker.alpha_cut}
		marker.modulate.a *= smoothstep(fade_start, fade_end, depth)
		marker.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
