extends VBoxContainer
const Catalog := preload("res://scripts/items/item_catalog.gd")
const Inventory := preload("res://scripts/items/item_inventory.gd")
const PACK := "res://assets/items/rpg-ui-pack-v1.1/rpg-ui-pack-v1.1/"
const PAPER := Color("f1e2b6")
const INK := Color("3b3142")
const FILTERS := ["Tất cả", "Vũ khí", "Giáp", "Bùa", "Tiêu hao"]
const FILTER_KINDS := ["", "weapon", "armor", "talisman", "consumable"]
var inventory: RefCounted
var player: Node
var _grid: GridContainer
var _filter_row: HBoxContainer
var _quick_name: Label
var _quick_icon: TextureRect
var _details_icon: TextureRect
var _details_title: Label
var _details_text: Label
var _equip_action: Button
var _quick_action: Button
var _selected := ""
var _filter := 0
var _slot_cards: Dictionary = {}
var _filter_buttons: Array[Button] = []

func configure(model: RefCounted, actor: Node) -> void:
	inventory = model
	player = actor
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	custom_minimum_size = Vector2(860, 400)
	add_theme_constant_override("separation", 9)
	_filter_row = HBoxContainer.new()
	_filter_row.add_theme_constant_override("separation", 5)
	add_child(_filter_row)
	for i in FILTERS.size():
		var tab := Button.new()
		tab.text = FILTERS[i]
		tab.custom_minimum_size.y = 32
		tab.add_theme_font_size_override("font_size", 13)
		tab.add_theme_stylebox_override("normal", _style("ui/tabs/tab_wood_inactive.png", 2, 2))
		tab.add_theme_stylebox_override("hover", _style("ui/tabs/tab_wood_active.png", 2, 2))
		tab.add_theme_stylebox_override("pressed", _style("ui/tabs/tab_wood_active.png", 2, 2))
		tab.pressed.connect(_set_filter.bind(i))
		_filter_buttons.append(tab)
		_filter_row.add_child(tab)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	add_child(body)
	var gear := VBoxContainer.new()
	gear.custom_minimum_size.x = 198
	gear.add_theme_constant_override("separation", 5)
	body.add_child(gear)
	var gear_title := _label("TRANG BỊ", 13, INK)
	gear.add_child(gear_title)
	for slot: String in Inventory.SLOTS:
		var card := _make_equipment_card(slot)
		_slot_cards[slot] = card
		gear.add_child(card)
	var quick_title := _label("Ô DÙNG NHANH · Q", 12, INK)
	gear.add_child(quick_title)
	var quick_card := _panel("ui/panels/panel_parchment.png", 5)
	quick_card.custom_minimum_size.y = 50
	gear.add_child(quick_card)
	var quick_row := HBoxContainer.new()
	quick_row.add_theme_constant_override("separation", 6)
	quick_card.add_child(quick_row)
	_quick_icon = _icon_rect(32)
	quick_row.add_child(_quick_icon)
	_quick_name = _label("—", 12, INK)
	_quick_name.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_quick_name.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_quick_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	quick_row.add_child(_quick_name)
	var right := VBoxContainer.new()
	right.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right.add_theme_constant_override("separation", 5)
	body.add_child(right)
	var heading := HBoxContainer.new()
	var inventory_title := _label("BALO ĐỒ", 14, INK)
	heading.add_child(inventory_title)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(spacer)
	var close_hint := _label("B · đóng", 11, INK)
	heading.add_child(close_hint)
	right.add_child(heading)
	var grid_scroll := ScrollContainer.new()
	grid_scroll.custom_minimum_size.y = 212
	grid_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	grid_scroll.clip_contents = true
	right.add_child(grid_scroll)
	_grid = GridContainer.new()
	_grid.columns = 8
	_grid.add_theme_constant_override("h_separation", 4)
	_grid.add_theme_constant_override("v_separation", 4)
	_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid_scroll.add_child(_grid)
	var detail := _panel("ui/panels/panel_parchment.png", 6)
	detail.custom_minimum_size.y = 94
	right.add_child(detail)
	var detail_row := HBoxContainer.new()
	detail_row.add_theme_constant_override("separation", 8)
	detail.add_child(detail_row)
	_details_icon = _icon_rect(48)
	detail_row.add_child(_details_icon)
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.add_theme_constant_override("separation", 2)
	detail_row.add_child(info)
	_details_title = _label("Chọn một món đồ", 14, INK)
	info.add_child(_details_title)
	_details_text = _label("Đồ bạn mang theo sẽ hiện ở đây.", 11, INK)
	_details_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_details_text.size_flags_vertical = Control.SIZE_EXPAND_FILL
	info.add_child(_details_text)
	var actions := VBoxContainer.new()
	actions.add_theme_constant_override("separation", 3)
	detail_row.add_child(actions)
	_equip_action = _small_button("Trang bị")
	_equip_action.pressed.connect(_equip_selected)
	actions.add_child(_equip_action)
	_quick_action = _small_button("Gán Q")
	_quick_action.pressed.connect(_assign_selected)
	actions.add_child(_quick_action)
	inventory.changed.connect(_refresh)
	_refresh()

func _style(relative_path: String, margin: int, content_margin: int = 3) -> StyleBoxTexture:
	var style := StyleBoxTexture.new()
	style.texture = load(PACK + relative_path) as Texture2D
	style.texture_margin_left = margin
	style.texture_margin_top = margin
	style.texture_margin_right = margin
	style.texture_margin_bottom = margin
	style.content_margin_left = content_margin
	style.content_margin_top = content_margin
	style.content_margin_right = content_margin
	style.content_margin_bottom = content_margin
	return style

func _panel(relative_path: String, margin: int) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	panel.add_theme_stylebox_override("panel", _style(relative_path, margin, margin))
	return panel

func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	return label

func _icon_rect(size: int) -> TextureRect:
	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(size, size)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	return icon

func _small_button(text: String) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(86, 33)
	button.add_theme_font_size_override("font_size", 11)
	button.add_theme_stylebox_override("normal", _style("ui/buttons/button_a_wood_normal.png", 4, 3))
	button.add_theme_stylebox_override("hover", _style("ui/buttons/button_a_wood_hover.png", 4, 3))
	button.add_theme_stylebox_override("pressed", _style("ui/buttons/button_a_wood_pressed.png", 4, 3))
	button.add_theme_stylebox_override("disabled", _style("ui/buttons/button_a_wood_disabled.png", 4, 3))
	return button

func _make_equipment_card(slot: String) -> Button:
	var card := Button.new()
	card.custom_minimum_size = Vector2(194, 60)
	card.add_theme_stylebox_override("normal", _style("ui/slots/slot_normal.png", 2, 3))
	card.add_theme_stylebox_override("hover", _style("ui/slots/slot_hover.png", 2, 3))
	card.add_theme_stylebox_override("pressed", _style("ui/slots/slot_selected.png", 2, 3))
	card.add_theme_stylebox_override("focus", _style("ui/slots/slot_selected.png", 2, 3))
	card.text = ""
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", 5)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	row.add_theme_constant_override("margin_left", 4)
	row.add_theme_constant_override("margin_right", 4)
	card.add_child(row)
	var icon := _icon_rect(34)
	icon.name = "ItemIcon"
	row.add_child(icon)
	var labels := VBoxContainer.new()
	labels.name = "Labels"
	labels.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	labels.alignment = BoxContainer.ALIGNMENT_CENTER
	labels.add_theme_constant_override("separation", 1)
	row.add_child(labels)
	var title := _label(Inventory.SLOTS[slot], 10, INK)
	title.name = "SlotName"
	labels.add_child(title)
	var name := _label("Trống", 11, INK)
	name.name = "ItemName"
	name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	labels.add_child(name)
	var remove := Button.new()
	remove.name = "Remove"
	remove.text = "×"
	remove.custom_minimum_size = Vector2(22, 24)
	remove.add_theme_font_size_override("font_size", 13)
	remove.add_theme_stylebox_override("normal", _style("ui/buttons/button_a_parchment_normal.png", 4, 1))
	remove.add_theme_stylebox_override("hover", _style("ui/buttons/button_a_parchment_hover.png", 4, 1))
	remove.add_theme_stylebox_override("pressed", _style("ui/buttons/button_a_parchment_pressed.png", 4, 1))
	remove.pressed.connect(func(): inventory.unequip(slot))
	row.add_child(remove)
	card.pressed.connect(func():
		var equipped_id := str(inventory.equipped.get(slot, ""))
		if equipped_id != "":
			_show_selected(equipped_id)
	)
	return card

func _set_filter(index: int) -> void:
	_filter = index
	_refresh()

func _refresh() -> void:
	for slot: String in Inventory.SLOTS:
		var card: Button = _slot_cards[slot]
		var id := str(inventory.equipped.get(slot, ""))
		var row := card.get_child(0) as HBoxContainer
		var icon := row.get_node("ItemIcon") as TextureRect
		var name := row.get_node("Labels/ItemName") as Label
		icon.texture = _item_icon(id)
		name.text = Catalog.item(id).get("name", "Trống")
		name.tooltip_text = Catalog.item(id).get("name", "")
		(row.get_node("Remove") as Button).disabled = id == ""
	var quick_id := str(inventory.quick_item)
	_quick_name.text = "%s ×%d" % [Catalog.item(quick_id).get("name", "Chưa gán"), int(inventory.counts.get(quick_id, 0))]
	_quick_icon.texture = _item_icon(quick_id)
	for i in _filter_buttons.size():
		_filter_buttons[i].add_theme_stylebox_override("normal", _style("ui/tabs/tab_wood_active.png" if i == _filter else "ui/tabs/tab_wood_inactive.png", 2, 2))
	for child in _grid.get_children():
		_grid.remove_child(child)
		child.queue_free()
	var visible_ids: Array[String] = []
	for id: String in Catalog.ITEMS:
		if int(inventory.counts.get(id, 0)) <= 0:
			continue
		var data: Dictionary = Catalog.ITEMS[id]
		var item_filter := str(data.get("slot", "consumable"))
		if _filter == 0 or item_filter == FILTER_KINDS[_filter]:
			visible_ids.append(id)
	for i in 32:
		if i < visible_ids.size():
			_grid.add_child(_make_item_slot(visible_ids[i]))
		else:
			var empty := TextureRect.new()
			empty.custom_minimum_size = Vector2(50, 50)
			empty.texture = load(PACK + "ui/slots/slot_normal.png") as Texture2D
			empty.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			empty.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			_grid.add_child(empty)
	if _selected not in visible_ids:
		_selected = visible_ids[0] if not visible_ids.is_empty() else ""
	if _selected.is_empty():
		_show_empty()
	else:
		_show_selected(_selected)

func _make_item_slot(id: String) -> Button:
	var button := Button.new()
	button.custom_minimum_size = Vector2(50, 50)
	button.text = ""
	button.tooltip_text = "%s ×%d" % [Catalog.item(id).name, int(inventory.counts.get(id, 0))]
	button.add_theme_stylebox_override("normal", _style("ui/slots/slot_normal.png", 2, 2))
	button.add_theme_stylebox_override("hover", _style("ui/slots/slot_hover.png", 2, 2))
	button.add_theme_stylebox_override("pressed", _style("ui/slots/slot_selected.png", 2, 2))
	button.add_theme_stylebox_override("focus", _style("ui/slots/slot_selected.png", 2, 2))
	var icon := _icon_rect(34)
	icon.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	icon.offset_left = -17
	icon.offset_top = -20
	icon.offset_right = 17
	icon.offset_bottom = 14
	icon.texture = _item_icon(id)
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(icon)
	var quantity := _label(str(inventory.counts[id]), 9, PAPER)
	quantity.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_RIGHT)
	quantity.offset_left = -22
	quantity.offset_top = -16
	quantity.offset_right = -3
	quantity.offset_bottom = -3
	quantity.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	quantity.add_theme_color_override("font_shadow_color", INK)
	quantity.add_theme_constant_override("shadow_offset_x", 1)
	quantity.add_theme_constant_override("shadow_offset_y", 1)
	quantity.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(quantity)
	button.pressed.connect(_show_selected.bind(id))
	return button

func _item_icon(id: String) -> Texture2D:
	if id.is_empty():
		return null
	var data := Catalog.item(id)
	return load(PACK + "icons/A/" + str(data.get("icon", "")) + ".png") as Texture2D

func _show_empty() -> void:
	_details_icon.texture = null
	_details_title.text = "Chưa có vật phẩm"
	_details_text.text = "Đồ nhặt được sẽ nằm trong chiếc túi này."
	_equip_action.disabled = true
	_quick_action.disabled = true

func _show_selected(id: String) -> void:
	if not Catalog.ITEMS.has(id) or int(inventory.counts.get(id, 0)) <= 0:
		return
	_selected = id
	var data := Catalog.item(id)
	var is_equipment: bool = data.kind == "equipment"
	_details_icon.texture = _item_icon(id)
	_details_title.text = "%s  ×%d" % [data.name, int(inventory.counts.get(id, 0))]
	_details_text.text = "%s  ·  %s" % [Inventory.SLOTS.get(data.get("slot", ""), "Tiêu hao"), data.description]
	if is_equipment and is_instance_valid(player):
		var old := Catalog.item(str(inventory.equipped.get(data.slot, "")))
		var effects: Dictionary = data.effects
		var old_effects: Dictionary = old.get("effects", {})
		var delta_attack := int(effects.get("attack", 0)) - int(old_effects.get("attack", 0))
		var delta_health := int(effects.get("health", 0)) - int(old_effects.get("health", 0))
		var delta_speed := float(effects.get("speed", 0.0)) - float(old_effects.get("speed", 0.0))
		var delta_parry := float(effects.get("parry", 0.0)) - float(old_effects.get("parry", 0.0))
		var changes: Array[String] = []
		if delta_attack != 0: changes.append("Sát thương %s%d" % ["+" if delta_attack > 0 else "", delta_attack])
		if delta_health != 0: changes.append("Máu tối đa %s%d" % ["+" if delta_health > 0 else "", delta_health])
		if not is_zero_approx(delta_speed): changes.append("Tốc độ %s%.1f" % ["+" if delta_speed > 0 else "", delta_speed])
		if not is_zero_approx(delta_parry): changes.append("Cửa sổ đỡ %s%.2fs" % ["+" if delta_parry > 0 else "", delta_parry])
		if not changes.is_empty():
			_details_text.text += "\n" + "  ·  ".join(changes)
	var is_equipped: bool = is_equipment and inventory.equipped.get(data.get("slot", ""), "") == id
	_equip_action.disabled = not is_equipment or is_equipped
	_equip_action.text = "Đang mặc" if is_equipped else "Trang bị"
	_quick_action.disabled = is_equipment or inventory.quick_item == id
	_quick_action.text = "Đang gán Q" if not is_equipment and inventory.quick_item == id else "Gán Q"

func _equip_selected() -> void:
	if not _selected.is_empty():
		inventory.equip(_selected)

func _assign_selected() -> void:
	if not _selected.is_empty():
		inventory.select_quick(_selected)
