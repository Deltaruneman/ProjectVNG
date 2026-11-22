extends Control
## Passive FPS reticle. View mode and F2 banner intentionally hidden.
var rig: Node3D

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(_delta: float) -> void:
	visible = is_instance_valid(rig) and rig._can_control() and rig.is_first_person()
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(rig) or not rig.is_first_person():
		return
	var ui_scale := maxf(0.1, minf(size.x / 1280.0, size.y / 720.0))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE * ui_scale)
	var point: Vector2 = rig.get_aim_screen_point() / ui_scale
	draw_circle(point, 3.0, Color(0.05, 0.07, 0.09, 0.8))
	draw_circle(point, 1.5, Color(0.95, 0.95, 0.85))
