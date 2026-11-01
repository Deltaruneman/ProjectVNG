extends Control
class_name SkillTreeGraph

var _nodes: Array[Control] = []
var _ratios: Array[Vector2] = []
var _link_starts: Array[Vector2] = []
var _link_ends: Array[Vector2] = []
var _link_colors: Array[Color] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func add_tree_node(node: Control, center_ratio: Vector2) -> void:
	add_child(node)
	_nodes.append(node)
	_ratios.append(center_ratio)
	_layout_nodes()


func add_link(from_ratio: Vector2, to_ratio: Vector2, color: Color) -> void:
	_link_starts.append(from_ratio)
	_link_ends.append(to_ratio)
	_link_colors.append(color)
	queue_redraw()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_layout_nodes()
		queue_redraw()


func _layout_nodes() -> void:
	for index in _nodes.size():
		var node: Control = _nodes[index]
		node.position = Vector2(size.x * _ratios[index].x - node.size.x * 0.5, size.y * _ratios[index].y - node.size.y * 0.5)


func _draw() -> void:
	for index in _link_starts.size():
		var start := Vector2(size.x * _link_starts[index].x, size.y * _link_starts[index].y)
		var finish := Vector2(size.x * _link_ends[index].x, size.y * _link_ends[index].y)
		draw_line(start, finish, _link_colors[index], 2.0, true)
