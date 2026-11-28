extends CanvasLayer

var _was_paused := false
var _closing := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 120
	_was_paused = get_tree().paused
	get_tree().paused = true
	_build_overlay()


func _build_overlay() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.025, 0.035, 0.065, 0.92)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(shade)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(540, 260)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("101b2b")
	panel_style.border_color = Color("e6bb62")
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(10)
	panel_style.content_margin_left = 28.0
	panel_style.content_margin_right = 28.0
	panel_style.content_margin_top = 26.0
	panel_style.content_margin_bottom = 24.0
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.alignment = BoxContainer.ALIGNMENT_CENTER
	content.add_theme_constant_override("separation", 20)
	panel.add_child(content)

	var heading := Label.new()
	heading.text = "COMING SOON"
	heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heading.add_theme_font_size_override("font_size", 38)
	heading.add_theme_color_override("font_color", Color("ffe7ac"))
	content.add_child(heading)

	var description := Label.new()
	description.text = "Nội dung này sẽ sớm được tiếp tục.\nNhấn Esc hoặc chọn Đóng."
	description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	description.add_theme_font_size_override("font_size", 22)
	description.add_theme_color_override("font_color", Color("e5edf8"))
	content.add_child(description)

	var close_button := Button.new()
	close_button.text = "Đóng"
	close_button.custom_minimum_size = Vector2(170, 48)
	close_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	close_button.add_theme_font_size_override("font_size", 20)
	close_button.pressed.connect(_close)
	content.add_child(close_button)
	close_button.grab_focus()


func _input(event: InputEvent) -> void:
	if not _closing and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()


func _close() -> void:
	if _closing:
		return
	_closing = true
	get_tree().paused = _was_paused
	queue_free()
