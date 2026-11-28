extends CanvasLayer
## Owned by GameManager so the cover survives replacement of the current scene.
signal finished(success: bool)
signal processing_frame
const MIN_DISPLAY_SECONDS := 0.45
var busy := false
var _error := false
var _root: Control
var _design: Control
var _card: PanelContainer
var _portrait: TextureRect
var _heading: Label
var _destination: Label
var _status: Label
var _progress: ProgressBar
var _percent: Label
var _back: Button
var _elapsed := 0.0
var _started_at := 0
var _restore_pause := false
var _previous_mouse := Input.MOUSE_MODE_VISIBLE

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 180
	_root = Control.new()
	_root.name = "SceneLoading"
	_root.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_root.theme = InventoryMenu._panel.theme
	add_child(_root)
	var shade := ColorRect.new()
	shade.color = Color("101421")
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_root.add_child(shade)
	_design = Control.new()
	_design.size = Vector2(960,540)
	_root.add_child(_design)
	var brand := _label("T O W E R   O F   A R C A N A",18,InventoryMenu.GOLD)
	brand.position = Vector2(0,65)
	brand.size.x = 960
	_design.add_child(brand)
	_card = PanelContainer.new()
	_card.position = Vector2(150,120)
	_card.size = Vector2(660,310)
	_card.add_theme_stylebox_override("panel",InventoryMenu._skin("panel_stone",30))
	_design.add_child(_card)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",14)
	_card.add_child(column)
	_heading = _label("HÀNH TRÌNH TIẾP DIỄN",22,InventoryMenu.GOLD)
	column.add_child(_heading)
	column.add_child(HSeparator.new())
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation",24)
	column.add_child(row)
	_portrait = TextureRect.new()
	_portrait.custom_minimum_size = Vector2(96,96)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var atlas := AtlasTexture.new()
	atlas.atlas = preload("res://assets/foxy/fox_hat/foxy_hat_full_sheet.png")
	atlas.region = Rect2(0,256,64,64)
	_portrait.texture = atlas
	row.add_child(_portrait)
	var details := VBoxContainer.new()
	details.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	details.add_theme_constant_override("separation",10)
	row.add_child(details)
	_destination = _label("",24,Color("fff0c9"))
	_destination.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	details.add_child(_destination)
	_status = _label("Đang chuẩn bị…",16,Color("cbbbdc"))
	_status.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size.y = 28
	details.add_child(_status)
	var meter := HBoxContainer.new()
	meter.add_theme_constant_override("separation",12)
	details.add_child(meter)
	_progress = ProgressBar.new()
	_progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_progress.custom_minimum_size = Vector2(0,14)
	_progress.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	_progress.show_percentage = false
	_progress.add_theme_stylebox_override("background",PauseMenu._style(Color("101421"),Color("76634f"),0))
	_progress.add_theme_stylebox_override("fill",PauseMenu._style(Color("dbc38a"),InventoryMenu.GOLD,0))
	meter.add_child(_progress)
	_percent = _label("0%",15,InventoryMenu.GOLD)
	_percent.custom_minimum_size.x = 46
	meter.add_child(_percent)
	_back = Button.new()
	_back.text = "Quay lại"
	_back.custom_minimum_size.y = 44
	_back.pressed.connect(_cancel_failed_load)
	column.add_child(_back)
	_back.hide()
	var footer := _label("D A Y   &   N I G H T",14,Color("b0aabf"))
	footer.position = Vector2(0,470)
	footer.size.x = 960
	_design.add_child(footer)
	get_viewport().size_changed.connect(_layout)
	_layout()
	_root.hide()

func _label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	return label

func _layout() -> void:
	var viewport := get_viewport().get_visible_rect().size
	_root.size = viewport
	var factor := minf(viewport.x/1000.0,viewport.y/580.0)
	_design.scale = Vector2.ONE*factor
	_design.position = (viewport-Vector2(960,540)*factor)*0.5

func _input(_event: InputEvent) -> void:
	if busy and not _error:
		get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	# Unlike SceneTree.process_frame / frame_post_draw, this is not emitted while
	# the editor suspends the game. Pause writes must resume from this callback.
	processing_frame.emit()
	if not busy: return
	_elapsed += delta
	(_portrait.texture as AtlasTexture).region.position.y = 256.0+float(int(_elapsed/0.3)%2)*64.0
	_percent.text = "%d%%" % roundi(_progress.value)

func start(path: String) -> void:
	if busy: return
	busy = true
	_error = false
	_elapsed = 0.0
	_started_at = Time.get_ticks_msec()
	_previous_mouse = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_root.modulate = Color.WHITE
	_root.show()
	_back.hide()
	_progress.show()
	_percent.show()
	_progress.value = 0
	_heading.text = "HÀNH TRÌNH TIẾP DIỄN"
	var names := {"basement_full":"Hầm ngục", "basement_b3":"Hầm ngục · Tầng 3", "garden":"Khu vườn", "castle":"Lâu đài", "main_menu":"Menu chính"}
	_destination.text = names.get(path.get_file().get_basename(),"Hành trình của Foxy")
	_status.text = "Đang chuẩn bị…"
	_load.call_deferred(path)

func set_pause_safely(value: bool, from_menu: bool = false) -> void:
	await processing_frame
	# Closing a persistent menu relinquishes its pause to the loading cover.
	if from_menu and busy and not value: return
	get_tree().paused = value

func _load(path: String) -> void:
	# Present an opaque frame before any resource work or scene instantiation.
	await RenderingServer.frame_post_draw
	await processing_frame
	# Acquire pause before menus close; their resume requests cannot briefly
	# release gameplay while the cover is taking over. This is a normal process callback.
	var menu_owns_pause := PauseMenu.is_open or PauseMenu._closing or InventoryMenu.is_open or InventoryMenu._closing or bool(InventoryMenu._cheat_menu.is_open) or bool(InventoryMenu._cheat_menu._closing)
	_restore_pause = get_tree().paused and not menu_owns_pause
	get_tree().paused = true
	await PauseMenu.close_menu()
	await InventoryMenu.close_menu()
	await InventoryMenu._cheat_menu.close_menu()
	while PauseMenu._closing or InventoryMenu._closing or bool(InventoryMenu._cheat_menu._closing):
		await processing_frame
	var error := ResourceLoader.load_threaded_request(path)
	if error != OK:
		_fail(path)
		return
	while true:
		var progress: Array = []
		var status := ResourceLoader.load_threaded_get_status(path,progress)
		if not progress.is_empty(): _progress.value = maxf(_progress.value,float(progress[0])*90.0)
		if status == ResourceLoader.THREAD_LOAD_LOADED: break
		if status in [ResourceLoader.THREAD_LOAD_FAILED,ResourceLoader.THREAD_LOAD_INVALID_RESOURCE]:
			_fail(path)
			return
		_status.text = "Đang chuẩn bị"+".".repeat(1+int(_elapsed*3.0)%3)
		await get_tree().process_frame
	var packed := ResourceLoader.load_threaded_get(path) as PackedScene
	if packed == null:
		_fail(path)
		return
	_progress.value = 95
	_status.text = "Đang mở hành trình…"
	var remaining := MIN_DISPLAY_SECONDS-float(Time.get_ticks_msec()-_started_at)/1000.0
	if remaining>0: await get_tree().create_timer(remaining).timeout
	# This continuation runs after a rendered frame, outside physics callbacks.
	await processing_frame
	error = get_tree().change_scene_to_packed(packed)
	if error != OK:
		_fail(path)
		return
	await get_tree().scene_changed
	await RenderingServer.frame_post_draw
	_progress.value = 100
	_status.text = "Đã sẵn sàng"
	await get_tree().create_timer(0.1).timeout
	var fade := create_tween()
	fade.tween_property(_root,"modulate:a",0.0,0.18)
	await fade.finished
	await set_pause_safely(false)
	_root.hide()
	busy = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	finished.emit(true)

func _fail(path: String) -> void:
	push_warning("Scene loading failed: "+path)
	_error = true
	_heading.text = "CHƯA THỂ TIẾP TỤC"
	_status.text = "Chưa mở được khu vực này. Hãy quay lại và thử lần nữa."
	_progress.hide()
	_percent.hide()
	_back.show()
	_back.grab_focus()

func _cancel_failed_load() -> void:
	if not _error: return
	_error = false
	await set_pause_safely(_restore_pause)
	_root.hide()
	busy = false
	Input.mouse_mode = _previous_mouse
	finished.emit(false)
