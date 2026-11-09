extends Control
class_name SkillTreeGraph

signal zoom_changed(value: float)

var _nodes: Array[Control] = []
var _ratios: Array[Vector2] = []
var _node_sizes: Array[Vector2] = []
var _link_starts: Array[Vector2] = []
var _link_ends: Array[Vector2] = []
var _link_colors: Array[Color] = []
var _link_unlocked: Array[bool] = []
var _pan := Vector2.ZERO
var layout_offset_ratio := Vector2.ZERO
var _panning := false
var zoom_level := 1.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	clip_contents = false


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.button_index == MOUSE_BUTTON_WHEEL_UP and mouse_button.pressed:
			set_zoom(zoom_level + 0.1)
			accept_event()
		elif mouse_button.button_index == MOUSE_BUTTON_WHEEL_DOWN and mouse_button.pressed:
			set_zoom(zoom_level - 0.1)
			accept_event()
		elif mouse_button.button_index == MOUSE_BUTTON_MIDDLE:
			_panning = mouse_button.pressed
			accept_event()
	elif event is InputEventMouseMotion and _panning:
		var motion := event as InputEventMouseMotion
		_pan += motion.relative / maxf(zoom_level, 0.01)
		_layout_nodes()
		queue_redraw()
		accept_event()


func set_zoom(value: float, reset_pan: bool = false) -> void:
	zoom_level = clampf(value, 0.65, 2.0)
	if reset_pan:
		_pan = Vector2.ZERO
	_layout_nodes()
	queue_redraw()
	zoom_changed.emit(zoom_level)


func add_tree_node(node: Control, center_ratio: Vector2) -> void:
	add_child(node)
	_nodes.append(node)
	_ratios.append(center_ratio)
	_node_sizes.append((node as SkillTreeNode).layout_size)
	_layout_nodes()


func add_link(from_ratio: Vector2, to_ratio: Vector2, color: Color, unlocked: bool = false) -> void:
	_link_starts.append(from_ratio)
	_link_ends.append(to_ratio)
	_link_colors.append(color)
	_link_unlocked.append(unlocked)
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_nodes()
		queue_redraw()


func _layout_nodes() -> void:
	var node_scale := 1.0
	for first_index in _ratios.size():
		var first := _ratios[first_index]
		var first_size := _node_sizes[first_index]
		var edge_gap := Vector2(minf(first.x, 1.0 - first.x) * size.x, minf(first.y, 1.0 - first.y) * size.y) * 2.0
		node_scale = minf(node_scale, (edge_gap.x - 8.0) / first_size.x)
		node_scale = minf(node_scale, (edge_gap.y - 8.0) / first_size.y)
		for second_index in range(first_index + 1, _ratios.size()):
			var gap := (_ratios[second_index] - first).abs() * size
			var pair_size := (first_size + _node_sizes[second_index]) * 0.5
			var horizontal_fit := (gap.x - 8.0) / pair_size.x
			var vertical_fit := (gap.y - 8.0) / pair_size.y
			node_scale = minf(node_scale, maxf(horizontal_fit, vertical_fit))
	node_scale = clampf(node_scale, 0.25, 1.0)
	var displayed_scale := node_scale * zoom_level
	for index in _nodes.size():
		var node: Control = _nodes[index]
		var center := _transform_point(size * _ratios[index])
		node.scale = Vector2.ONE * displayed_scale
		node.position = center - _node_sizes[index] * displayed_scale * 0.5
	queue_redraw()


func _transform_point(point: Vector2) -> Vector2:
	var center := size * 0.5
	return center + (point + _pan - center) * zoom_level + size * layout_offset_ratio


func _draw() -> void:
	for index in _link_starts.size():
		var start := _transform_point(size * _link_starts[index])
		var finish := _transform_point(size * _link_ends[index])
		var color := _link_colors[index]
		var glow := color
		glow.a *= 0.22
		draw_line(start, finish, glow, 5.0 * zoom_level, true)
		draw_line(start, finish, color.darkened(0.55), 2.0 * zoom_level, true)
		if _link_unlocked[index]:
			draw_line(start, finish, color.lightened(0.12), 2.5 * zoom_level, true)
