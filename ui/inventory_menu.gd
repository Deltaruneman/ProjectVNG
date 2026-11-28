extends CanvasLayer
const CATALOG := preload("res://scripts/item_catalog.gd")
const CHEAT_MENU_SCRIPT := preload("res://ui/cheat_menu.gd")
const FARM_CROPS := {"broccoli": "Bông cải", "cucumber": "Dưa leo", "spinach": "Rau bina", "pineapple": "Dứa"}
const FARM_ICONS := "res://assets/vendor/free_pixel_farm_crops/icons/32px/x1/"
const GOLD := Color("f1e2b6")
const INK := Color("3f2419")
const SKIN_ROOT := "res://assets/ui/hearthmark/"
var is_open := false
var page := "equipment"
var selected := ""
var _previous_mouse := Input.MOUSE_MODE_VISIBLE
var _closing := false
var _root: Control
var _panel: PanelContainer
var _list: VBoxContainer
var _detail: VBoxContainer
var _balance: Label
var _status: Label
var _tabs: HBoxContainer
var _title: Label
var _skin_data: Dictionary = {}
var _skin_cache: Dictionary = {}
var _cheat_menu: CanvasLayer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 115
	_skin_data = JSON.parse_string(FileAccess.get_file_as_string(SKIN_ROOT + "slices.json"))
	_build()
	_cheat_menu = CHEAT_MENU_SCRIPT.new()
	_cheat_menu.name = "CheatMenu"
	add_child(_cheat_menu)
	get_viewport().size_changed.connect(_layout)
	get_tree().scene_changed.connect(close_menu)
	GameManager.inventory_changed.connect(_refresh)
	GameManager.skill_progress_changed.connect(_refresh_balance)
	GameManager.potion_use_rejected.connect(_show_potion_rejection)
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
	theme.set_stylebox("scroll", "VScrollBar", _skin("scroll_track", 3))
	for state in ["grabber", "grabber_highlight", "grabber_pressed"]:
		theme.set_stylebox(state, "VScrollBar", _skin("scroll_thumb", 3))
	_panel.theme = theme
	var body := VBoxContainer.new()
	body.add_theme_constant_override("separation", 10)
	_panel.add_child(body)
	var header := HBoxContainer.new()
	body.add_child(header)
	_title = _label("TÚI ĐỒ", 26)
	_title.add_theme_color_override("font_color", GOLD)
	_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(_title)
	_balance = _label("", 17)
	header.add_child(_balance)
	_button(header, "Đóng · Esc", close_menu)
	_tabs = HBoxContainer.new()
	body.add_child(_tabs)
	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 18)
	body.add_child(columns)
	_list = _scroll_column(columns, 1.25)
	_detail = _scroll_column(columns, 1.0, true)
	_status = _label("B · Túi đồ", 14)
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	body.add_child(_status)

func _scroll_column(parent: Control, ratio: float, parchment: bool = false) -> VBoxContainer:
	var holder := PanelContainer.new()
	holder.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	holder.size_flags_stretch_ratio = ratio
	holder.add_theme_stylebox_override("panel", _skin("panel_parchment", 16) if parchment else StyleBoxEmpty.new())
	parent.add_child(holder)
	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	holder.add_child(scroll)
	var column := VBoxContainer.new()
	column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	column.add_theme_constant_override("separation", 9)
	scroll.add_child(column)
	return column

func _label(value: String, font_size: int = 16) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	return label

func _paragraph(parent: Control, value: String) -> void:
	var label := _label(value)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	if parent == _detail:
		label.add_theme_color_override("font_color", INK)
	parent.add_child(label)

func _button(parent: Control, value: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = value
	button.alignment = HORIZONTAL_ALIGNMENT_LEFT
	button.pressed.connect(action)
	parent.add_child(button)
	return button

func _clear(parent: Node) -> void:
	for child in parent.get_children():
		parent.remove_child(child)
		child.queue_free()

func _layout() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var factor := maxf(0.1, minf(viewport_size.x / 960.0, viewport_size.y / 540.0))
	_root.scale = Vector2.ONE * factor
	_root.size = viewport_size / factor
	_panel.position = Vector2(18, 16)
	_panel.size = _root.size - Vector2(36, 32)

func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	if _closing:
		return
	if is_open:
		if event.is_action_pressed("inventory") or event.is_action_pressed("ui_cancel"):
			get_viewport().set_input_as_handled()
			close_menu()
		return
	if event.is_action_pressed("inventory"):
		get_viewport().set_input_as_handled()
		if bool(_cheat_menu.get("is_open")):
			_open_after_cheat("equipment")
		else:
			open_menu("equipment")

func _open_after_cheat(target: String) -> void:
	await _cheat_menu.call("close_menu")
	open_menu(target)

func open_menu(target: String = "equipment") -> bool:
	if is_open or _closing or get_tree().paused or GameManager.is_changing():
		return false
	var player := get_tree().get_first_node_in_group("player") as Player
	if player == null or player.health <= 0 or player.is_talking:
		return false
	var dialogic := get_node_or_null("/root/Dialogic")
	if dialogic != null and dialogic.get("current_timeline") != null:
		return false
	player._cancel_skill_aim()
	is_open = true
	page = target
	_previous_mouse = Input.mouse_mode
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_root.show()
	_refresh()
	return true

func close_menu() -> void:
	if not is_open or _closing:
		return
	_root.hide()
	_closing = true
	await get_tree().process_frame
	await get_tree().process_frame
	is_open = false
	_closing = false
	get_tree().paused = false
	Input.mouse_mode = _previous_mouse

func _show_page(target: String) -> void:
	page = target
	_refresh()

func _refresh_balance() -> void:
	if _balance != null:
		_balance.text = "%d SP" % GameManager.skill_points

func _refresh() -> void:
	if not is_open:
		return
	_refresh_balance()
	_layout.call_deferred()
	_clear(_tabs)
	_clear(_list)
	_clear(_detail)
	_title.text = "BÀN ENCHANT" if page == "enchant" else "TÚI ĐỒ"
	for entry in [["equipment", "Trang bị"], ["consumables", "Tiêu hao"], ["farm_items", "Nông sản"]]:
		var tab := _button(_tabs, entry[1], _show_page.bind(entry[0]))
		for state in ["normal", "hover", "pressed", "focus", "disabled"]:
			tab.add_theme_stylebox_override(state, _skin("tab_wood_active" if page == entry[0] else "tab_wood_inactive", 10))
		tab.add_theme_color_override("font_disabled_color", GOLD)
		tab.disabled = page == entry[0]
	if page == "enchant":
		_build_enchant()
		return
	if page == "farm_items":
		_build_farm_items()
		return
	if page == "equipment":
		_equipment_summary()
	_paragraph(_list, "VẬT PHẨM TRONG TÚI" if page == "equipment" else "VẬT PHẨM TIÊU HAO")
	var grid := GridContainer.new()
	grid.name = "InventoryGrid"
	grid.columns = 5
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	_list.add_child(grid)
	var found := false
	for uid: String in GameManager.inventory.items:
		var data := CATALOG.item(GameManager.inventory.items[uid].definition)
		if data.slot == "offhand":
			continue
		if (data.slot == "consumable") != (page == "consumables"):
			continue
		found = true
		_item_tile(grid, uid)
	if not found:
		_paragraph(_list, "Túi đang trống. P → Nhận bộ vật phẩm để thử.")
	var has_detail := false
	if GameManager.inventory.items.has(selected):
		var slot := str(CATALOG.item(GameManager.inventory.items[selected].definition).slot)
		if (slot == "consumable") == (page == "consumables"):
			_item_details(selected)
			has_detail = true
	if not has_detail:
		_paragraph(_detail, "CHỌN MỘT VẬT PHẨM")
		_paragraph(_detail, "Bấm vào ô đồ để xem đặc tính, trang bị hoặc sử dụng. Dấu ✓ cho biết vật phẩm đang mang.")

func _build_farm_items() -> void:
	var raw: Variant = GameManager.flags.get("garden_farm_v1", {})
	var farm: Dictionary = raw if raw is Dictionary else {}
	var seeds: Dictionary = farm.get("seeds", {}) if farm.get("seeds", {}) is Dictionary else {}
	var produce: Dictionary = farm.get("produce", {}) if farm.get("produce", {}) is Dictionary else {}
	for kind in ["seeds", "produce"]:
		_paragraph(_list, "HẠT GIỐNG" if kind == "seeds" else "NÔNG SẢN")
		var grid := GridContainer.new()
		grid.name = "FarmSeeds" if kind == "seeds" else "FarmProduce"
		grid.columns = 4
		grid.add_theme_constant_override("h_separation", 8)
		grid.add_theme_constant_override("v_separation", 8)
		_list.add_child(grid)
		var counts: Dictionary = seeds if kind == "seeds" else produce
		for crop: String in FARM_CROPS:
			_farm_tile(grid, kind, crop, maxi(0, int(counts.get(crop, 0))))
	var parts := selected.split(":")
	if parts.size() == 3 and parts[0] == "farm" and parts[1] in ["seeds", "produce"] and FARM_CROPS.has(parts[2]):
		var kind := str(parts[1])
		var crop := str(parts[2])
		var count := int((seeds if kind == "seeds" else produce).get(crop, 0))
		var art := TextureRect.new()
		art.texture = _farm_icon(kind, crop)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		art.custom_minimum_size = Vector2(100, 90)
		_detail.add_child(art)
		_paragraph(_detail, ("Hạt giống · " if kind == "seeds" else "Nông sản · ") + str(FARM_CROPS[crop]))
		_paragraph(_detail, "Số lượng: %d" % maxi(0, count))
		_paragraph(_detail, "Dùng F tại ô đất trống để trồng. Cây lớn sau 90 giây." if kind == "seeds" else "Thu hoạch từ cây đã trưởng thành trong khu vườn.")
	else:
		_paragraph(_detail, "CHỌN MỘT VẬT PHẨM")
		_paragraph(_detail, "Chọn hạt giống hoặc nông sản để xem số lượng và thông tin.")

func _farm_icon(kind: String, crop: String) -> Texture2D:
	var path := FARM_ICONS + ("seeds/" + crop + "_seeds.png" if kind == "seeds" else "products/" + crop + ".png")
	return load(path) as Texture2D

func _farm_tile(parent: Control, kind: String, crop: String, count: int) -> void:
	var id := "farm:%s:%s" % [kind, crop]
	var tile := _button(parent, "", _select.bind(id))
	tile.name = "Farm_%s_%s" % [kind, crop]
	tile.custom_minimum_size = Vector2(84, 94)
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var asset := "slot_selected" if selected == id or state in ["pressed", "focus"] else ("slot_hover" if state == "hover" else "slot_normal")
		tile.add_theme_stylebox_override(state, _skin(asset, 6))
	var icon := TextureRect.new()
	icon.texture = _farm_icon(kind, crop)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.position = Vector2(14, 8)
	icon.size = Vector2(56, 52)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(icon)
	var caption := _label(str(FARM_CROPS[crop]), 12)
	caption.position = Vector2(5, 65)
	caption.size = Vector2(74, 20)
	caption.clip_text = true
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(caption)
	var badge := _label(str(count), 14)
	badge.name = "Count"
	badge.position = Vector2(60, 3)
	badge.add_theme_color_override("font_color", GOLD)
	badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(badge)

func _equipment_summary() -> void:
	_paragraph(_list, "ĐANG TRANG BỊ")
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 8)
	_list.add_child(row)
	for slot: String in CATALOG.SLOTS:
		var column := VBoxContainer.new()
		row.add_child(column)
		var heading := _label(str(CATALOG.SLOTS[slot]), 12)
		heading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		column.add_child(heading)
		var uid := str(GameManager.inventory.equipped[slot])
		if uid != "":
			_item_tile(column, uid, true)
		else:
			var empty := _button(column, "—", func() -> void: pass)
			empty.custom_minimum_size = Vector2(84, 72)
			empty.add_theme_stylebox_override("normal", _skin("slot_normal", 6))
			empty.add_theme_stylebox_override("disabled", _skin("slot_normal", 6))
			empty.disabled = true

func _item_tile(parent: Control, uid: String, equipment: bool = false) -> void:
	var entry: Dictionary = GameManager.inventory.items[uid]
	var data := CATALOG.item(entry.definition)
	var tile := _button(parent, "", _select.bind(uid))
	tile.custom_minimum_size = Vector2(84, 72 if equipment else 94)
	tile.tooltip_text = ""
	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		var art := "slot_selected" if selected == uid or state in ["pressed", "focus"] else ("slot_hover" if state == "hover" else "slot_normal")
		tile.add_theme_stylebox_override(state, _skin(art, 6))
	var icon := TextureRect.new()
	icon.texture = CATALOG.texture(entry.definition)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.position = Vector2(14, 8)
	icon.size = Vector2(56, 52)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	tile.add_child(icon)
	if not equipment:
		var caption := _label(str(data.name).split(" · ")[0], 12)
		caption.position = Vector2(5, 65)
		caption.size = Vector2(74, 20)
		caption.clip_text = true
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(caption)
	if GameManager.inventory.equipped.values().has(uid) or data.slot == "consumable":
		var badge := _label("✓" if data.slot != "consumable" else str(entry.count), 14)
		badge.position = Vector2(60, 3)
		badge.add_theme_color_override("font_color", GOLD)
		badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
		tile.add_child(badge)

func _select(uid: String) -> void:
	if page == "equipment" and GameManager.inventory.items.has(uid) and CATALOG.item(GameManager.inventory.items[uid].definition).slot == "consumable":
		page = "consumables"
	selected = uid
	_refresh()

func _item_details(uid: String) -> void:
	var entry: Dictionary = GameManager.inventory.items[uid]
	var data := CATALOG.item(entry.definition)
	var art := TextureRect.new()
	art.texture = CATALOG.texture(entry.definition)
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	art.custom_minimum_size = Vector2(100, 90)
	_detail.add_child(art)
	_paragraph(_detail, str(data.name))
	_paragraph(_detail, str(data.description))
	for enchant: String in entry.enchants:
		_paragraph(_detail, "%s %d" % [CATALOG.ENCHANTS.get(enchant, {}).get("name", enchant), entry.enchants[enchant]])
	for enchant: String in entry.get("inactive_enchants", {}):
		_paragraph(_detail, "%s %d · Được giữ lại, không hoạt động" % [CATALOG.ENCHANTS.get(enchant, {}).get("name", enchant), entry.inactive_enchants[enchant]])
	if data.slot == "consumable":
		if GameManager.inventory.equipped.get("consumable", "") == uid:
			_button(_detail, "Bỏ khỏi ô Q", func() -> void: GameManager.unequip_item("consumable"))
		else:
			_button(_detail, "Gán vào ô Q", func() -> void: GameManager.equip_item(uid))
		if entry.definition != "venom_potion":
			_button(_detail, "Sử dụng", func() -> void:
				if GameManager.use_inventory_item(uid):
					_status.text = "Đã sử dụng.")
	else:
		if GameManager.inventory.equipped.values().has(uid):
			_button(_detail, "Tháo trang bị", func() -> void: GameManager.unequip_item(str(data.slot)))
		else:
			_button(_detail, "Trang bị", func() -> void: GameManager.equip_item(uid))

func _show_potion_rejection(reason: String) -> void:
	if is_open:
		_status.text = reason


func _build_enchant() -> void:
	_paragraph(_list, "Chọn một vũ khí trong túi.")
	for uid: String in GameManager.inventory.items:
		var data := CATALOG.item(GameManager.inventory.items[uid].definition)
		if data.slot == "main":
			_button(_list, str(data.name), _select.bind(uid))
	if not GameManager.inventory.items.has(selected) or str(CATALOG.item(GameManager.inventory.items[selected].definition).slot) != "main":
		_paragraph(_detail, "Chọn vũ khí để xem 3 lựa chọn ngẫu nhiên.")
		return
	var definition := CATALOG.item(GameManager.inventory.items[selected].definition)
	_paragraph(_detail, str(definition.name))
	var unlimited: bool = definition.get("unlimited_enchants", false)
	var line_count: int = GameManager.inventory.items[selected].enchants.size()
	_paragraph(_detail, "Blade: vô hạn dòng/cấp · SP theo cấp" if unlimited else "Đã có %d / 3 dòng · Cấp I / II / III: 1 / 2 / 3 SP" % line_count)
	var choices := GameManager.prepare_enchants(selected)
	if choices.is_empty():
		_paragraph(_detail, "Đã tối đa 3 dòng và cấp enchant cho vũ khí này.")
		return
	for index in 3:
		if index >= choices.size():
			var unavailable := _button(_detail, "Không còn lựa chọn", func() -> void: pass)
			unavailable.disabled = true
			continue
		var offer: Dictionary = choices[index]
		var enchant: Dictionary = CATALOG.ENCHANTS[offer.id]
		var button := _button(_detail, "%s %d · %d SP" % [enchant.name, offer.rank, offer.cost], _enchant.bind(selected, index, GameManager.inventory.offer_epoch))
		button.disabled = GameManager.skill_points < int(offer.cost)
		_paragraph(_detail, str(enchant.text))
	_paragraph(_detail, "Chỉ vũ khí có cộng hưởng mới nhận enchant nguyên tố.")

func _enchant(uid: String, index: int, epoch: int) -> void:
	_status.text = "Đã enchant vũ khí." if GameManager.enchant_weapon(uid, index, epoch) else "Lựa chọn hết hạn hoặc không đủ SP."
