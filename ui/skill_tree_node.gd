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

const NODE_SIZE := Vector2(118.0, 78.0)
const NODE_RADIUS := 22.0


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
	var center := Vector2(size.x * 0.5, 23.0)
	var radius := NODE_RADIUS + (2.0 if _hovered and available else 0.0)
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
	var glow := accent_color
	glow.a = 0.10
	draw_circle(center, radius + 4.0, glow if available or purchased or selected else Color.TRANSPARENT)
	draw_circle(center, radius, fill)
	draw_arc(center, radius, 0.0, TAU, 48, border, 2.0 if available or selected else 1.0, true)
	var font: Font = ThemeDB.fallback_font
	if icon_texture != null:
		draw_texture_rect(icon_texture, Rect2(Vector2(center.x - 13.0, center.y - 13.0), Vector2(26.0, 26.0)), false)
	else:
		draw_string(font, Vector2(0.0, center.y + 6.0), icon_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 17, Color("f3f7fc"))
	draw_string(font, Vector2(0.0, 53.0), rank_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 9, Color("f8edc4") if purchased or selected else Color("bdc8d1"))
	draw_string(font, Vector2(0.0, 74.0), title_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 10, Color("f2f4f6") if available or purchased else Color("9ba7b3"))
