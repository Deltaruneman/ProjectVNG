extends SceneTree

## Bản headless của tools/build_basement_full.gd (không cần mở editor):
##   godot --headless --path . --script res://tools/run_build_basement_full.gd

const Builder := preload("res://tools/basement_full_builder.gd")


func _initialize() -> void:
	quit(0 if Builder.new().build() == OK else 1)
