extends Control
## Quiet engraved rules and corner ornaments in the book's shared design space.


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _draw() -> void:
	var ink := Color(0.43, 0.29, 0.15, 0.33)
	for page: Rect2 in [Rect2(88.0, 374.0, 416.0, 616.0), Rect2(564.0, 374.0, 436.0, 616.0)]:
		for corner: Vector2 in [page.position, Vector2(page.end.x, page.position.y), page.end, Vector2(page.position.x, page.end.y)]:
			var direction := Vector2(1.0 if corner.x == page.position.x else -1.0, 1.0 if corner.y == page.position.y else -1.0)
			draw_line(corner, corner + Vector2(direction.x * 30.0, 0.0), ink, 1.0, true)
			draw_line(corner, corner + Vector2(0.0, direction.y * 30.0), ink, 1.0, true)
			var center := corner + direction * 7.0
			draw_colored_polygon(PackedVector2Array([center + Vector2(0, -3), center + Vector2(3, 0), center + Vector2(0, 3), center + Vector2(-3, 0)]), ink)
		var middle := page.get_center().x
		draw_line(Vector2(middle - 52.0, 1000.0), Vector2(middle - 10.0, 1000.0), ink, 1.0, true)
		draw_line(Vector2(middle + 10.0, 1000.0), Vector2(middle + 52.0, 1000.0), ink, 1.0, true)
		draw_circle(Vector2(middle, 1000.0), 2.5, ink)
