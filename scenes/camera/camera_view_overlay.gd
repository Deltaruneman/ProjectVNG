extends Control
## Passive camera hint and FPS reticle; never consumes HUD clicks.
var rig: Node3D
var _background: StyleBoxFlat

func _ready() -> void:
	_background = _panel()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(_delta: float) -> void:
	visible = is_instance_valid(rig) and rig._can_control()
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(rig):
		return
	# Project renders UI at a small base resolution; keep this hint compact in pixels.
	var ui_scale := maxf(0.1, minf(size.x / 1280.0, size.y / 720.0))
	var logical_size := size / ui_scale
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * ui_scale)
	var names := ["TOP-DOWN", "TPS", "FPS"]
	var hints := ["WASD move | Mouse aim | Fixed view", "WASD move | Mouse look | Wheel zoom", "WASD move / strafe | Mouse look"]
	var font := ThemeDB.fallback_font
	var title: String = "F2  " + names[rig.view_mode]
	var hint: String = hints[rig.view_mode]
	var width := maxf(font.get_string_size(hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 14).x, 220.0) + 24.0
	var x := maxf(8.0, logical_size.x - width - 16.0)
	draw_style_box(_background, Rect2(x, 76.0, width, 55.0))
	draw_string(font, Vector2(x + 12.0, 97.0), title, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color(0.95, 0.86, 0.6))
	draw_string(font, Vector2(x + 12.0, 119.0), hint, HORIZONTAL_ALIGNMENT_LEFT, -1, 14)
	if rig.is_first_person():
		var point: Vector2 = rig.get_aim_screen_point() / ui_scale
		draw_circle(point, 3.0, Color(0.05, 0.07, 0.09, 0.8))
		draw_circle(point, 1.5, Color(0.95, 0.95, 0.85))

func _panel() -> StyleBoxFlat:
	var panel := StyleBoxFlat.new()
	panel.bg_color = Color(0.03, 0.05, 0.07, 0.72)
	panel.set_corner_radius_all(6)
	return panel
