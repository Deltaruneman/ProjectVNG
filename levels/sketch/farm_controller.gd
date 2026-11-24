extends Node3D
## Scene-local farm. Persisted in GameManager flags with the same save as SP.
const CROPS := ["broccoli", "cucumber", "spinach", "pineapple"]
const NAMES := ["Bông cải", "Dưa leo", "Rau bina", "Dứa"]
const GROW_SECONDS := 90.0
const FARM_KEY := "garden_farm_v1"
const CROP_ROOT := "res://assets/vendor/free_pixel_farm_crops/crops/x1/"
@export var plots_path: NodePath = NodePath("../Markers")
@export var plot_key_prefix := ""
@export var merchant_position := Vector3(10, 1, 14)
var menu_page := "shop"
var talking := false
var requested_shop := false
var scroll: ScrollContainer
var close_button: Button
var data: Dictionary
var plots: Array[Node3D] = []
var sprites: Dictionary = {}
var panel: PanelContainer
var ui_root: Control
var title: Label
var choices: VBoxContainer
var hint: Label
var target_plot: Node3D
var shop_mode := false
var opened := false
var old_mouse := Input.MOUSE_MODE_VISIBLE
var refresh_timer := 0.0
@onready var player: Player = get_parent().get_node("Player")

func _ready() -> void:
	var saved: Variant = GameManager.flags.get(FARM_KEY, {})
	data = saved.duplicate(true) if saved is Dictionary else {}
	for key in ["seeds", "produce", "plots"]:
		if not data.get(key) is Dictionary:
			data[key] = {}
	for child in get_node(plots_path).get_children():
		if child is Node3D and str(child.name).begins_with("Plot_"):
			plots.append(child)
			var sprite := Sprite3D.new()
			sprite.position.y = 0.55
			sprite.pixel_size = 0.065
			sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			child.add_child(sprite)
			sprites[_plot_key(child)] = sprite
	_make_merchant()
	_make_ui()
	_update_crops()

func _make_merchant() -> void:
	var merchant := Node3D.new()
	merchant.name = "SeedMerchant"
	merchant.position = merchant_position
	add_child(merchant)
	var body := Sprite3D.new()
	body.texture = preload("res://assets/monsters/mushroom/mushroom_sprite_sheet.png")
	body.hframes = 3
	body.vframes = 6
	body.frame = 1
	body.pixel_size = 0.055
	body.position.y = 0.8
	body.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	body.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	merchant.add_child(body)
	var label := Label3D.new()
	label.text = "Người bán hạt giống"
	label.position.y = 1.65
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 40
	label.outline_size = 10
	merchant.add_child(label)

func _make_ui() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 110
	add_child(canvas)
	ui_root = Control.new()
	ui_root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	ui_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	canvas.add_child(ui_root)
	hint = Label.new()
	hint.position = Vector2(20, 90)
	hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	hint.add_theme_font_size_override("font_size", 20)
	ui_root.add_child(hint)
	panel = PanelContainer.new()
	panel.name = "FarmPanel"
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.add_theme_stylebox_override("panel", InventoryMenu._skin("panel_stone", 18))
	panel.theme = InventoryMenu._panel.theme
	ui_root.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	panel.add_child(box)
	scroll = ScrollContainer.new()
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.follow_focus = true
	box.add_child(scroll)
	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 10)
	scroll.add_child(content)
	title = Label.new()
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", InventoryMenu.GOLD)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(title)
	choices = VBoxContainer.new()
	choices.add_theme_constant_override("separation", 6)
	content.add_child(choices)
	close_button = Button.new()
	close_button.text = "Rời đi · Esc"
	close_button.pressed.connect(_back)
	box.add_child(close_button)
	get_viewport().size_changed.connect(_layout_ui)
	_layout_ui()
	panel.hide()

func _layout_ui() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var factor := maxf(0.1, minf(viewport_size.x / 960.0, viewport_size.y / 540.0))
	ui_root.scale = Vector2.ONE * factor
	ui_root.size = viewport_size / factor
	panel.size = Vector2(minf(560, ui_root.size.x - 32), minf(480, ui_root.size.y - 32))
	hint.size.x = ui_root.size.x - 40
	panel.position = (ui_root.size - panel.size) * 0.5

func _process(delta: float) -> void:
	refresh_timer += delta
	if refresh_timer >= 0.5:
		refresh_timer = 0.0
		_update_crops()
	if opened or talking or not player.can_interact():
		hint.text = ""
		return
	var near := _nearest()
	if near == null:
		hint.text = ""
	elif near == $SeedMerchant:
		hint.text = "F: Nói chuyện với người bán hạt giống"
	else:
		var planted: Dictionary = data.plots.get(_plot_key(near), {})
		if planted.is_empty():
			hint.text = "F: Chọn hạt và trồng"
		else:
			var left := maxf(0.0, GROW_SECONDS - (Time.get_unix_time_from_system() - float(planted.get("planted_at", 0))))
			hint.text = "F: Thu hoạch" if left <= 0.0 else "Đang lớn: %d giây" % ceili(left)

func _nearest() -> Node3D:
	var nearest: Node3D = null
	var best := 1.55
	for node: Node3D in plots + [$SeedMerchant]:
		var p := node.global_position - player.global_position
		var distance := Vector2(p.x, p.z).length()
		if distance < best:
			best = distance
			nearest = node
	return nearest

func _unhandled_input(event: InputEvent) -> void:
	if talking:
		if event.is_action_pressed("ui_cancel") and not event.is_echo():
			requested_shop = false
			Dialogic.end_timeline(true)
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("interact") and not event.is_echo():
			if Dialogic.current_state == Dialogic.States.AWAITING_CHOICE:
				Dialogic.Choices.select_focused_choice()
			elif Dialogic.current_state == Dialogic.States.REVEALING_TEXT:
				Dialogic.Text.skip_text_reveal()
			elif Dialogic.current_state == Dialogic.States.IDLE:
				Dialogic.handle_next_event()
			get_viewport().set_input_as_handled()
		return
	if opened:
		if event.is_action_pressed("ui_cancel") and not event.is_echo():
			_back()
			get_viewport().set_input_as_handled()
		elif event.is_action_pressed("interact") and not event.is_echo():
			var focused := get_viewport().gui_get_focus_owner() as Button
			if focused != null and not focused.disabled and panel.is_ancestor_of(focused):
				focused.pressed.emit()
			get_viewport().set_input_as_handled()
		return
	if not event.is_action_pressed("interact") or event.is_echo() or not player.can_interact():
		return
	var near := _nearest()
	if near == null:
		return
	get_viewport().set_input_as_handled()
	if near == $SeedMerchant:
		_open(null)
	else:
		var planted: Dictionary = data.plots.get(_plot_key(near), {})
		if planted.is_empty():
			_open(near)
		elif Time.get_unix_time_from_system() - float(planted.get("planted_at", 0)) >= GROW_SECONDS:
			_harvest(near)

func _talk() -> void:
	if talking or opened or not player.can_interact() or Dialogic.current_timeline != null:
		return
	talking = true
	requested_shop = false
	old_mouse = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	player.start_talk()
	Dialogic.signal_event.connect(_on_merchant_signal)
	Dialogic.Choices.use_input_action = true
	Dialogic.start("res://dialog/timelines/seed_merchant.dtl")
	await Dialogic.timeline_ended
	if Dialogic.signal_event.is_connected(_on_merchant_signal):
		Dialogic.signal_event.disconnect(_on_merchant_signal)
	talking = false
	Input.mouse_mode = old_mouse
	if is_instance_valid(player):
		player.finish_talk()
	if requested_shop and is_inside_tree() and not GameManager.is_changing():
		_open_shop.call_deferred()

func _on_merchant_signal(argument: Variant) -> void:
	if argument == "seed_shop" and talking:
		requested_shop = true

func _open_shop() -> void:
	if is_inside_tree() and player.can_interact():
		_open_panel(null)

func _open(plot: Node3D) -> void:
	if plot == null:
		_talk()
	else:
		_open_panel(plot)

func _open_panel(plot: Node3D) -> void:
	target_plot = plot
	shop_mode = plot == null
	menu_page = "shop" if shop_mode else "plant"
	opened = true
	player.start_talk()
	old_mouse = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	panel.show()
	_refresh_menu()

func _plot_key(plot: Node3D) -> String:
	return plot_key_prefix + str(plot.name)

func _back() -> void:
	var return_to_merchant := shop_mode
	_close()
	if return_to_merchant:
		_talk.call_deferred()

func _close() -> void:
	if not opened:
		return
	opened = false
	panel.hide()
	Input.mouse_mode = old_mouse
	if is_instance_valid(player):
		player.finish_talk()

func _exit_tree() -> void:
	requested_shop = false
	if talking:
		Dialogic.end_timeline(true)
		Input.mouse_mode = old_mouse
		if is_instance_valid(player):
			player.finish_talk()
	_close()

func _refresh_menu() -> void:
	for child in choices.get_children():
		choices.remove_child(child)
		child.queue_free()
	close_button.text = "Quay lại · Esc" if shop_mode else "Đóng · Esc"
	scroll.scroll_vertical = 0
	var stock := []
	for i in range(CROPS.size()):
		stock.append("%s: %d" % [NAMES[i], int(data.produce.get(CROPS[i], 0))])
	title.text = ("Mua hạt · %d SP\n" % GameManager.skill_points if shop_mode else "Chọn hạt để trồng\n") + "Đã thu hoạch: " + ", ".join(stock)
	for i in range(CROPS.size()):
		var index := i
		var count := int(data.seeds.get(CROPS[i], 0))
		var button := Button.new()
		button.text = "%s · hạt: %d%s" % [NAMES[i], count, " · mua 1 SP" if shop_mode else ""]
		button.icon = InventoryMenu._farm_icon("seeds", CROPS[i])
		button.expand_icon = true
		button.icon_alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = Vector2(0, 54)
		button.add_theme_constant_override("icon_max_width", 36)
		button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		button.disabled = GameManager.has_checkpoint_conflict() or (GameManager.skill_points < 1 if shop_mode else count < 1)
		button.pressed.connect(func(): _choose(index))
		choices.add_child(button)
	_focus_first.call_deferred()

func _focus_first() -> void:
	if not opened:
		return
	for button in choices.get_children():
		if button is Button and not button.disabled:
			button.grab_focus()
			return
	close_button.grab_focus()

func _choose(index: int) -> void:
	if GameManager.has_checkpoint_conflict():
		return
	var crop: String = CROPS[index]
	if shop_mode:
		if menu_page != "shop" or GameManager.skill_points < 1:
			return
		GameManager.skill_points -= 1
		GameManager.flags["farm_seed_spent"] = int(GameManager.flags.get("farm_seed_spent", 0)) + 1
		data.seeds[crop] = int(data.seeds.get(crop, 0)) + 1
		_save()
		GameManager.skill_progress_changed.emit()
		_refresh_menu()
	elif is_instance_valid(target_plot) and not data.plots.has(_plot_key(target_plot)) and int(data.seeds.get(crop, 0)) > 0:
		data.seeds[crop] = int(data.seeds[crop]) - 1
		data.plots[_plot_key(target_plot)] = {"crop": crop, "planted_at": Time.get_unix_time_from_system()}
		_save()
		_update_crops()
		_close()

func _harvest(plot: Node3D) -> void:
	if GameManager.has_checkpoint_conflict():
		return
	var record: Dictionary = data.plots.get(_plot_key(plot), {})
	var crop := str(record.get("crop", ""))
	if crop not in CROPS or Time.get_unix_time_from_system() - float(record.get("planted_at", 0)) < GROW_SECONDS:
		return
	data.produce[crop] = int(data.produce.get(crop, 0)) + 1
	data.plots.erase(_plot_key(plot))
	_save()
	_update_crops()

func _save() -> void:
	GameManager.flags[FARM_KEY] = data.duplicate(true)
	GameManager.save_game()

func _update_crops() -> void:
	for plot in plots:
		var sprite: Sprite3D = sprites[_plot_key(plot)]
		var record: Dictionary = data.plots.get(_plot_key(plot), {})
		var crop := str(record.get("crop", ""))
		if crop not in CROPS:
			sprite.texture = null
			continue
		var elapsed := maxf(0.0, Time.get_unix_time_from_system() - float(record.get("planted_at", 0)))
		var stage := "stage0_seed" if elapsed < 30.0 else ("stage1_sprout" if elapsed < 60.0 else ("stage2_growing" if elapsed < GROW_SECONDS else "stage4_harvest"))
		var path := CROP_ROOT + crop + "/" + crop + "_" + stage + ".png"
		if sprite.texture == null or sprite.texture.resource_path != path:
			sprite.texture = load(path)
