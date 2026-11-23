extends Control
class_name SkillTreeNode

signal activated
signal hover_changed(source: Control, title: String, description: String, color: Color)

const NODE_SIZE := Vector2(108.0, 116.0)
const LARGE_NODE_SIZE := Vector2(132.0, 132.0)

var icon_text := "✦"
var icon_texture: Texture2D = null
var title_text := ""
var detail_title := ""
var description_text := ""
var action_label := "HỌC KỸ NĂNG"
var action_callback: Callable = Callable()
var rank_text := ""
var accent_color := Color("83d9ed")
var available := false
var action_available := false
var purchased := false
var selected := false
var focused := false
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
	focus_entered.connect(queue_redraw)
	focus_exited.connect(queue_redraw)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mouse_event: InputEventMouseButton = event
		if mouse_event.button_index == MOUSE_BUTTON_LEFT and mouse_event.pressed:
			grab_focus()
			activated.emit()
			accept_event()
	elif event is InputEventKey:
		var key_event: InputEventKey = event
		if key_event.pressed and not key_event.echo and (key_event.keycode == KEY_ENTER or key_event.keycode == KEY_SPACE):
			activated.emit()
			accept_event()


func _on_mouse_entered() -> void:
	_hovered = true
	queue_redraw()
	hover_changed.emit(self, detail_title, description_text, accent_color)


func _on_mouse_exited() -> void:
	_hovered = false
	queue_redraw()
	hover_changed.emit(self, "", "", accent_color)


func _draw() -> void:
	var center := Vector2(size.x * 0.5, 51.0 if prominent_icon else 44.0)
	var base_radius := 45.0 if prominent_icon else 38.0
	var radius := base_radius
	var element_ink := Color("795933").lerp(accent_color.darkened(0.5), 0.3)
	var fill := Color("d8c18c")
	var border := Color("aa9165")
	if available:
		fill = Color("ead8a9")
		border = element_ink
	if purchased:
		fill = Color("dcc18a").lerp(accent_color, 0.12)
		border = element_ink
	if selected:
		fill = Color("e9cb86")
		border = Color("795125")
	if _hovered or focused or has_focus():
		fill = fill.lightened(0.08)
		border = Color("624025")
	draw_circle(center, radius, fill)
	draw_arc(center, radius, 0.0, TAU, 64, border, 2.0 if available or purchased else 1.0, true)
	draw_arc(center, radius - 4.0, 0.0, TAU, 64, Color(border, 0.35), 1.0, true)
	if selected or focused or has_focus():
		draw_arc(center, radius + 4.0, 0.0, TAU, 64, border, 1.5, true)
		for index in 4:
			var direction := Vector2.from_angle(float(index) * PI * 0.5)
			draw_line(center + direction * (radius + 2.0), center + direction * (radius + 7.0), border, 2.0, true)
	var font: Font = ThemeDB.fallback_font
	if icon_texture != null:
		var icon_size := Vector2.ONE * (68.0 if prominent_icon else 58.0)
		var tint := Color(1.0, 0.94, 0.8) if available or purchased else Color(0.65, 0.57, 0.44, 0.6)
		draw_texture_rect(icon_texture, Rect2(center - icon_size * 0.5, icon_size), false, tint)
	else:
		var icon_font_size := 24 if prominent_icon else 20
		draw_string(font, Vector2(0.0, center.y + 7.0), icon_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, icon_font_size, element_ink)
	var rank_y := 112.0 if prominent_icon else 96.0
	var title_y := 128.0 if prominent_icon else 112.0
	draw_string(font, Vector2(0.0, rank_y), rank_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 15, Color("79582f"))
	draw_string(font, Vector2(0.0, title_y), title_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, 17, Color("4c3525") if available or purchased else Color("8e7956"))
