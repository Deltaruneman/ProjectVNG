extends Control
class_name SkillTreeNode

signal activated

var icon_text := "✦"
var icon_texture: Texture2D = null
var title_text := ""
var rank_text := ""
var accent_color := Color("83d9ed")
var available := false
var purchased := false
var selected := false
var _hovered := false

const NODE_SIZE := Vector2(100.0, 74.0)
const HEX_RADIUS := 22.0


func _ready() -> void:
	custom_minimum_size = NODE_SIZE
	size = NODE_SIZE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_ALL
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _gui_input(event: InputEvent) -> void:
	if not available:
		return
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			activated.emit()
			accept_event()
	elif event is InputEventKey:
		var key_event: InputEventKey = event
		if key_event.pressed and (key_event.keycode == KEY_ENTER or key_event.keycode == KEY_SPACE):
			activated.emit()
			accept_event()


func _on_mouse_entered() -> void:
	_hovered = true
	queue_redraw()


func _on_mouse_exited() -> void:
	_hovered = false
	queue_redraw()


func _draw() -> void:
	var center := Vector2(size.x * 0.5, 25.0)
	var radius := HEX_RADIUS + (2.0 if _hovered and available else 0.0)
	var points := PackedVector2Array([
		center + Vector2(-radius * 0.5, -radius * 0.866),
		center + Vector2(radius * 0.5, -radius * 0.866),
		center + Vector2(radius, 0.0),
		center + Vector2(radius * 0.5, radius * 0.866),
		center + Vector2(-radius * 0.5, radius * 0.866),
		center + Vector2(-radius, 0.0),
	])
	var fill := Color("131e2b")
	var border := Color("526170")
	if available:
		fill = accent_color.darkened(0.62)
		border = accent_color
	if purchased:
		fill = accent_color.darkened(0.35)
		border = accent_color.lightened(0.22)
	if selected:
		fill = accent_color.darkened(0.18)
		border = Color("fff0aa")
	if _hovered and available:
		fill = fill.lightened(0.16)
	var outline := points.duplicate()
	outline.append(points[0])
	draw_colored_polygon(points, fill)
	draw_polyline(outline, border, 2.0 if available or selected else 1.0, true)
	var font: Font = ThemeDB.fallback_font
	if icon_texture != null:
		draw_texture_rect(icon_texture, Rect2(Vector2(center.x - 12.0, center.y - 12.0), Vector2(24.0, 24.0)), false)
	else:
		draw_string(font, Vector2(0.0, center.y + 5.0), icon_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 15, Color("f3f7fc"))
	draw_string(font, Vector2(0.0, 48.0), rank_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 8, Color("f8edc4") if purchased or selected else Color("bdc8d1"))
	draw_string(font, Vector2(0.0, 70.0), title_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 8, Color("f2f4f6") if available or purchased else Color("9ba7b3"))
