extends Node3D
## Scene-local farm. Persisted in GameManager flags with the same save as SP.
const CROPS := ["broccoli", "cucumber", "spinach", "pineapple"]
const NAMES := ["Bông cải", "Dưa leo", "Rau bina", "Dứa"]
const GROW_SECONDS := 90.0
const FARM_KEY := "garden_farm_v1"
const CROP_ROOT := "res://assets/vendor/free_pixel_farm_crops/crops/x1/"
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
	for child in get_parent().get_node("Markers").get_children():
		if child is Node3D and str(child.name).begins_with("Plot_"):
			plots.append(child)
			var sprite := Sprite3D.new()
			sprite.position.y = 0.55
			sprite.pixel_size = 0.065
			sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
			sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			child.add_child(sprite)
			sprites[str(child.name)] = sprite
	_make_merchant()
	_make_ui()
	_update_crops()

func _make_merchant() -> void:
	var merchant := Node3D.new()
	merchant.name = "SeedMerchant"
	merchant.position = Vector3(10, 1.0, 14)
	add_child(merchant)
	var body := MeshInstance3D.new()
	var mesh := CapsuleMesh.new()
	mesh.radius = 0.32
	mesh.height = 1.3
	body.mesh = mesh
	body.position.y = 0.65
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.45, 0.26, 0.12)
	body.material_override = material
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
	hint.position = Vector2(20, 110)
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
	title = Label.new()
	title.add_theme_font_size_override("font_size", 20)
	title.add_theme_color_override("font_color", InventoryMenu.GOLD)
	title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(title)
	choices = VBoxContainer.new()
	choices.add_theme_constant_override("separation", 6)
	box.add_child(choices)
	var close := Button.new()
	close.text = "Đóng · F / Esc"
	close.pressed.connect(_close)
	box.add_child(close)
	get_viewport().size_changed.connect(_layout_ui)
	_layout_ui()
	panel.hide()

func _layout_ui() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var factor := maxf(0.1, minf(viewport_size.x / 960.0, viewport_size.y / 540.0))
	ui_root.scale = Vector2.ONE * factor
	ui_root.size = viewport_size / factor
	panel.size = Vector2(530, 430)
	panel.position = (ui_root.size - panel.size) * 0.5

func _process(delta: float) -> void:
	refresh_timer += delta
	if refresh_timer >= 0.5:
		refresh_timer = 0.0
		_update_crops()
	if opened or not player.can_interact():
		hint.text = ""
		return
	var near := _nearest()
	if near == null:
		hint.text = ""
	elif near == $SeedMerchant:
		hint.text = "F: Mua hạt giống (1 SP / hạt)"
	else:
		var planted: Dictionary = data.plots.get(str(near.name), {})
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
	if opened:
		if event.is_action_pressed("interact") or event.is_action_pressed("ui_cancel"):
			_close()
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
		var planted: Dictionary = data.plots.get(str(near.name), {})
		if planted.is_empty():
			_open(near)
		elif Time.get_unix_time_from_system() - float(planted.get("planted_at", 0)) >= GROW_SECONDS:
			_harvest(near)

func _open(plot: Node3D) -> void:
	target_plot = plot
	shop_mode = plot == null
	opened = true
	player.start_talk()
	old_mouse = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	panel.show()
	_refresh_menu()

func _close() -> void:
	if not opened:
		return
	opened = false
	panel.hide()
	Input.mouse_mode = old_mouse
	if is_instance_valid(player):
		player.finish_talk()

func _exit_tree() -> void:
	_close()

func _refresh_menu() -> void:
	for child in choices.get_children():
		choices.remove_child(child)
		child.queue_free()
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
		button.disabled = GameManager.has_checkpoint_conflict() or (GameManager.skill_points < 1 if shop_mode else count < 1)
		button.pressed.connect(func(): _choose(index))
		choices.add_child(button)

func _choose(index: int) -> void:
	if GameManager.has_checkpoint_conflict():
		return
	var crop: String = CROPS[index]
	if shop_mode:
		if GameManager.skill_points < 1:
			return
		GameManager.skill_points -= 1
		GameManager.flags["farm_seed_spent"] = int(GameManager.flags.get("farm_seed_spent", 0)) + 1
		data.seeds[crop] = int(data.seeds.get(crop, 0)) + 1
		_save()
		GameManager.skill_progress_changed.emit()
		_refresh_menu()
	elif is_instance_valid(target_plot) and not data.plots.has(str(target_plot.name)) and int(data.seeds.get(crop, 0)) > 0:
		data.seeds[crop] = int(data.seeds[crop]) - 1
		data.plots[str(target_plot.name)] = {"crop": crop, "planted_at": Time.get_unix_time_from_system()}
		_save()
		_update_crops()
		_close()

func _harvest(plot: Node3D) -> void:
	if GameManager.has_checkpoint_conflict():
		return
	var record: Dictionary = data.plots.get(str(plot.name), {})
	var crop := str(record.get("crop", ""))
	if crop not in CROPS or Time.get_unix_time_from_system() - float(record.get("planted_at", 0)) < GROW_SECONDS:
		return
	data.produce[crop] = int(data.produce.get(crop, 0)) + 1
	data.plots.erase(str(plot.name))
	_save()
	_update_crops()

func _save() -> void:
	GameManager.flags[FARM_KEY] = data.duplicate(true)
	GameManager.save_game()

func _update_crops() -> void:
	for plot in plots:
		var sprite: Sprite3D = sprites[str(plot.name)]
		var record: Dictionary = data.plots.get(str(plot.name), {})
		var crop := str(record.get("crop", ""))
		if crop not in CROPS:
			sprite.texture = null
			continue
		var elapsed := maxf(0.0, Time.get_unix_time_from_system() - float(record.get("planted_at", 0)))
		var stage := "stage0_seed" if elapsed < 30.0 else ("stage1_sprout" if elapsed < 60.0 else ("stage2_growing" if elapsed < GROW_SECONDS else "stage4_harvest"))
		var path := CROP_ROOT + crop + "/" + crop + "_" + stage + ".png"
		if sprite.texture == null or sprite.texture.resource_path != path:
			sprite.texture = load(path)
