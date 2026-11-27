extends TextureProgressBar
## Each divider marks one HP. Range's fractional fill displays half-HP hits.
func _ready() -> void:
	changed.connect(queue_redraw)
	value_changed.connect(func(_value: float) -> void: queue_redraw())
	resized.connect(queue_redraw)


func _draw() -> void:
	var capacity := max_value - min_value
	if capacity <= 1.0:
		return
	var top := float(stretch_margin_top)
	var height := maxf(0.0, size.y - top - float(stretch_margin_bottom))
	for point in range(1, ceili(capacity)):
		var x := roundf(size.x * float(point) / capacity)
		draw_rect(Rect2(x, top, 1.0, height), Color("1b1012"))