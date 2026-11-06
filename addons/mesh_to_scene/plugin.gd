@tool
extends EditorPlugin

## Registers the "Mesh to Scene" dock in the editor.
##
## The dock is a self-contained scene; this plugin only handles adding it to
## the editor while enabled and removing it again when disabled.

const DockScene := preload("res://addons/mesh_to_scene/mesh_to_scene_dock.tscn")

## The ScrollContainer that is actually docked; it wraps the panel so the dock
## scrolls vertically when the editor makes it shorter than its contents.
var _dock: ScrollContainer


func _enter_tree() -> void:
	var panel := DockScene.instantiate()

	# Hand the panel the editor's base control so it can parent file dialogs to it.
	if panel.has_method("set_editor_base_control"):
		panel.call("set_editor_base_control", EditorInterface.get_base_control())

	# Let the panel fill the dock width; the scroll container adds a vertical
	# scrollbar when the contents are taller than the available space.
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	_dock = ScrollContainer.new()
	# The dock's node name becomes its tab title.
	_dock.name = "Mesh to Scene"
	_dock.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	_dock.add_child(panel)

	# Dock into the lower-left, alongside the FileSystem and History tabs.
	add_control_to_dock(DOCK_SLOT_LEFT_BL, _dock)


func _exit_tree() -> void:
	if _dock:
		remove_control_from_docks(_dock)
		_dock.queue_free()
		_dock = null
