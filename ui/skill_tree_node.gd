extends Control
class_name SkillTreeNode

signal activated
signal hover_changed(title: String, description: String, color: Color)

const NODE_SIZE := Vector2(128.0, 96.0)
const LARGE_NODE_SIZE := Vector2(148.0, 112.0)

var icon_text := "✦"
var icon_texture: Texture2D = null
var title_text := ""
var description_text := ""
var rank_text := ""
var accent_color := Color("83d9ed")
var available := false
var purchased := false
var selected := false
var prominent_icon := false
var layout_size := NODE_SIZE
var _hovered := false


func _ready() -> void:
	custom_minimum_size = layout_size
	size = layout_size
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
	hover_changed.emit(title_text, description_text, accent_color)


func _on_mouse_exited() -> void:
	_hovered = false
	queue_redraw()
	hover_changed.emit("", "", accent_color)


func _draw() -> void:
	var center := Vector2(size.x * 0.5, 35.0 if prominent_icon else 30.0)
	var base_radius := 40.0 if prominent_icon else 32.0
	var radius := base_radius + (2.0 if _hovered and available else 0.0)
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
	if _hovered:
		fill = fill.lightened(0.12)
		border = border.lightened(0.12)
	var glow := accent_color
	glow.a = 0.10
	draw_circle(center, radius + 4.0, glow if available or purchased or selected else Color.TRANSPARENT)
	draw_circle(center, radius, fill)
	draw_arc(center, radius, 0.0, TAU, 48, border, 2.0 if available or selected else 1.0, true)
	var font: Font = ThemeDB.fallback_font
	if icon_texture != null:
		var icon_size := Vector2.ONE * (60.0 if prominent_icon else 48.0)
		draw_texture_rect(icon_texture, Rect2(center - icon_size * 0.5, icon_size), false)
	else:
		var icon_font_size := 22 if prominent_icon else 18
		draw_string(font, Vector2(0.0, center.y + 7.0), icon_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, icon_font_size, Color("f3f7fc"))
	var rank_y := 84.0 if prominent_icon else 67.0
	var title_y := 107.0 if prominent_icon else 92.0
	draw_string(font, Vector2(0.0, rank_y), rank_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 11, Color("f8edc4") if purchased or selected else Color("bdc8d1"))
	draw_string(font, Vector2(0.0, title_y), title_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 12 if prominent_icon else 11, Color("f2f4f6") if available or purchased else Color("9ba7b3"))
