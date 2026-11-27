extends Node2D
## Keeps a 2D pixel effect anchored to its world-space cast/impact point.

var world_position: Vector3
var world_direction: Vector3
var world_half_extent: float
var half_frame_width: float
var view_camera: Camera3D
var visual: Node2D

func _ready() -> void:
	# CameraRig updates late; project after it so effects do not trail a frame.
	process_priority = 200

func configure(camera: Camera3D, at: Vector3, direction: Vector3, half_extent: float, half_width: float, sprite: Node2D) -> void:
	view_camera = camera
	world_position = at
	world_direction = direction
	world_half_extent = half_extent
	half_frame_width = half_width
	visual = sprite
	_update_projection()

func _process(_delta: float) -> void:
	_update_projection()

func _update_projection() -> void:
	if not is_instance_valid(view_camera) or not view_camera.is_current():
		visible = false
		return
	visible = not view_camera.is_position_behind(world_position)
	if not visible:
		return
	var center := view_camera.unproject_position(world_position)
	position = center
	var screen_right := view_camera.unproject_position(world_position + view_camera.global_basis.x * world_half_extent) - center
	scale = Vector2.ONE * maxf(screen_right.length() / half_frame_width, 0.01)
	if world_direction.length_squared() > 0.001 and is_instance_valid(visual):
		var projected := view_camera.unproject_position(world_position + world_direction.normalized()) - center
		if projected.length_squared() > 0.001:
			visual.rotation = projected.angle()
