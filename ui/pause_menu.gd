extends CanvasLayer
## A single pause owner. Existing Skill Tree / cinematics keep their own pause.
const GOLD := Color("dbc38a")
const INK := Color("101820")
const INVENTORY_PANEL := preload("res://ui/inventory_panel.gd")
var _preview_stream: AudioStreamWAV
var is_open := false
var _page := "home"
var _previous_mouse := Input.MOUSE_MODE_VISIBLE
var _baseline: Dictionary = {}
var _binding_action := ""
var _binding_slot := 0
var _binding_button: Button
var _binding_buttons: Dictionary = {}
var _confirmation := ""
var _display_seconds := 0.0
var _root: Control
var _panel: PanelContainer
var _body: VBoxContainer
var _tabs: HBoxContainer
var _content: VBoxContainer
var _footer: HBoxContainer
var _status: Label
var _title: Label
var _dialog: PanelContainer
var _modal_shade: ColorRect
var _dialog_text: Label
var _dialog_accept: Button
var _dialog_cancel: Button
var _fps: Label
var _tab_index := 0
var _resume_guard := 0
var _closing := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 120
	_build_shell()
	get_viewport().size_changed.connect(_layout)
	get_tree().scene_changed.connect(_scene_changed)
	_layout()
	_root.hide()

func _build_shell() -> void:
	_root = Control.new()
	_root.name = "PauseOverlay"
	_root.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	add_child(_root)
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.04, 0.86)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(shade)
	_panel = PanelContainer.new()
	_panel.add_theme_stylebox_override("panel", _style(INK, GOLD.darkened(0.35), 20))
	_panel.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_root.add_child(_panel)
	var theme := Theme.new()
	theme.default_font_size = 17
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var fill := Color("202e39") if state in ["normal", "disabled"] else Color("344652")
		var border := GOLD if state == "focus" else Color("50616a")
		theme.set_stylebox(state, "Button", _style(fill, border, 10))
		theme.set_stylebox(state, "OptionButton", _style(fill, border, 10))
	theme.set_color("font_color", "Label", Color("e7e4da"))
	theme.set_color("font_color", "Button", Color("f5e6c4"))
	theme.set_color("font_disabled_color", "Button", Color("8c9496"))
	_panel.theme = theme
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 10)
	_panel.add_child(_body)
	var eyebrow := _label("T O W E R   O F   A R C A N A", 14)
	eyebrow.modulate = GOLD
	_body.add_child(eyebrow)
	_title = _label("Tạm dừng", 34)
	_body.add_child(_title)
	_body.add_child(HSeparator.new())
	_tabs = HBoxContainer.new()
	_tabs.add_theme_constant_override("separation", 8)
	_body.add_child(_tabs)
	var scroll := ScrollContainer.new()
	scroll.name = "ContentScroll"
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.follow_focus = true
	scroll.clip_contents = true
	_body.add_child(scroll)
	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 8)
	scroll.add_child(_content)
	_status = _label("", 15)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size.y = 38
	_status.modulate = GOLD
	_body.add_child(_status)
	_footer = HBoxContainer.new()
	_footer.add_theme_constant_override("separation", 10)
	_body.add_child(_footer)
	_modal_shade = ColorRect.new()
	_modal_shade.color = Color(0, 0, 0, 0.35)
	_modal_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(_modal_shade)
	_modal_shade.hide()
	_dialog = PanelContainer.new()
	_dialog.add_theme_stylebox_override("panel", _style(Color("1b2934"), GOLD, 30))
	_dialog.theme = theme
	_root.add_child(_dialog)
	var dialog_body := VBoxContainer.new()
	dialog_body.add_theme_constant_override("separation", 22)
	_dialog.add_child(dialog_body)
	_dialog_text = _label("", 20)
	_dialog_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialog_body.add_child(_dialog_text)
	var actions := HBoxContainer.new()
	dialog_body.add_child(actions)
	_dialog_cancel = _button("Quay lại", _cancel_confirmation)
	actions.add_child(_dialog_cancel)
	_dialog_accept = _button("Xác nhận", _accept_confirmation)
	actions.add_child(_dialog_accept)
	_dialog_cancel.focus_next = _dialog_accept.get_path()
	_dialog_cancel.focus_previous = _dialog_accept.get_path()
	_dialog_accept.focus_next = _dialog_cancel.get_path()
	_dialog_accept.focus_previous = _dialog_cancel.get_path()
	_dialog.hide()
	_fps = _label("", 9)
	_fps.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_fps.position = Vector2(6, 6)
	add_child(_fps)

func _style(fill: Color, border: Color, margin: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = fill
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(5)
	style.content_margin_left = margin
	style.content_margin_right = margin
	style.content_margin_top = margin
	style.content_margin_bottom = margin
	return style

func _label(text: String, font_size: int = 17) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	return label

func _button(text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 42
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.pressed.connect(callback)
	if callback.get_method() != "_preview_sound":
		button.pressed.connect(_preview_sound.bind("UI"))
	return button

func _layout() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	_root.size = viewport_size
	var design := Vector2(720, 560) if _page == "home" else Vector2(960, 650)
	var fit := minf(viewport_size.x * 0.94 / design.x, viewport_size.y * 0.94 / design.y)
	_panel.size = design
	_panel.scale = Vector2.ONE * fit
	_panel.position = (viewport_size - design * fit) / 2.0
	_dialog.size = Vector2(600, 240)
	_dialog.scale = Vector2.ONE * fit
	_dialog.position = (viewport_size - _dialog.size * fit) / 2.0

func _clear(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

func _input(event: InputEvent) -> void:
	if _closing:
		get_viewport().set_input_as_handled()
		return
	if event.is_echo():
		if is_open:
			get_viewport().set_input_as_handled()
		return
	if not is_open:
		if event.is_action_pressed("inventory"):
			if open_menu():
				_show_inventory()
				get_viewport().set_input_as_handled()
			return
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			if open_menu():
				get_viewport().set_input_as_handled()
		return
	if not _binding_action.is_empty():
		if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
			_cancel_binding()
		elif (event is InputEventKey or event is InputEventMouseButton) and event.is_pressed():
			var error := GameSettings.bind_event(_binding_action, _binding_slot, event)
			_status.text = error if not error.is_empty() else "Đã đổi phím. Chọn Áp dụng để lưu."
			if error.is_empty():
				_cancel_binding()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("inventory") and _page == "inventory":
		close_menu()
		get_viewport().set_input_as_handled()
		return
	if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		if not _confirmation.is_empty():
			_cancel_confirmation()
		elif _page == "settings":
			_cancel_settings()
		elif _page in ["help", "inventory"]:
			_show_home()
		else:
			close_menu()
		get_viewport().set_input_as_handled()
	# GUI still receives navigation/clicks. Gameplay nodes are paused and Skill Tree is gated.

func open_menu() -> bool:
	if is_open or get_tree().paused or GameManager.is_changing():
		return false
	# Dialogue/cutscenes own their input and should complete before pausing here.
	var dialogic := get_node_or_null("/root/Dialogic")
	if dialogic != null and dialogic.get("current_timeline") != null:
		return false
	is_open = true
	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.has_method("_cancel_skill_aim"):
		player._cancel_skill_aim()
	_previous_mouse = Input.mouse_mode
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_root.show()
	_show_home()
	return true

func close_menu() -> void:
	if not is_open or _closing:
		return
	if _page == "settings" and not _baseline.is_empty():
		GameSettings.restore(_baseline)
	_cancel_binding()
	_hide_confirmation()
	_root.hide()
	_closing = true
	# Let the closing input leave Input's just-pressed state before gameplay resumes.
	_resume_guard += 1
	var guard := _resume_guard
	await get_tree().process_frame
	await get_tree().process_frame
	if guard == _resume_guard:
		is_open = false
		_closing = false
		get_tree().paused = false
		Input.mouse_mode = _previous_mouse

func _scene_changed() -> void:
	if is_open:
		close_menu()

func _process(delta: float) -> void:
	_fps.visible = GameSettings.values.get("show_fps", false)
	if _fps.visible:
		_fps.text = "%d FPS" % Engine.get_frames_per_second()
	if is_open:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if _confirmation == "display":
		_display_seconds -= delta
		_dialog_text.text = "Giữ chế độ màn hình này?\nTự khôi phục sau %d giây." % ceili(_display_seconds)
		if _display_seconds <= 0.0:
			_cancel_confirmation()

func _show_home() -> void:
	_page = "home"
	_panel.add_theme_stylebox_override("panel", _style(INK, GOLD.darkened(0.35), 20))
	_body.get_child(0).show()
	_title.add_theme_color_override("font_color", Color("e7e4da"))
	_title.text = "Tạm dừng"
	_clear(_tabs)
	_clear(_content)
	_clear(_footer)
	var subtitle := _label("Hành trình có thể đợi một chút.", 20)
	subtitle.modulate = GOLD
	_content.add_child(subtitle)
	for item in [["Tiếp tục", close_menu], ["Cài đặt", open_settings], ["Túi đồ / Trang bị", _show_inventory], ["Điều khiển", _show_help], ["Thoát trò chơi", _ask_quit]]:
		_content.add_child(_button(item[0], item[1]))
	_status.text = "Tiến trình được lưu tự động tại checkpoint.\nEsc để tiếp tục · Alt để thả con trỏ khi chơi."
	_footer.add_child(_label("DAY & NIGHT", 13))
	(_content.get_child(1) as Button).grab_focus()
	_layout.call_deferred()

func _show_inventory() -> void:
	_page = "inventory"
	var wood_frame := StyleBoxFlat.new()
	wood_frame.bg_color = Color("9a6236")
	wood_frame.border_color = Color("3f2419")
	wood_frame.set_border_width_all(3)
	wood_frame.set_corner_radius_all(3)
	wood_frame.content_margin_left = 18
	wood_frame.content_margin_top = 16
	wood_frame.content_margin_right = 18
	wood_frame.content_margin_bottom = 12
	_panel.add_theme_stylebox_override("panel", wood_frame)
	_panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_body.get_child(0).hide()
	_title.add_theme_color_override("font_color", Color("3b3142"))
	_title.text = "Túi đồ"
	_clear(_tabs)
	_clear(_content)
	_clear(_footer)
	var view := INVENTORY_PANEL.new()
	var paper := PanelContainer.new()
	var paper_style := StyleBoxTexture.new()
	paper_style.texture = load("res://assets/items/rpg-ui-pack-v1.1/rpg-ui-pack-v1.1/ui/panels/panel_parchment.png") as Texture2D
	paper_style.texture_margin_left = 8
	paper_style.texture_margin_top = 8
	paper_style.texture_margin_right = 8
	paper_style.texture_margin_bottom = 8
	paper_style.content_margin_left = 10
	paper_style.content_margin_top = 8
	paper_style.content_margin_right = 10
	paper_style.content_margin_bottom = 8
	paper.add_theme_stylebox_override("panel", paper_style)
	paper.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_content.add_child(paper)
	paper.add_child(view)
	view.configure(GameManager.inventory, get_tree().get_first_node_in_group("player"))
	var binding := GameSettings.binding_text(GameSettings.bindings.use_consumable[0])
	_status.text = "Chọn vật phẩm để xem hiệu ứng và trang bị.\n[%s] dùng tiêu hao sau khi trở lại trận đấu. Lưu cùng tiến trình tại checkpoint." % binding
	_status.add_theme_color_override("font_color", Color("3b3142"))
	var back := _button("Quay lại  ·  Esc", _show_home)
	for state in ["normal", "hover", "pressed"]:
		var button_style := StyleBoxTexture.new()
		button_style.texture = load("res://assets/items/rpg-ui-pack-v1.1/rpg-ui-pack-v1.1/ui/buttons/button_a_wood_%s.png" % state) as Texture2D
		button_style.texture_margin_left = 4
		button_style.texture_margin_top = 4
		button_style.texture_margin_right = 4
		button_style.texture_margin_bottom = 4
		back.add_theme_stylebox_override(state, button_style)
	_footer.add_child(back)
	if view._grid.get_child_count() > 0 and view._grid.get_child(0) is Button:
		(view._grid.get_child(0) as Button).grab_focus()
	_layout.call_deferred()

func _ask_quit() -> void:
	_show_confirmation("quit", "Thoát trò chơi?\nLần chơi sau sẽ tiếp tục từ checkpoint đã lưu. Tiến trình chưa lưu sau checkpoint có thể mất.", "Thoát trò chơi")

func _show_help() -> void:
	_page = "help"
	_title.text = "Hướng dẫn điều khiển"
	_clear(_content)
	_clear(_footer)
	for action: String in GameSettings.ACTIONS:
		var row := _row(GameSettings.ACTIONS[action])
		var slots: Array = GameSettings.bindings[action]
		row.add_child(_label("%s    /    %s" % [GameSettings.binding_text(slots[0]), GameSettings.binding_text(slots[1])]))
	_status.text = "Chuột: xoay camera · Con lăn: zoom · Alt: thả con trỏ\nChạm phím kỹ năng để dùng; giữ 0,3 giây để ngắm rồi thả."
	var back := _button("Quay lại  ·  Esc", _show_home)
	_footer.add_child(back)
	back.grab_focus()
	_layout.call_deferred()

func open_settings() -> void:
	_baseline = GameSettings.snapshot()
	_page = "settings"
	_title.text = "Cài đặt"
	_clear(_tabs)
	_clear(_footer)
	for index in 3:
		var button := _button(["Điều khiển", "Âm thanh", "Hiển thị"][index], _show_tab.bind(index))
		button.toggle_mode = true
		_tabs.add_child(button)
	_footer.add_child(_button("Mặc định", func(): _show_confirmation("reset", "Khôi phục toàn bộ cài đặt mặc định?\nChọn Áp dụng sau đó để lưu thay đổi.", "Khôi phục")))
	_footer.add_child(_button("Hủy  ·  Esc", _cancel_settings))
	_footer.add_child(_button("Áp dụng", _apply_settings))
	_show_tab(0)
	(_tabs.get_child(0) as Button).grab_focus()
	if not GameSettings.load_notice.is_empty():
		_status.text = GameSettings.load_notice

func _show_tab(index: int) -> void:
	_layout.call_deferred()
	_cancel_binding()
	_tab_index = index
	_clear(_content)
	_binding_buttons.clear()
	(_body.get_node("ContentScroll") as ScrollContainer).scroll_vertical = 0
	for i in 3:
		(_tabs.get_child(i) as Button).set_pressed_no_signal(i == index)
	_status.text = "Âm thanh và camera được nghe / xem thử ngay. Áp dụng để lưu; Hủy để hoàn tác."
	match index:
		0:
			_slider("Độ nhạy chuột", "sensitivity", 0.02, 0.5, 0.01)
			_toggle("Đảo chiều trục dọc camera", "invert_y")
			_slider("Góc nhìn camera", "fov", 45, 85, 1)
			var note := _label("Chọn một ô rồi nhấn phím / nút chuột. Esc hủy gán; × xóa ô phụ.", 15)
			note.modulate = GOLD
			_content.add_child(note)
			for action: String in GameSettings.ACTIONS:
				var row := _row(GameSettings.ACTIONS[action])
				for slot in 2:
					var button := _button(GameSettings.binding_text(GameSettings.bindings[action][slot]), _start_binding.bind(action, slot))
					button.custom_minimum_size.x = 150
					row.add_child(button)
					_binding_buttons[action + str(slot)] = button
					var clear := _button("×", _clear_binding.bind(action, slot))
					clear.tooltip_text = "Xóa ô phím (giữ ít nhất một ô)"
					clear.size_flags_horizontal = Control.SIZE_SHRINK_END
					row.add_child(clear)
		1:
			for pair in [["Âm lượng tổng", "master"], ["Nhạc nền", "music"], ["Hiệu ứng chiến đấu", "sfx"], ["Giao diện", "ui"]]:
				_slider(pair[0], pair[1], 0, 1, 0.01)
			_toggle("Tắt toàn bộ âm thanh", "mute")
			_toggle("Tắt tiếng khi chuyển sang ứng dụng khác", "background_mute")
			_content.add_child(_button("Nghe thử hiệu ứng", _preview_sound.bind("SFX")))
			_content.add_child(_button("Nghe thử giao diện", _preview_sound.bind("UI")))
			_status.text = "Nhạc nền áp dụng cho kênh Music khi màn chơi có nhạc. Màn chơi hiện tại chưa có nhạc nền."
		2:
			_option("Chế độ màn hình", "window_mode", ["Cửa sổ", "Cửa sổ không viền", "Toàn màn hình"], [0, 1, 2])
			_option("Kích thước cửa sổ", "resolution", ["960 × 540", "1280 × 720", "1600 × 900", "1920 × 1080", "2560 × 1440"], [0, 1, 2, 3, 4])
			_toggle("Đồng bộ dọc (VSync)", "vsync")
			_option("Giới hạn FPS", "fps_limit", ["Không giới hạn", "30", "60", "90", "120", "144", "165", "240"], GameSettings.LIMITS)
			_slider("Tỷ lệ kết xuất 3D", "render_scale", 0.5, 1.0, 0.05)
			_option("Khử răng cưa MSAA", "msaa", ["Tắt", "2×", "4×", "8×"], [0, 1, 2, 3])
			_toggle("Hiện bộ đếm FPS", "show_fps")
			_status.text = "Hiển thị áp dụng khi bấm Áp dụng. Đổi cửa sổ cần xác nhận trong 15 giây.\nKích thước chỉ dùng cho chế độ cửa sổ; game nhúng trong editor có thể bỏ qua."

func _row(text: String) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 10)
	var label := _label(text)
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(label)
	_content.add_child(row)
	return row

func _edit(key: String, value: Variant) -> void:
	GameSettings.values[key] = value
	GameSettings.apply_audio()
	GameSettings.changed.emit()

func _slider(text: String, key: String, low: float, high: float, step: float) -> void:
	var row := _row(text)
	var slider := HSlider.new()
	slider.custom_minimum_size = Vector2(270, 35)
	slider.min_value = low
	slider.max_value = high
	slider.step = step
	slider.value = GameSettings.values[key]
	row.add_child(slider)
	var value_label := _label("")
	value_label.custom_minimum_size.x = 75
	row.add_child(value_label)
	var update := func(value: float):
		value_label.text = "%d%%" % roundi(value * 100) if high <= 1.0 and key != "sensitivity" else "%.2f" % value
	update.call(slider.value)
	slider.value_changed.connect(func(value: float):
		_edit(key, value)
		update.call(value))

func _toggle(text: String, key: String) -> void:
	var row := _row(text)
	var toggle := CheckButton.new()
	toggle.text = "Bật"
	toggle.button_pressed = GameSettings.values[key]
	row.add_child(toggle)
	toggle.toggled.connect(func(value: bool): _edit(key, value))

func _option(text: String, key: String, labels: Array, data: Array) -> void:
	var row := _row(text)
	var option := OptionButton.new()
	option.custom_minimum_size.x = 280
	for label: String in labels:
		option.add_item(label)
	option.select(maxi(0, data.find(GameSettings.values[key])))
	row.add_child(option)
	option.item_selected.connect(func(index: int): _edit(key, data[index]))

func _start_binding(action: String, slot: int) -> void:
	_cancel_binding()
	_binding_action = action
	_binding_slot = slot
	_binding_button = _binding_buttons[action + str(slot)]
	_binding_button.text = "Nhấn phím…"
	_status.text = "Đang gán «%s» — Esc để hủy. Phím trùng sẽ không được ghi đè." % GameSettings.ACTIONS[action]

func _cancel_binding() -> void:
	if is_instance_valid(_binding_button) and not _binding_action.is_empty():
		_binding_button.text = GameSettings.binding_text(GameSettings.bindings[_binding_action][_binding_slot])
	_binding_action = ""
	_binding_button = null

func _clear_binding(action: String, slot: int) -> void:
	_status.text = GameSettings.clear_binding(action, slot)
	(_binding_buttons[action + str(slot)] as Button).text = GameSettings.binding_text(GameSettings.bindings[action][slot])

func _cancel_settings() -> void:
	_cancel_binding()
	GameSettings.restore(_baseline)
	_show_home()

func _apply_settings() -> void:
	_cancel_binding()
	GameSettings.apply()
	if GameSettings.values.window_mode != _baseline.values.window_mode or GameSettings.values.resolution != _baseline.values.resolution:
		_display_seconds = 15.0
		_show_confirmation("display", "Giữ chế độ màn hình này?", "Giữ thay đổi")
	else:
		_save_settings()

func _save_settings() -> void:
	var error := GameSettings.save_settings()
	if error != OK:
		_status.text = "Chưa lưu được cài đặt: %s. Kiểm tra quyền ghi rồi thử lại, hoặc Hủy." % error_string(error)
		return
	_baseline = GameSettings.snapshot()
	_status.text = "Đã áp dụng và lưu cài đặt."

func _show_confirmation(kind: String, text: String, accept_text: String) -> void:
	_confirmation = kind
	_dialog_text.text = text
	_dialog_accept.text = accept_text
	_panel.modulate = Color(0.45, 0.45, 0.45)
	_panel.process_mode = Node.PROCESS_MODE_DISABLED
	_dialog.show()
	_dialog_cancel.grab_focus()
	_modal_shade.show()

func _hide_confirmation() -> void:
	_confirmation = ""
	_dialog.hide()
	_modal_shade.hide()
	_panel.modulate = Color.WHITE
	_panel.process_mode = Node.PROCESS_MODE_INHERIT
	if _footer.get_child_count() > 0 and _footer.get_child(0) is Button:
		(_footer.get_child(0) as Button).grab_focus()
	elif _content.get_child_count() > 1 and _content.get_child(1) is Button:
		(_content.get_child(1) as Button).grab_focus()

func _cancel_confirmation() -> void:
	if _confirmation == "display":
		GameSettings.values.window_mode = _baseline.values.window_mode
		GameSettings.values.resolution = _baseline.values.resolution
		GameSettings.apply_display()
		_show_tab(_tab_index)
		_status.text = "Đã khôi phục chế độ màn hình trước đó. Các thay đổi khác chưa được lưu."
	_hide_confirmation()

func _accept_confirmation() -> void:
	var kind := _confirmation
	_hide_confirmation()
	match kind:
		"quit": get_tree().quit()
		"display": _save_settings()
		"reset":
			GameSettings.values = GameSettings.defaults.duplicate(true)
			GameSettings.bindings = GameSettings.default_bindings.duplicate(true)
			GameSettings.apply_bindings()
			GameSettings.apply_audio()
			GameSettings.changed.emit()
			_show_tab(_tab_index)
			_status.text = "Đã chọn mặc định. Áp dụng để lưu; Hủy để giữ cài đặt cũ."

func _preview_sound(bus: String) -> void:
	var audio := AudioStreamPlayer.new()
	if _preview_stream == null:
		_preview_stream = AudioStreamWAV.new()
		_preview_stream.format = AudioStreamWAV.FORMAT_16_BITS
		_preview_stream.mix_rate = 22050
		var data := PackedByteArray()
		data.resize(6615 * 2)
		for i in 6615:
			var envelope := sin(PI * float(i) / 6615.0)
			var sample := int(sin(TAU * 660.0 * float(i) / 22050.0) * envelope * 4500)
			data.encode_s16(i * 2, sample)
		_preview_stream.data = data
	audio.stream = _preview_stream
	audio.bus = bus
	add_child(audio)
	audio.finished.connect(audio.queue_free)
	audio.play()
