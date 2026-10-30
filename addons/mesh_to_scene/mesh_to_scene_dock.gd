@tool
extends VBoxContainer

## Editor dock UI for the batch mesh-to-scene converter.
##
## All controls are created in code (in [method _ready]) so the whole panel
## lives in one file and stays easy to adjust. The dock only gathers user input
## into a [MeshToSceneOptions] and hands it to [MeshToSceneConverter]; it holds
## no conversion logic of its own.

## Where the last-used settings are stored, so they survive editor restarts.
const SETTINGS_PATH := "user://mesh_to_scene.cfg"

## Braille frames used for the little "working" spinner.
const SPINNER_FRAMES := ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]

## Editor base control, set by the plugin, used to parent folder-pick dialogs.
var _editor_base: Control

var _source_edit: LineEdit
var _recursive_check: CheckBox
var _ext_checks: Dictionary = {} # extension (String) -> CheckBox
var _count_label: Label

var _collision_check: CheckBox
var _collision_group: VBoxContainer
var _collision_type_option: OptionButton
var _scene_root_option: OptionButton

var _output_edit: LineEdit
var _layout_option: OptionButton

var _gen_library_check: CheckBox
var _library_group: VBoxContainer
var _library_path_edit: LineEdit
var _library_name_edit: LineEdit

var _convert_button: Button
var _progress: ProgressBar
var _status_label: Label
var _open_folder_button: Button
var _log: RichTextLabel

## Every control that must be disabled while a conversion runs.
var _inputs: Array[Control] = []
var _running := false
var _spin := 0
var _last_output_folder := ""


func set_editor_base_control(base: Control) -> void:
	_editor_base = base


func _ready() -> void:
	add_theme_constant_override("separation", 6)

	_add_heading("Source")
	_source_edit = _add_folder_row("Source folder", "", "Folder to scan for mesh files.")
	_source_edit.text_changed.connect(func(_t: String) -> void:
		_refresh_convert_enabled()
		_update_scan_count())
	_recursive_check = _add_check("Scan recursively", true, "Also scan every sub-folder of the source folder.")
	_recursive_check.toggled.connect(func(_p: bool) -> void: _update_scan_count())
	_add_file_type_row()

	_count_label = Label.new()
	_count_label.add_theme_color_override("font_color", Color(0.6, 0.63, 0.72))
	add_child(_count_label)

	_add_separator()
	_add_heading("Scene")
	_scene_root_option = _add_option("Scene root", ["MeshInstance3D", "StaticBody3D"],
		"Root node of each generated scene.\nMeshInstance3D: collision (if any) is nested in a StaticBody3D.\nStaticBody3D: the mesh and collision are its children.")
	_collision_check = _add_check("Add collision", false, "Generate a collision shape for each mesh.")
	_collision_check.toggled.connect(_on_collision_toggled)
	_collision_group = VBoxContainer.new()
	add_child(_collision_group)
	_collision_type_option = _add_option("Collision type", ["Trimesh (exact)", "Convex (hull)"],
		"Trimesh: exact concave shape following the geometry — best for static level pieces.\nConvex: simplified convex hull — cheaper, but ignores holes and concave detail.",
		_collision_group)

	_add_separator()
	_add_heading("Output")
	_output_edit = _add_folder_row("Output folder", "", "Folder where the generated scenes are saved.")
	_output_edit.text_changed.connect(func(_t: String) -> void: _refresh_convert_enabled())
	_layout_option = _add_option("Output layout", ["Mirror source folders", "Flatten into one folder"],
		"Mirror: recreate the source sub-folder structure under the output folder.\nFlatten: put every generated scene directly in the output folder.")

	_add_separator()
	_add_heading("MeshLibrary")
	_gen_library_check = _add_check("Generate MeshLibrary", false,
		"Also build a MeshLibrary from the generated scenes, for use with a GridMap.")
	_gen_library_check.toggled.connect(_on_generate_library_toggled)
	_build_library_group()

	_add_separator()
	_convert_button = Button.new()
	_convert_button.text = "Convert"
	_convert_button.pressed.connect(_on_convert_pressed)
	add_child(_convert_button)

	_status_label = Label.new()
	_status_label.visible = false
	add_child(_status_label)

	_progress = ProgressBar.new()
	_progress.min_value = 0
	_progress.max_value = 100
	_progress.value = 0
	_progress.visible = false
	add_child(_progress)

	_open_folder_button = Button.new()
	_open_folder_button.text = "Open output folder"
	_open_folder_button.visible = false
	_open_folder_button.pressed.connect(_on_open_folder_pressed)
	add_child(_open_folder_button)

	_log = RichTextLabel.new()
	_log.bbcode_enabled = true
	_log.custom_minimum_size = Vector2(0, 120)
	_log.selection_enabled = true
	_log.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(_log)

	_load_settings()
	_on_collision_toggled(_collision_check.button_pressed)
	_on_generate_library_toggled(_gen_library_check.button_pressed)
	_refresh_convert_enabled()
	_update_scan_count()
	_show_hint()


# --- UI construction helpers ------------------------------------------------

func _add_heading(text: String) -> void:
	# A little breathing room above each section so groups read as distinct.
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 4)
	add_child(spacer)

	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0.92, 0.94, 1.0))
	add_child(label)


func _add_separator() -> void:
	add_child(HSeparator.new())


func _add_check(text: String, pressed: bool, tooltip := "", parent: Node = self) -> CheckBox:
	var check := CheckBox.new()
	check.text = text
	check.button_pressed = pressed
	check.tooltip_text = tooltip
	parent.add_child(check)
	_inputs.append(check)
	return check


## Adds a "Label: [LineEdit] [...]" row that opens a folder picker and returns the LineEdit.
func _add_folder_row(label_text: String, value: String, tooltip := "", parent: Node = self) -> LineEdit:
	var label := Label.new()
	label.text = label_text
	label.tooltip_text = tooltip
	parent.add_child(label)

	var row := HBoxContainer.new()
	var edit := LineEdit.new()
	edit.text = value
	edit.placeholder_text = "res://..."
	edit.tooltip_text = tooltip
	edit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(edit)
	_inputs.append(edit)

	var browse := Button.new()
	browse.text = "..."
	browse.tooltip_text = "Browse for a folder"
	browse.pressed.connect(_pick_folder.bind(edit))
	row.add_child(browse)
	_inputs.append(browse)

	parent.add_child(row)
	return edit


## Adds a "Label: [OptionButton]" row with the given items and returns the OptionButton.
func _add_option(label_text: String, items: Array, tooltip := "", parent: Node = self) -> OptionButton:
	var label := Label.new()
	label.text = label_text
	label.tooltip_text = tooltip
	parent.add_child(label)

	var option := OptionButton.new()
	for item in items:
		option.add_item(item)
	option.tooltip_text = tooltip
	parent.add_child(option)
	_inputs.append(option)
	return option


func _add_file_type_row() -> void:
	var label := Label.new()
	label.text = "File types"
	label.tooltip_text = "Which mesh file formats to include while scanning."
	add_child(label)

	var row := HBoxContainer.new()
	for ext in ["fbx", "glb", "gltf"]:
		var check := CheckBox.new()
		check.text = "." + ext
		check.button_pressed = true
		check.tooltip_text = "Include .%s files" % ext
		check.toggled.connect(func(_p: bool) -> void: _update_scan_count())
		row.add_child(check)
		_inputs.append(check)
		_ext_checks[ext] = check
	add_child(row)


func _build_library_group() -> void:
	_library_group = VBoxContainer.new()
	_library_group.visible = false
	add_child(_library_group)

	_library_path_edit = _add_folder_row("Library folder", "",
		"Folder where the MeshLibrary resource is saved.", _library_group)

	var name_label := Label.new()
	name_label.text = "Library file name"
	name_label.tooltip_text = "File name for the MeshLibrary (a .tres extension is added if missing)."
	_library_group.add_child(name_label)

	_library_name_edit = LineEdit.new()
	_library_name_edit.text = "mesh_library.tres"
	_library_name_edit.tooltip_text = name_label.tooltip_text
	_library_group.add_child(_library_name_edit)
	_inputs.append(_library_name_edit)


# --- Enable / disable state -------------------------------------------------

func _on_collision_toggled(pressed: bool) -> void:
	_collision_group.visible = pressed


func _on_generate_library_toggled(pressed: bool) -> void:
	_library_group.visible = pressed


## The Convert button is only usable once the required folders are filled in and
## no conversion is currently running.
func _refresh_convert_enabled() -> void:
	if _running:
		_convert_button.disabled = true
		return
	var ready := not _source_edit.text.strip_edges().is_empty() \
		and not _output_edit.text.strip_edges().is_empty()
	_convert_button.disabled = not ready
	_convert_button.tooltip_text = "" if ready else "Set a source and an output folder first."


## Shows how many mesh files the current source/filter settings would convert,
## so the user knows the scope before pressing Convert.
func _update_scan_count() -> void:
	if _running:
		return
	var source := _source_edit.text.strip_edges()
	if source.is_empty():
		_count_label.text = ""
		return
	if not DirAccess.dir_exists_absolute(source):
		_count_label.text = "Folder not found"
		return

	var options := MeshToSceneOptions.new()
	options.source_folder = source
	options.recursive = _recursive_check.button_pressed
	options.extensions = _selected_extensions()

	var count := MeshToSceneConverter.gather_files(options).size()
	_count_label.text = "Found: %d mesh file(s)" % count


## Muted placeholder shown in the log until the first conversion runs.
func _show_hint() -> void:
	_log.text = "[color=#7f8598]Pick a source and an output folder, then press Convert.[/color]"


func _set_running(running: bool) -> void:
	_running = running
	for control in _inputs:
		_set_control_enabled(control, not running)
	_convert_button.text = "Converting…" if running else "Convert"
	_progress.visible = running
	_status_label.visible = running
	if running:
		_open_folder_button.visible = false
		_progress.value = 0
	_refresh_convert_enabled()


func _set_control_enabled(control: Control, enabled: bool) -> void:
	if control is LineEdit:
		(control as LineEdit).editable = enabled
	elif control is BaseButton:
		(control as BaseButton).disabled = not enabled


# --- Folder picking ---------------------------------------------------------

func _pick_folder(target: LineEdit) -> void:
	# EditorFileDialog is only available inside the editor; guard just in case.
	if _editor_base == null:
		return
	var dialog := EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_DIR
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.title = "Select folder"
	_editor_base.add_child(dialog)
	dialog.dir_selected.connect(func(dir: String) -> void:
		target.text = dir
		_refresh_convert_enabled()
		dialog.queue_free())
	dialog.canceled.connect(func() -> void: dialog.queue_free())
	dialog.popup_centered_ratio(0.5)


func _on_open_folder_pressed() -> void:
	if _last_output_folder.is_empty():
		return
	OS.shell_open(ProjectSettings.globalize_path(_last_output_folder))


# --- Conversion -------------------------------------------------------------

func _on_convert_pressed() -> void:
	var options := _collect_options()

	var error := options.validate()
	if not error.is_empty():
		_log.text = "[color=#e06c75]%s[/color]" % error
		return

	_save_settings(options)
	_last_output_folder = options.output_folder
	_log.text = ""
	_set_running(true)

	var report: MeshToSceneReport = await MeshToSceneConverter.convert(options, _on_progress)

	_set_running(false)

	# Refresh the FileSystem dock so the newly created scenes appear right away —
	# Godot does not rescan on its own after files are written to disk.
	if not report.created_scenes.is_empty():
		EditorInterface.get_resource_filesystem().scan()

	_show_report(report)


func _on_progress(done: int, total: int, message: String) -> void:
	_spin = (_spin + 1) % SPINNER_FRAMES.size()
	_status_label.text = "%s %s" % [SPINNER_FRAMES[_spin], message]
	_progress.max_value = maxi(total, 1)
	_progress.value = done


func _show_report(report: MeshToSceneReport) -> void:
	var lines: Array[String] = []
	lines.append("[color=#98c379]Created: %d[/color]" % report.created_scenes.size())
	if report.overwritten.size() > 0:
		lines.append("Overwritten: %d" % report.overwritten.size())
	if report.skipped_files.size() > 0:
		lines.append("Skipped (no mesh): %d" % report.skipped_files.size())
	if not report.library_path.is_empty():
		lines.append("MeshLibrary: %s" % report.library_path)
	for w in report.warnings:
		lines.append("[color=#e5c07b]⚠ %s[/color]" % w)
	for e in report.errors:
		lines.append("[color=#e06c75]✖ %s[/color]" % e)

	_log.text = "\n".join(lines)
	_open_folder_button.visible = report.created_scenes.size() > 0 and report.errors.is_empty()


# --- Settings persistence ---------------------------------------------------

func _selected_extensions() -> PackedStringArray:
	var extensions: PackedStringArray = []
	for ext in _ext_checks:
		if (_ext_checks[ext] as CheckBox).button_pressed:
			extensions.append(ext)
	return extensions


func _collect_options() -> MeshToSceneOptions:
	var options := MeshToSceneOptions.new()
	options.source_folder = _source_edit.text.strip_edges()
	options.recursive = _recursive_check.button_pressed
	options.extensions = _selected_extensions()

	# OptionButton item order matches the enum value order, so the selected
	# index maps straight onto the enum (enum values are plain ints).
	options.add_collision = _collision_check.button_pressed
	options.collision_type = _collision_type_option.selected
	options.scene_root = _scene_root_option.selected

	options.output_folder = _output_edit.text.strip_edges()
	options.output_layout = _layout_option.selected

	options.generate_mesh_library = _gen_library_check.button_pressed
	options.library_path = _library_path_edit.text.strip_edges()

	# Make sure the library file always has a .tres extension.
	var library_name := _library_name_edit.text.strip_edges()
	if not library_name.is_empty() and not library_name.to_lower().ends_with(".tres"):
		library_name += ".tres"
		_library_name_edit.text = library_name
	options.library_file_name = library_name

	return options


func _save_settings(options: MeshToSceneOptions) -> void:
	var config := ConfigFile.new()
	config.set_value("mesh_to_scene", "source_folder", options.source_folder)
	config.set_value("mesh_to_scene", "recursive", options.recursive)
	config.set_value("mesh_to_scene", "extensions", options.extensions)
	config.set_value("mesh_to_scene", "add_collision", options.add_collision)
	config.set_value("mesh_to_scene", "collision_type", options.collision_type)
	config.set_value("mesh_to_scene", "scene_root", options.scene_root)
	config.set_value("mesh_to_scene", "output_folder", options.output_folder)
	config.set_value("mesh_to_scene", "output_layout", options.output_layout)
	config.set_value("mesh_to_scene", "generate_mesh_library", options.generate_mesh_library)
	config.set_value("mesh_to_scene", "library_path", options.library_path)
	config.set_value("mesh_to_scene", "library_file_name", options.library_file_name)
	config.save(SETTINGS_PATH)


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return

	_source_edit.text = config.get_value("mesh_to_scene", "source_folder", "")
	_recursive_check.button_pressed = config.get_value("mesh_to_scene", "recursive", true)

	var extensions: PackedStringArray = config.get_value("mesh_to_scene", "extensions", ["fbx", "glb", "gltf"])
	for ext in _ext_checks:
		(_ext_checks[ext] as CheckBox).button_pressed = ext in extensions

	_collision_check.button_pressed = config.get_value("mesh_to_scene", "add_collision", false)
	_collision_type_option.selected = config.get_value("mesh_to_scene", "collision_type", 0)
	_scene_root_option.selected = config.get_value("mesh_to_scene", "scene_root", 0)

	_output_edit.text = config.get_value("mesh_to_scene", "output_folder", "")
	_layout_option.selected = config.get_value("mesh_to_scene", "output_layout", 0)

	_gen_library_check.button_pressed = config.get_value("mesh_to_scene", "generate_mesh_library", false)
	_library_path_edit.text = config.get_value("mesh_to_scene", "library_path", "")
	_library_name_edit.text = config.get_value("mesh_to_scene", "library_file_name", "mesh_library.tres")
