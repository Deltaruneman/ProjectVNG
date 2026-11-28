extends CanvasLayer

const CATALOG := preload("res://scripts/item_catalog.gd")
const GOLD := Color("f1e2b6")
const SKIN_ROOT := "res://assets/ui/hearthmark/"

var is_open := false
var _closing := false
var _previous_mouse := Input.MOUSE_MODE_VISIBLE
var _root: Control
var _panel: PanelContainer
var _actions: VBoxContainer
var _skin_data: Dictionary = {}
var _skin_cache: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 116
	_skin_data = JSON.parse_string(FileAccess.get_file_as_string(SKIN_ROOT + "slices.json"))
	_build()
	get_viewport().size_changed.connect(_layout)
	get_tree().scene_changed.connect(close_menu)
	_layout()
	_root.hide()


func _skin(asset: String, inset: float = 12.0) -> StyleBoxTexture:
	var key := asset + str(inset)
	if _skin_cache.has(key):
		return _skin_cache[key]
	var data: Dictionary = _skin_data[asset]
	var border: Dictionary = data.nineSlice
	var style := StyleBoxTexture.new()
	style.texture = load(SKIN_ROOT + str(data.file))
	style.texture_margin_left = float(border.left)
	style.texture_margin_top = float(border.top)
	style.texture_margin_right = float(border.right)
	style.texture_margin_bottom = float(border.bottom)
	style.axis_stretch_horizontal = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	style.axis_stretch_vertical = StyleBoxTexture.AXIS_STRETCH_MODE_TILE
	style.content_margin_left = inset
	style.content_margin_right = inset
	style.content_margin_top = inset
	style.content_margin_bottom = inset
	_skin_cache[key] = style
	return style


func _build() -> void:
	_root = Control.new()
	_root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_root)
	var shade := ColorRect.new()
	shade.color = Color(0.02, 0.03, 0.055, 0.92)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(shade)
	_panel = PanelContainer.new()
	_panel.add_theme_stylebox_override("panel", _skin("panel_stone", 18))
	_root.add_child(_panel)
	var theme := Theme.new()
	theme.default_font_size = 16
	theme.set_color("font_color", "Label", Color("ece7dc"))
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var asset: String = "button_a_wood_" + ("hover" if state == "focus" else state)
		theme.set_stylebox(state, "Button", _skin(asset, 10))
	theme.set_color("font_color", "Button", GOLD)
	theme.set_color("font_hover_color", "Button", Color.WHITE)
	theme.set_color("font_disabled_color", "Button", Color("b98e5a"))
	_panel.theme = theme
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 12)
	_panel.add_child(body)
	var header := HBoxContainer.new()
	body.add_child(header)
	var title := Label.new()
	title.text = "MENU THỬ NGHIỆM"
	title.add_theme_font_size_override("font_size", 26)
	title.add_theme_color_override("font_color", GOLD)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	_add_button(header, "Đóng · P / Esc", close_menu)
	var description := Label.new()
	description.text = "Công cụ thử vật phẩm và kỹ năng. Tiến trình ở đây vẫn được lưu."
	description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(description)
	_actions = VBoxContainer.new()
	_actions.add_theme_constant_override("separation", 8)
	body.add_child(_actions)
	_add_button(_actions, "Nhận bộ vật phẩm", _grant_test_items)
	_add_button(_actions, "+20 SP để thử", _grant_test_points)
	_add_button(_actions, "Mở bàn enchant", _open_enchant)
	_add_button(_actions, "Trở về không nguyên tố", GameManager.reset_skill_tree)
	_actions.add_child(HSeparator.new())
	for form: String in CATALOG.ELEMENTS:
		_add_button(_actions, "Test hệ %s + skill 1" % str(CATALOG.ELEMENTS[form]), _test_element.bind(form))


func _add_button(parent: Control, title: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = title
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.pressed.connect(action)
	parent.add_child(button)
	return button


func _layout() -> void:
	if _panel == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var factor := maxf(0.1, minf(viewport_size.x / 960.0, viewport_size.y / 540.0))
	_root.scale = Vector2.ONE * factor
	_root.size = viewport_size / factor
	_panel.position = Vector2(18, 16)
	_panel.size = _root.size - Vector2(36, 32)


func _input(event: InputEvent) -> void:
	if event.is_echo() or _closing:
		return
	if event.is_action_pressed("cheat_menu"):
		get_viewport().set_input_as_handled()
		if is_open:
			close_menu()
		else:
			_open_menu()
	elif is_open and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_menu()


func _open_menu() -> void:
	if is_open or _closing:
		return
	var inventory_menu := get_node_or_null("/root/InventoryMenu")
	if inventory_menu != null and bool(inventory_menu.get("is_open")):
		await inventory_menu.call("close_menu")
	if get_tree().paused or GameManager.is_changing():
		return
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.health <= 0 or player.is_talking:
		return
	var dialogic := get_node_or_null("/root/Dialogic")
	if dialogic != null and dialogic.get("current_timeline") != null:
		return
	player._cancel_skill_aim()
	_previous_mouse = Input.mouse_mode
	is_open = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_root.show()


func close_menu() -> void:
	if not is_open or _closing:
		return
	_root.hide()
	_closing = true
	await get_tree().process_frame
	await get_tree().process_frame
	await GameManager.set_pause_safely(false)
	is_open = false
	_closing = false
	Input.mouse_mode = _previous_mouse


func _grant_test_items() -> void:
	for definition: String in CATALOG.definitions():
		if CATALOG.item(definition).slot == "offhand":
			continue
		GameManager.inventory.grant(definition, 5 if CATALOG.item(definition).slot == "consumable" else 1)
	GameManager.notify_inventory_changed()


func _grant_test_points() -> void:
	GameManager.skill_points += 20
	GameManager.notify_inventory_changed()


func _test_element(form: String) -> void:
	GameManager.reset_skill_tree()
	GameManager.skill_points = maxi(GameManager.skill_points, 3)
	GameManager.spend_skill_point("form_" + form, form)
	GameManager.spend_skill_point("active_%s_1" % form)


func _open_enchant() -> void:
	var inventory_menu := get_node_or_null("/root/InventoryMenu")
	await close_menu()
	if inventory_menu != null:
		inventory_menu.call("open_menu", "enchant")
