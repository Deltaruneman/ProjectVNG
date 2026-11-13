extends Control

signal pause_cancel_requested

const RETICLE_COLOR := Color(0.93, 0.96, 0.84, 0.95)
const SHADOW_COLOR := Color(0.07, 0.12, 0.15, 0.75)
const AIM_SCREEN_POSITION := Vector2(0.5, 0.42)


static func aim_screen_point(viewport_size: Vector2) -> Vector2:
	return viewport_size * AIM_SCREEN_POSITION


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	resized.connect(queue_redraw)


func _process(_delta: float) -> void:
	if get_tree().paused and get_parent().visible:
		pause_cancel_requested.emit()


func _draw() -> void:
	var center := aim_screen_point(size)
	draw_arc(center, 3.5, 0.0, TAU, 28, SHADOW_COLOR, 2.0, true)
	draw_arc(center, 3.5, 0.0, TAU, 28, RETICLE_COLOR, 1.0, true)
	for axis in [Vector2.RIGHT, Vector2.DOWN]:
		for sign_value in [-1.0, 1.0]:
			var start: Vector2 = center + axis * sign_value * 6.0
			var finish: Vector2 = center + axis * sign_value * 8.5
			draw_line(start, finish, SHADOW_COLOR, 2.0, true)
			draw_line(start, finish, RETICLE_COLOR, 1.0, true)
	draw_circle(center, 1.0, RETICLE_COLOR)
