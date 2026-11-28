extends Control

var continue_button: Button
var new_button: Button
var settings_button: Button
var status: Label
var confirmation: ConfirmationDialog
var _starting := false
var _portrait: TextureRect
var _content_root: Control
var _elapsed := 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	theme = InventoryMenu._panel.theme
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_content_root = Control.new()
	_content_root.size = Vector2(960,540)
	add_child(_content_root)
	var eyebrow := _label("T O W E R   O F", 32, InventoryMenu.GOLD)
	eyebrow.position = Vector2(0,50)
	eyebrow.size.x = 500
	_content_root.add_child(eyebrow)
	var title := _label("ARCANA", 66, Color("fff0c9"))
	title.position = Vector2(0,85)
	title.size.x = 500
	_content_root.add_child(title)
	var subtitle := _label("D A Y   &   N I G H T", 16, Color("bfabd9"))
	subtitle.position = Vector2(0,172)
	subtitle.size.x = 500
	_content_root.add_child(subtitle)
	_portrait = TextureRect.new()
	_portrait.position = Vector2(148,235)
	_portrait.size = Vector2(204,190)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var atlas := AtlasTexture.new()
	atlas.atlas = preload("res://assets/foxy/fox_hat/foxy_hat_full_sheet.png")
	atlas.region = Rect2(0,256,64,64)
	_portrait.texture = atlas
	_content_root.add_child(_portrait)
	var icons := HBoxContainer.new()
	icons.position = Vector2(178,437)
	icons.add_theme_constant_override("separation",16)
	for texture in [preload("res://assets/sprites/Pixel_Skill_Spell_Icons_v1.0/PNG/32x32/wind/wind_orb.png"),preload("res://assets/sprites/Pixel_Skill_Spell_Icons_v1.0/PNG/32x32/lightning/lightning_orb.png"),preload("res://assets/sprites/item/RavenmoreIconPack2023/RavenmoreIconPack2023/64/PotionRed.png"),preload("res://assets/sprites/item/RavenmoreIconPack2023/RavenmoreIconPack2023/64/PotionBlue.png")]:
		var icon := TextureRect.new()
		icon.texture = texture
		icon.custom_minimum_size = Vector2(24,24)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icons.add_child(icon)
	_content_root.add_child(icons)
	var panel := PanelContainer.new()
	panel.name = "TitlePanel"
	panel.position = Vector2(530,38)
	panel.size = Vector2(390,464)
	panel.add_theme_stylebox_override("panel", InventoryMenu._skin("panel_stone", 28))
	_content_root.add_child(panel)
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation",12)
	panel.add_child(box)
	box.add_child(_label("HÀNH TRÌNH CỦA FOXY", 18, InventoryMenu.GOLD))
	box.add_child(HSeparator.new())
	continue_button = _button("Tiếp tục", _continue_game)
	continue_button.name = "Continue"
	box.add_child(continue_button)
	new_button = _button("Chơi mới", _ask_new_game)
	new_button.name = "NewGame"
	box.add_child(new_button)
	settings_button = _button("Cài đặt", _settings)
	settings_button.name = "Settings"
	box.add_child(settings_button)
	if not OS.has_feature("web"):
		box.add_child(_button("Thoát", func(): get_tree().quit()))
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	box.add_child(spacer)
	status = _label("", 14, Color("e3d8c2"))
	status.custom_minimum_size.y = 42
	status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	box.add_child(status)
	var footer := _label("WASD  ·  Di chuyển     /     Chuột  ·  Ngắm kỹ năng", 14, Color("b0aabf"))
	footer.position = Vector2(0,510)
	footer.size.x = 960
	_content_root.add_child(footer)
	confirmation = ConfirmationDialog.new()
	confirmation.title = "Bắt đầu hành trình mới?"
	confirmation.dialog_text = "Tiến trình checkpoint hiện tại sẽ được thay thế."
	confirmation.ok_button_text = "Chơi mới"
	confirmation.cancel_button_text = "Quay lại"
	confirmation.confirmed.connect(_new_game)
	add_child(confirmation)
	GameManager.scene_change_failed.connect(_start_failed)
	_refresh_continue()
	(continue_button if not continue_button.disabled else new_button).grab_focus()
	get_viewport().size_changed.connect(_layout)
	_layout()

func _layout() -> void:
	var viewport := get_viewport().get_visible_rect().size
	var factor := minf(viewport.x / 1000.0, viewport.y / 580.0)
	_content_root.scale = Vector2.ONE * factor
	_content_root.position = (viewport-Vector2(960,540)*factor)*0.5
	queue_redraw()

func _draw() -> void:
	var viewport := get_viewport().get_visible_rect().size
	draw_rect(Rect2(Vector2.ZERO,viewport),Color("101421"))
	var glow := Vector2(viewport.x*0.28,viewport.y*0.52)
	for i in range(12,0,-1):
		draw_circle(glow, float(i)*viewport.y*0.055,Color(0.28,0.16,0.42,0.016))
	for i in 50:
		var at := Vector2(fposmod(float(i)*173.3,viewport.x), fposmod(float(i)*97.7,viewport.y))
		draw_circle(at,1.0,Color(0.77,0.66,0.93,0.12+0.1*sin(_elapsed+float(i))))
	var base := viewport.y*0.88
	for i in 10:
		var x := float(i)*viewport.x/9.0
		var height := viewport.y*(0.13+0.03*sin(float(i)*3.1))
		draw_rect(Rect2(x,base-height,viewport.x*0.065,height),Color("151b2a"))
		draw_colored_polygon(PackedVector2Array([Vector2(x-5,base-height),Vector2(x+viewport.x*0.032,base-height-30),Vector2(x+viewport.x*0.07,base-height)]),Color("151b2a"))

func _process(delta: float) -> void:
	_elapsed += delta
	var atlas := _portrait.texture as AtlasTexture
	# Reuse Foxy's idle_down frames16/20 from player_anims.tres.
	atlas.region.position.y = 256.0 + float(int(_elapsed / 0.3) % 2) * 64.0
	_portrait.position.y = 235.0+sin(_elapsed*1.6)*3.0
	queue_redraw()

func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label

func _button(value: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = value
	button.custom_minimum_size.y = 52
	button.pressed.connect(func():
		PauseMenu._preview_sound("UI")
		action.call())
	return button

func _refresh_continue() -> void:
	continue_button.disabled = not SaveSystem.has_save() or GameManager.has_checkpoint_conflict()
	status.text = "Nhấn Chơi mới để bắt đầu hành trình." if not SaveSystem.has_save() else "Tiếp tục từ checkpoint gần nhất."
	if SaveSystem.has_save() and GameManager.has_checkpoint_conflict():
		status.text = "Checkpoint chưa tương thích. Có thể bắt đầu hành trình mới."

func _continue_game() -> void:
	if _starting or continue_button.disabled: return
	_starting = true
	GameManager.continue_game()
	if not GameManager.is_changing(): _start_failed()

func _ask_new_game() -> void:
	if _starting: return
	if SaveSystem.has_save():
		confirmation.popup_centered(Vector2i(mini(380,int(get_viewport().get_visible_rect().size.x)-24),150))
	else:
		_new_game()

func _new_game() -> void:
	if _starting: return
	_starting = true
	GameManager.new_game()

func _settings() -> void:
	if not _starting:
		PauseMenu.open_title_settings()

func _start_failed() -> void:
	_starting = false
	_refresh_continue()
