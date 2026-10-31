@tool
extends EditorScript

## Dựng lại levels/level_1/basement_full.tscn từ tools/basement_full_builder.gd.
## Cách chạy: mở file này trong Script Editor rồi bấm File | Run (Ctrl + Shift + X).
## Bố cục nằm trong basement_full_builder.gd; scene cũ bị ghi đè toàn bộ.

const Builder := preload("res://tools/basement_full_builder.gd")


func _run() -> void:
	if Builder.new().build() == OK:
		EditorInterface.get_resource_filesystem().scan()
