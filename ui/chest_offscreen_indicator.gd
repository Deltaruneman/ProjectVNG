extends Control

const CHEST_ICON := preload("res://assets/sprites/object/chest/chest_gold_close_01.png")

var target: Node3D
var active := true
var _edge_position := Vector2.ZERO
var _direction := Vector2.UP


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = 100
	queue_redraw()


func _process(_delta: float) -> void:
	if not active or not is_instance_valid(target):
		visible = false
		return
	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		visible = false
		return
	var point := target.global_position + Vector3.UP * 0.9
	var projected: Vector2 = camera.unproject_position(point)
	var view_size: Vector2 = get_viewport_rect().size
	var center: Vector2 = view_size * 0.5
	var behind := camera.is_position_behind(point)
	var safe_margin: Vector2 = Vector2(52.0, 58.0)
	var safe_rect: Rect2 = Rect2(safe_margin, view_size - safe_margin * 2.0)
	var on_screen := not behind and safe_rect.has_point(projected)
	visible = not on_screen
	if on_screen:
		return
	_direction = projected - center
	if behind:
		_direction = -_direction
	if _direction.length_squared() < 0.001:
		_direction = Vector2.UP
	_direction = _direction.normalized()
	var half_extent: Vector2 = center - safe_margin
	var x_scale: float = half_extent.x / absf(_direction.x) if absf(_direction.x) > 0.001 else INF
	var y_scale: float = half_extent.y / absf(_direction.y) if absf(_direction.y) > 0.001 else INF
	_edge_position = center + _direction * minf(x_scale, y_scale)
	queue_redraw()


func _draw() -> void:
	if not visible:
		return
	var direction := _direction.normalized()
	var side := Vector2(-direction.y, direction.x)
	var icon_rect := Rect2(_edge_position - Vector2(11.0, 11.0), Vector2(22.0, 22.0))
	draw_rect(icon_rect.grow(2.0), Color(0.08, 0.07, 0.08, 0.94), true)
	draw_rect(icon_rect.grow(2.0), Color("ffcf66"), false, 2.0)
	draw_texture_rect(CHEST_ICON, icon_rect, false)
	var tip := _edge_position + direction * 22.0
	var tail := _edge_position + direction * 12.0
	var arrow := PackedVector2Array([
		tip,
		tail + side * 6.0,
		tail - side * 6.0,
	])
	draw_colored_polygon(arrow, Color("ffcf66"))
	var outline := PackedVector2Array(arrow)
	outline.append(arrow[0])
	draw_polyline(outline, Color("241d1b"), 2.0, true)
