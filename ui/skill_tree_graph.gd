extends Control
class_name SkillTreeGraph

var _nodes: Array[Control] = []
var _ratios: Array[Vector2] = []
var _link_starts: Array[Vector2] = []
var _link_ends: Array[Vector2] = []
var _link_colors: Array[Color] = []
var _link_unlocked: Array[bool] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func add_tree_node(node: Control, center_ratio: Vector2) -> void:
	add_child(node)
	_nodes.append(node)
	_ratios.append(center_ratio)
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
	for index in _nodes.size():
		var node: Control = _nodes[index]
		node.scale = Vector2.ONE
		node.position = size * _ratios[index] - node.size * 0.5
	queue_redraw()


func _draw() -> void:
	for index in _link_starts.size():
		var start := size * _link_starts[index]
		var finish := size * _link_ends[index]
		var color := _link_colors[index]
		var glow := color
		glow.a *= 0.22
		draw_line(start, finish, glow, 5.0, true)
		draw_line(start, finish, color.darkened(0.55), 2.0, true)
		if _link_unlocked[index]:
			draw_line(start, finish, color.lightened(0.12), 2.5, true)
