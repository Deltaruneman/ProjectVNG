class_name PlayerHUD
extends CanvasLayer

const SKILL_ICON_ROOT := "res://assets/sprites/Pixel_Skill_Spell_Icons_v1.0/PNG/32x32/"
const BASIC_DAGGER_ICON := "res://assets/sprites/object/blade/blade_throw_1.png"
const SKILL_TREE_BOOK_ICON_SHEET := "res://assets/ui/craftpix-net-809047-free-animated-magic-book-pixel-art-asset-pack/PNG/Open_book.png"
const SKILL_TREE_BOOK_ICON_REGION := Rect2(829.0, 628.0, 246.0, 183.0)
const MENU_CANVAS_LAYER := 100

# Kích thước skill bar (chỉnh ở đây)
const SLOT_W := 29.0
const SLOT_H := 29.0
const SLOT_GAP := 2
const BAR_PAD := 2
const BAR_BOTTOM := 5.0
const DASH_SLOT := 4
const PARRY_SLOT := 5
const ULTIMATE_SLOT := 6
const SKILL_TREE_SLOT := 7
const SLOT_COUNT := 8
const DEFENSE_SLOT_W := 28.0
const DEFENSE_GROUP_GAP := 6.0
const LOW_HEALTH_VIGNETTE_SHADER := """
shader_type canvas_item;
uniform vec4 vignette_tint : source_color = vec4(0.92, 0.08, 0.12, 1.0);
uniform float pulse_alpha = 0.0;
uniform float edge_width = 0.12;

void fragment() {
	float edge_distance = min(min(UV.x, 1.0 - UV.x), min(UV.y, 1.0 - UV.y));
	float edge_mask = 1.0 - smoothstep(0.0, edge_width, edge_distance);
	COLOR = vec4(vignette_tint.rgb, vignette_tint.a * pulse_alpha * edge_mask);
}
"""

## Health bar ở góc trên-trái màn hình. Gắn script này vào một node CanvasLayer.
## - Nếu gán texture_progress (ảnh thanh máu đầy) trong Inspector -> dùng TextureProgressBar với ảnh của bạn.
## - Nếu chưa gán -> tự vẽ một thanh máu đơn giản bằng code (để vẫn có HUD khi chưa có asset).
## Tự tìm player qua group "player" và lắng nghe tín hiệu health_changed.

@export var margin: Vector2 = Vector2(24, 24)
@export var tween_time: float = 0.2

@export_group("Texture (pixel bar)")
## Ảnh nền/khung rỗng của thanh máu (có thể để trống)
@export var texture_under: Texture2D
## Ảnh phần máu đầy - BẮT BUỘC nếu muốn dùng ảnh
@export var texture_progress: Texture2D
## Ảnh viền/khung phủ lên trên cùng (có thể để trống)
@export var texture_over: Texture2D
## Phóng to pixel art theo số nguyên (2, 3, 4...) để giữ nét
@export var pixel_scale: float = 3.0
## Offset của phần máu so với ảnh nền, dùng khi ảnh progress nhỏ hơn ảnh under
@export var progress_offset: Vector2 = Vector2.ZERO
## Hiện chữ "3 / 3" đè lên thanh máu
@export var show_label: bool = false

@export_group("Fallback (không dùng ảnh)")
@export var bar_size: Vector2 = Vector2(240, 28)
@export var fill_color: Color = Color("e0453c")
@export var low_color: Color = Color("ff9d1f") ## Màu khi máu còn từ 1/3 trở xuống

var _bar: Range
var _label: Label
var _fill: StyleBoxFlat ## chỉ có ở chế độ fallback
var _tween: Tween
var _player: BaseCharacter
var _rage_bar: ProgressBar
var _rage_label: Label
var _skill_points_label: Label
var _skill_controls_label: Label
var _ultimate_skill_label: Label
var _low_health_warning: Label
var _low_health_vignette_layer: CanvasLayer
var _skill_tree_layer: CanvasLayer
var _vignette_material: ShaderMaterial
var _status_strip: HBoxContainer
var _skill_slot_panels: Array[PanelContainer] = []
var _skill_slot_styles: Array[StyleBoxFlat] = []
var _skill_slot_icons: Array[TextureRect] = []
var _skill_slot_placeholders: Array[Label] = []
var _skill_slot_cooldown_overlays: Array[ColorRect] = []
var _skill_slot_cooldown_labels: Array[Label] = []
var _status_chips: Array[PanelContainer] = []
var _status_chip_labels: Array[Label] = []
var _skill_icon_cache: Dictionary = {}
var _action_icon_cache: Dictionary = {}
var _critical_health_active := false
var _skill_tree_is_open := false
var _input_key_labels: Array[Label] = []


func _ready() -> void:
	layer = 1 # HUD gameplay; menu dùng PlayerHUD.MENU_CANVAS_LAYER
	add_to_group("hud")
	if texture_progress != null:
		_build_texture_bar()
	else:
		_build_flat_bar()
	_build_label()
	_build_low_health_warning()
	_build_status_strip()
	_skill_tree_layer = get_node_or_null("SkillTreeLayer") as CanvasLayer

	_player = get_tree().get_first_node_in_group("player") as BaseCharacter
	if _player == null:
		push_warning("PlayerHUD: không tìm thấy node nào thuộc group 'player'")
		return
	_player.health_changed.connect(_on_health_changed)
	_refresh(_player.health, _player.max_health, false)
	_skill_points_label = Label.new()
	_skill_points_label.position = Vector2(300, 10)
	_skill_points_label.size = Vector2(100, 12)
	_skill_points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	add_child(_skill_points_label)
	GameManager.skill_progress_changed.connect(_refresh_skill_points)
	_refresh_skill_points()
	if _player is Player:
		_rage_bar = get_node_or_null("RageMeter/RageBar") as ProgressBar
		_rage_label = get_node_or_null("RageMeter/RageLabel") as Label
		_build_skill_bar()
		(_player as Player).active_skill_slot_changed.connect(_on_active_skill_slot_changed)
		_on_active_skill_slot_changed((_player as Player).selected_active_slot, (_player as Player).get_selected_active_skill_id())
		GameManager.skill_progress_changed.connect(_refresh_skill_bar)
		_refresh_skill_points()
		if _rage_bar != null and _rage_label != null:
			_rage_bar.max_value = Player.MAX_RAGE
			(_player as Player).rage_changed.connect(_on_rage_changed)
			_on_rage_changed((_player as Player).rage, Player.MAX_RAGE)


## Gọi từ skill tree menu: hud.set_skill_bar_visible(false) khi mở, true khi đóng
func set_skill_bar_visible(value: bool) -> void:
	var bar := get_node_or_null("SkillBar")
	if bar != null:
		bar.visible = value


func set_skill_tree_open(open: bool) -> void:
	_skill_tree_is_open = open
	for child in get_children():
		if child == _skill_tree_layer:
			child.visible = open
			continue
		var show_child := not open
		if child == _low_health_warning or child == _low_health_vignette_layer:
			show_child = show_child and _critical_health_active
		child.visible = show_child


func _process(_delta: float) -> void:
	_refresh_skill_bar()
	_refresh_rage_label()
	_refresh_status_strip()
	if _critical_health_active:
		var pulse := 0.5 + 0.5 * sin(float(Time.get_ticks_msec()) * 0.007)
		if _low_health_warning != null:
			_low_health_warning.modulate.a = 0.65 + 0.35 * pulse
		if _vignette_material != null:
			_vignette_material.set_shader_parameter("pulse_alpha", 0.05 + 0.13 * pulse)


func _refresh_skill_points() -> void:
	if _skill_points_label != null:
		_skill_points_label.text = "✦ %d SP" % GameManager.skill_points


func _on_active_skill_slot_changed(slot: int, skill_id: String) -> void:
	_refresh_skill_bar()


func _build_skill_bar() -> void:
	var main_slot_count := SLOT_COUNT - 2
	var main_group_width := main_slot_count * SLOT_W + (main_slot_count - 1) * SLOT_GAP + 2.0 * (BAR_PAD + 1.0)
	var defense_group_width := 2.0 * DEFENSE_SLOT_W + SLOT_GAP + 2.0 * (BAR_PAD + 1.0)
	var bar_w := main_group_width + defense_group_width + DEFENSE_GROUP_GAP
	var bar_h := SLOT_H + 2.0 * (BAR_PAD + 1.0)
	var frame := HBoxContainer.new()
	frame.name = "SkillBar"
	var viewport_width := get_viewport().get_visible_rect().size.x
	var viewport_center_x := viewport_width * 0.5
	var local_center_x := transform.affine_inverse() * Vector2(viewport_center_x, 0.0)
	var center_anchor_x := local_center_x.x / viewport_width
	frame.alignment = BoxContainer.ALIGNMENT_CENTER
	frame.add_theme_constant_override("separation", int(DEFENSE_GROUP_GAP))
	frame.anchor_left = center_anchor_x
	frame.anchor_right = center_anchor_x
	frame.anchor_top = 1.0
	frame.anchor_bottom = 1.0
	frame.offset_left = -bar_w * 0.5
	frame.offset_right = bar_w * 0.5
	frame.offset_top = -(bar_h + BAR_BOTTOM)
	frame.offset_bottom = -BAR_BOTTOM
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(frame)

	var main_row := _create_skill_group(frame, "PrimarySkills", Color(0.015, 0.025, 0.035, 0.55), Color(0.19, 0.25, 0.28, 0.6))
	var defense_row := _create_skill_group(frame, "DefenseSkills", Color(0.018, 0.045, 0.055, 0.72), Color("4a929a"))
	for index in SLOT_COUNT:
		_create_skill_slot(index, defense_row if index == DASH_SLOT or index == PARRY_SLOT else main_row)


func _create_skill_group(parent: HBoxContainer, group_name: String, background: Color, border: Color) -> HBoxContainer:
	var panel := PanelContainer.new()
	panel.name = group_name
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	style.set_content_margin_all(BAR_PAD)
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	var row := HBoxContainer.new()
	row.add_theme_constant_override("separation", SLOT_GAP)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(row)
	return row


func _create_skill_slot(index: int, row: HBoxContainer) -> void:
	var slot_width := _skill_slot_width(index)
	var is_defense_slot := index == DASH_SLOT or index == PARRY_SLOT
	var slot := PanelContainer.new()
	slot.custom_minimum_size = Vector2(slot_width, SLOT_H)
	slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var slot_style := StyleBoxFlat.new()
	slot_style.bg_color = Color("17232c")
	slot_style.border_color = Color("68737a")
	slot_style.set_border_width_all(1)
	slot_style.set_corner_radius_all(3)
	slot.add_theme_stylebox_override("panel", slot_style)
	row.add_child(slot)
	_skill_slot_panels.append(slot)
	_skill_slot_styles.append(slot_style)

	var content := Control.new()
	content.custom_minimum_size = Vector2(slot_width - 4.0, SLOT_H - 4.0)
	content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot.add_child(content)
	var icon := TextureRect.new()
	icon.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon.offset_left = 1.0
	icon.offset_top = 8.0 if is_defense_slot else 0.0
	icon.offset_right = -1.0
	icon.offset_bottom = -2.0 if is_defense_slot else 0.0
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(icon)
	_skill_slot_icons.append(icon)

	var placeholder := Label.new()
	placeholder.set_anchors_preset(Control.PRESET_FULL_RECT)
	placeholder.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	placeholder.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	placeholder.add_theme_font_size_override("font_size", 11 if SLOT_W < 32.0 else 13)
	placeholder.add_theme_color_override("font_color", Color("ccd6dc"))
	placeholder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(placeholder)
	_skill_slot_placeholders.append(placeholder)

	var overlay := ColorRect.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.color = Color(0.01, 0.015, 0.02, 0.76)
	overlay.visible = false
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(overlay)
	_skill_slot_cooldown_overlays.append(overlay)

	var cooldown_label := Label.new()
	cooldown_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	cooldown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cooldown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	cooldown_label.add_theme_font_size_override("font_size", 9 if SLOT_W < 32.0 else 11)
	cooldown_label.add_theme_color_override("font_color", Color("ffffff"))
	cooldown_label.visible = false
	cooldown_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if is_defense_slot:
		cooldown_label.set_anchors_preset(Control.PRESET_TOP_RIGHT)
		cooldown_label.position = Vector2(-12.0, 0.0)
		cooldown_label.size = Vector2(12.0, 8.0)
		cooldown_label.add_theme_font_size_override("font_size", 6)
		cooldown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	content.add_child(cooldown_label)
	_skill_slot_cooldown_labels.append(cooldown_label)

	var key_label := Label.new()
	if is_defense_slot:
		key_label.position = Vector2(0.0, 0.0)
		key_label.size = Vector2(12.0, 8.0)
		key_label.add_theme_font_size_override("font_size", 6)
	else:
		key_label.position = Vector2(slot_width - 4.0 - 14.0, SLOT_H - 4.0 - 11.0)
		key_label.size = Vector2(14.0, 11.0)
		key_label.add_theme_font_size_override("font_size", 6)
	key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	key_label.text = _input_hint(_slot_input_action(index), true)
	_input_key_labels.append(key_label)
	key_label.add_theme_color_override("font_color", Color("fff2cf"))
	key_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	content.add_child(key_label)
	if index == SKILL_TREE_SLOT:
		icon.offset_left = -1.0
		icon.offset_top = -2.0
		icon.offset_right = 1.0
		icon.offset_bottom = 2.0
		var book_icon := AtlasTexture.new()
		book_icon.atlas = load(SKILL_TREE_BOOK_ICON_SHEET) as Texture2D
		book_icon.region = SKILL_TREE_BOOK_ICON_REGION
		book_icon.filter_clip = true
		icon.texture = book_icon
		placeholder.visible = false
		key_label.add_theme_color_override("font_color", Color("ffe19a"))
		slot.mouse_filter = Control.MOUSE_FILTER_STOP
		slot.tooltip_text = "T · Cây kỹ năng"
		slot.gui_input.connect(_on_skill_tree_slot_input)
	elif is_defense_slot:
		var action_id := "dash" if index == DASH_SLOT else "parry"
		icon.texture = _load_action_icon(action_id)
		icon.modulate = Color.WHITE
		placeholder.visible = icon.texture == null
		placeholder.text = "D" if index == DASH_SLOT else "P"


func _refresh_skill_bar() -> void:
	var player := _player as Player
	if player == null or _skill_slot_panels.size() != SLOT_COUNT:
		return
	for index in _input_key_labels.size():
		_input_key_labels[index].text = _input_hint(_slot_input_action(index), true)
	for index in 4:
		var slot_number := index + 1
		var skill_id := player.get_active_skill_id_for_slot(slot_number)
		var icon_name := _skill_icon_name(skill_id)
		var icon_texture: Texture2D = _load_skill_icon(icon_name) if icon_name != "" else _load_basic_projectile_icon(GameManager.weapon_form if slot_number == 1 else "")
		_skill_slot_icons[index].texture = icon_texture
		_skill_slot_icons[index].modulate = Color.WHITE
		_skill_slot_placeholders[index].visible = icon_texture == null
		_skill_slot_placeholders[index].text = "O" if skill_id == "" else "?"
		var remaining := player.get_active_skill_cooldown_for_slot(slot_number)
		_skill_slot_cooldown_overlays[index].visible = remaining > 0.0
		_skill_slot_cooldown_labels[index].visible = remaining > 0.0
		_skill_slot_cooldown_labels[index].text = str(ceili(remaining)) if remaining > 0.0 else ""
		_skill_slot_styles[index].border_color = Color("52f19a") if player.selected_active_slot == slot_number else Color("68737a")
		_skill_slot_styles[index].set_border_width_all(2 if player.selected_active_slot == slot_number else 1)
		var title := _skill_display_name(skill_id)
		if skill_id == "" and slot_number == 1:
			title = str({"wind": "Phi Dao Gió", "fire": "Hỏa Cầu", "ice": "Băng Cầu", "lightning": "Lôi Cầu"}.get(GameManager.weapon_form, title))
		_skill_slot_panels[index].tooltip_text = "%s · %s · %s thi triển" % [_input_hint(_slot_input_action(index)), title, _input_hint("skill")]
	_refresh_action_slot(DASH_SLOT, "dash", _input_hint("dash") + " · Dash", maxf(0.0, player.dash_cooldown_timer))
	_refresh_action_slot(PARRY_SLOT, "parry", _input_hint("parry") + " · Parry", maxf(0.0, player.parry_cooldown_timer))

	var ultimate_id := GameManager.selected_ultimate_skill
	var ultimate_icon := _skill_icon_name(ultimate_id)
	var ultimate_texture: Texture2D = _load_skill_icon(ultimate_icon)
	var ultimate_slot := ULTIMATE_SLOT
	_skill_slot_icons[ultimate_slot].texture = ultimate_texture
	_skill_slot_icons[ultimate_slot].modulate = Color.WHITE if ultimate_id != "" else Color("65717b")
	_skill_slot_placeholders[ultimate_slot].visible = ultimate_texture == null
	_skill_slot_placeholders[ultimate_slot].text = "I" if ultimate_id == "" else "?"
	var ultimate_remaining := player.get_ultimate_cooldown_remaining()
	_skill_slot_cooldown_overlays[ultimate_slot].visible = ultimate_remaining > 0.0
	_skill_slot_cooldown_labels[ultimate_slot].visible = ultimate_remaining > 0.0
	_skill_slot_cooldown_labels[ultimate_slot].text = str(ceili(ultimate_remaining)) if ultimate_remaining > 0.0 else ""
	var ultimate_ready := ultimate_id != "" and player.rage >= Player.MAX_RAGE and ultimate_remaining <= 0.0
	_skill_slot_styles[ultimate_slot].border_color = Color("f3d36a") if ultimate_ready else Color("ad7be8")
	_skill_slot_styles[ultimate_slot].set_border_width_all(2 if ultimate_ready else 1)
	var ultimate_status := "Chưa chọn tuyệt kỹ"
	if ultimate_id != "":
		if ultimate_ready:
			ultimate_status = "Sẵn sàng"
		elif ultimate_remaining > 0.0:
			ultimate_status = "Đang hồi chiêu"
		else:
			ultimate_status = "Đang nạp nộ khí"
	_skill_slot_panels[ultimate_slot].tooltip_text = "%s · %s · %s" % [_input_hint("ultimate"), _skill_display_name(ultimate_id), ultimate_status]
	_skill_slot_panels[SKILL_TREE_SLOT].tooltip_text = _input_hint("skill_tree") + " · Cây kỹ năng"


func _slot_input_action(index: int) -> String:
	return ["active_skill_1", "active_skill_2", "active_skill_3", "active_skill_4", "dash", "parry", "ultimate", "skill_tree"][index]


func _input_hint(action: String, compact: bool = false) -> String:
	var hints: Array[String] = []
	for event in InputMap.action_get_events(action):
		var text := ""
		if event is InputEventKey:
			text = OS.get_keycode_string(event.physical_keycode if event.physical_keycode else event.keycode)
		elif event is InputEventMouseButton:
			text = {1: "LMB", 2: "RMB", 3: "MMB"}.get(event.button_index, "M%d" % event.button_index)
		if not text.is_empty():
			if compact:
				return str({"Shift": "SH", "Space": "SP", "Backspace": "BS", "Control": "CT"}.get(text, text)).left(4)
			hints.append(text)
	return " / ".join(hints) if not hints.is_empty() else "—"


func _skill_slot_width(index: int) -> float:
	return DEFENSE_SLOT_W if index == DASH_SLOT or index == PARRY_SLOT else SLOT_W


func _refresh_action_slot(slot_index: int, action_id: String, action_name: String, remaining: float) -> void:
	var icon_texture := _load_action_icon(action_id)
	_skill_slot_icons[slot_index].texture = icon_texture
	_skill_slot_icons[slot_index].modulate = Color.WHITE if remaining <= 0.0 else Color("8daeb1")
	_skill_slot_placeholders[slot_index].visible = icon_texture == null
	_skill_slot_placeholders[slot_index].text = "D" if slot_index == DASH_SLOT else "P"
	_skill_slot_cooldown_overlays[slot_index].visible = false
	_skill_slot_cooldown_labels[slot_index].visible = remaining > 0.0
	_skill_slot_cooldown_labels[slot_index].text = "%.1f" % remaining if remaining > 0.0 else ""
	_skill_slot_styles[slot_index].border_color = Color("76e3d2") if remaining <= 0.0 else Color("53747c")
	_skill_slot_styles[slot_index].set_border_width_all(2 if remaining <= 0.0 else 1)
	_skill_slot_panels[slot_index].tooltip_text = "%s · %s" % [action_name, "Sẵn sàng" if remaining <= 0.0 else "%.1fs" % remaining]


func _load_action_icon(action_id: String) -> Texture2D:
	if not _action_icon_cache.has(action_id):
		var image := Image.create(16, 16, false, Image.FORMAT_RGBA8)
		image.fill(Color(0.0, 0.0, 0.0, 0.0))
		if action_id == "dash":
			var trail := Color("56aeb7")
			var accent := Color("a6fff0")
			_fill_icon_rect(image, 1, 5, 6, 1, trail)
			_fill_icon_rect(image, 0, 7, 8, 1, trail)
			_fill_icon_rect(image, 1, 9, 6, 1, trail)
			_fill_icon_rect(image, 7, 4, 2, 1, accent)
			_fill_icon_rect(image, 8, 5, 2, 1, accent)
			_fill_icon_rect(image, 9, 6, 2, 1, accent)
			_fill_icon_rect(image, 10, 7, 5, 2, accent)
			_fill_icon_rect(image, 9, 9, 2, 1, accent)
			_fill_icon_rect(image, 8, 10, 2, 1, accent)
			_fill_icon_rect(image, 7, 11, 2, 1, accent)
		else:
			var outline := Color("a6fff0")
			var fill := Color("34717a")
			_fill_icon_rect(image, 6, 1, 4, 1, outline)
			_fill_icon_rect(image, 4, 2, 8, 1, outline)
			_fill_icon_rect(image, 3, 3, 10, 1, outline)
			_fill_icon_rect(image, 3, 4, 10, 1, outline)
			_fill_icon_rect(image, 4, 5, 8, 1, outline)
			_fill_icon_rect(image, 5, 6, 6, 1, outline)
			_fill_icon_rect(image, 6, 7, 4, 1, outline)
			_fill_icon_rect(image, 7, 8, 2, 1, outline)
			_fill_icon_rect(image, 5, 3, 6, 1, fill)
			_fill_icon_rect(image, 4, 4, 8, 1, fill)
			_fill_icon_rect(image, 5, 5, 6, 1, fill)
			_fill_icon_rect(image, 6, 6, 4, 1, fill)
			_fill_icon_rect(image, 7, 7, 2, 1, fill)
			for step in 6:
				_fill_icon_rect(image, 5 + step, 8 - step, 2, 1, Color("fff2cf"))
		_action_icon_cache[action_id] = ImageTexture.create_from_image(image)
	return _action_icon_cache[action_id] as Texture2D


func _fill_icon_rect(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	for py in range(y, y + height):
		for px in range(x, x + width):
			image.set_pixel(px, py, color)


func _build_low_health_warning() -> void:
	_low_health_vignette_layer = CanvasLayer.new()
	_low_health_vignette_layer.name = "LowHealthVignetteLayer"
	_low_health_vignette_layer.layer = layer + 1
	_low_health_vignette_layer.transform = Transform2D.IDENTITY
	_low_health_vignette_layer.visible = false
	add_child(_low_health_vignette_layer)
	var vignette := ColorRect.new()
	vignette.name = "LowHealthVignette"
	vignette.set_anchors_preset(Control.PRESET_FULL_RECT)
	vignette.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var vignette_shader := Shader.new()
	vignette_shader.code = LOW_HEALTH_VIGNETTE_SHADER
	_vignette_material = ShaderMaterial.new()
	_vignette_material.shader = vignette_shader
	_vignette_material.set_shader_parameter("pulse_alpha", 0.0)
	vignette.material = _vignette_material
	_low_health_vignette_layer.add_child(vignette)

	_low_health_warning = Label.new()
	_low_health_warning.name = "LowHealthWarning"
	_low_health_warning.text = "MÁU THẤP"
	_low_health_warning.position = Vector2(margin.x, margin.y + 51.0)
	_low_health_warning.size = Vector2(100.0, 15.0)
	_low_health_warning.visible = false
	_low_health_warning.add_theme_font_size_override("font_size", 9)
	_low_health_warning.add_theme_color_override("font_color", Color("ff625a"))
	_low_health_warning.add_theme_color_override("font_outline_color", Color("180d12"))
	_low_health_warning.add_theme_constant_override("outline_size", 2)
	_low_health_warning.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_low_health_warning)


func _build_status_strip() -> void:
	_status_strip = HBoxContainer.new()
	_status_strip.name = "ActiveStatusStrip"
	_status_strip.position = Vector2(margin.x, margin.y + 70.0)
	_status_strip.add_theme_constant_override("separation", 2)
	_status_strip.visible = false
	_status_strip.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_status_strip)
	var border_colors := [Color("ffad66"), Color("8de7c1"), Color("89d9ff")]
	for index in 3:
		var chip := PanelContainer.new()
		chip.visible = false
		chip.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.025, 0.035, 0.05, 0.86)
		style.border_color = border_colors[index]
		style.set_border_width_all(1)
		style.set_corner_radius_all(3)
		style.set_content_margin_all(1.0)
		chip.add_theme_stylebox_override("panel", style)
		_status_strip.add_child(chip)
		_status_chips.append(chip)
		var label := Label.new()
		label.add_theme_font_size_override("font_size", 6)
		label.add_theme_color_override("font_color", border_colors[index])
		label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		chip.add_child(label)
		_status_chip_labels.append(label)


func _refresh_status_strip() -> void:
	var player := _player as Player
	if player == null or _status_strip == null:
		return
	var statuses := player.get_hud_statuses()
	var visible_count := mini(statuses.size(), _status_chips.size())
	for index in _status_chips.size():
		var has_status := index < visible_count
		_status_chips[index].visible = has_status
		if not has_status:
			continue
		var status: Dictionary = statuses[index]
		var remaining := maxi(1, ceili(float(status.get("remaining", 0.0))))
		_status_chip_labels[index].text = "%s · %ds" % [str(status.get("label", "")), remaining]
	_status_strip.visible = visible_count > 0


func _on_skill_tree_slot_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var skill_tree := get_node_or_null("SkillTreeLayer/SkillTree")
		if skill_tree != null and skill_tree.has_method("set_open"):
			skill_tree.call("set_open", true)
			get_viewport().set_input_as_handled()


func _skill_display_name(skill_id: String) -> String:
	var names: Dictionary = {
		"": "Quả cầu trắng",
		"active_wind_1": "Giải Phóng Kiếm Khí", "active_wind_2": "Phong Bộc", "active_wind_3": "Quét Kiếm Phi Gió",
		"active_fire_1": "Hỏa Cầu", "active_fire_2": "Ma Hỏa", "active_fire_3": "Hỏa Nộ",
		"active_ice_1": "Băng Cầu", "active_ice_2": "Hầm Mộ Băng Giá", "active_ice_3": "Khiên Băng",
		"active_wind_4": "Lốc Xoáy", "active_fire_4": "Mưa Thiên Thạch", "active_ice_4": "Bão Băng",
		"active_lightning_1": "Lôi Cầu", "active_lightning_2": "Xích Lôi", "active_lightning_3": "Sét Đánh", "active_lightning_4": "Lôi Bạo",
		"ultimate_wind_1": "Cái Chết Tựa Cơn Gió", "ultimate_wind_2": "Trăng Tối",
		"ultimate_fire_1": "Hỏa Kiếm", "ultimate_fire_2": "Hỏa Thần Giáng Lâm",
		"ultimate_ice_1": "Chân Băng", "ultimate_ice_2": "Kỷ Băng Hà",
		"ultimate_lightning_1": "Tâm Bão", "ultimate_lightning_2": "Thiên Lôi",
	}
	return str(names.get(skill_id, skill_id.replace("_", " ")))


func _skill_icon_name(skill_id: String) -> String:
	if skill_id == "":
		return ""
	var parts := skill_id.split("_")
	if parts.size() < 3:
		return ""
	var element: String = parts[1]
	var index := int(parts[2]) - 1
	if parts[0] == "active":
		var active_icons: Array[String] = ["shard", "orb", "strike", "nova"]
		return element + "_" + active_icons[clampi(index, 0, active_icons.size() - 1)]
	if parts[0] == "ultimate":
		var ultimate_icons: Array[String] = ["nova", "star"]
		return element + "_" + ultimate_icons[mini(index, 1)]
	return ""


func _load_skill_icon(icon_name: String) -> Texture2D:
	if icon_name == "":
		return null
	if not _skill_icon_cache.has(icon_name):
		var element := icon_name.get_slice("_", 0)
		_skill_icon_cache[icon_name] = load(SKILL_ICON_ROOT + element + "/" + icon_name + ".png") as Texture2D
	return _skill_icon_cache[icon_name] as Texture2D


func _load_basic_projectile_icon(form: String) -> Texture2D:
	if form == "wind":
		if not _skill_icon_cache.has("basic_dagger"):
			_skill_icon_cache["basic_dagger"] = load(BASIC_DAGGER_ICON) as Texture2D
		return _skill_icon_cache["basic_dagger"] as Texture2D
	var palette := form if form in ["fire", "ice", "lightning"] else "white"
	var key := "orb_" + palette
	if not _skill_icon_cache.has(key):
		var icon := AtlasTexture.new()
		icon.atlas = load("res://assets/effects/pixelfx/projectiles/orb-%s/orb-%s.png" % [palette, palette]) as Texture2D
		icon.region = Rect2(92, 14, 32, 32)
		_skill_icon_cache[key] = icon
	return _skill_icon_cache[key] as Texture2D


func _on_rage_changed(current: float, maximum: float) -> void:
	if _rage_bar == null:
		return
	_rage_bar.max_value = maximum
	_rage_bar.value = current
	_refresh_rage_label()


func _refresh_rage_label() -> void:
	var player := _player as Player
	if _rage_label == null or player == null:
		return
	var ready := GameManager.selected_ultimate_skill != "" and player.rage >= Player.MAX_RAGE and player.get_ultimate_cooldown_remaining() <= 0.0
	_rage_label.text = "TUYỆT KỸ SẴN SÀNG" if ready else "NỘ KHÍ"
	_rage_label.add_theme_color_override("font_color", Color("ffe173") if ready else Color("d1c7ff"))


func _build_texture_bar() -> void:
	var bar := TextureProgressBar.new()
	bar.texture_under = texture_under
	bar.texture_progress = texture_progress
	bar.texture_over = texture_over
	bar.texture_progress_offset = progress_offset
	bar.fill_mode = TextureProgressBar.FILL_LEFT_TO_RIGHT
	bar.step = 0.01 # để tween mượt, mặc định step = 1 sẽ giật
	bar.position = margin
	bar.scale = Vector2(pixel_scale, pixel_scale)
	bar.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST # giữ pixel art sắc nét
	add_child(bar)
	_bar = bar


func _build_flat_bar() -> void:
	var bar := ProgressBar.new()
	bar.show_percentage = false
	bar.position = margin
	bar.size = bar_size
	bar.custom_minimum_size = bar_size

	var background := StyleBoxFlat.new()
	background.bg_color = Color(0, 0, 0, 0.6)
	background.border_color = Color(1, 1, 1, 0.8)
	background.set_border_width_all(2)
	background.set_corner_radius_all(6)

	_fill = StyleBoxFlat.new()
	_fill.bg_color = fill_color
	_fill.set_corner_radius_all(6)

	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", _fill)
	add_child(bar)
	_bar = bar


func _build_label() -> void:
	# Chế độ fallback luôn hiện chữ; chế độ ảnh chỉ hiện khi bật show_label
	if texture_progress != null and not show_label:
		return
	_label = Label.new()
	_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_bar.add_child(_label)


func _on_health_changed(current: int, maximum: int) -> void:
	_refresh(current, maximum, true)


func _refresh(current: int, maximum: int, animate: bool) -> void:
	_bar.max_value = maximum
	if _label != null:
		_label.text = "%d / %d" % [current, maximum] + "HP"
	_critical_health_active = maximum > 0 and current > 0 and current * 3 <= maximum
	if _low_health_warning != null:
		_low_health_warning.visible = _critical_health_active and not _skill_tree_is_open
	if _low_health_vignette_layer != null:
		_low_health_vignette_layer.visible = _critical_health_active and not _skill_tree_is_open
	if _fill != null:
		_fill.bg_color = low_color if current * 3 <= maximum else fill_color
	if _tween != null:
		_tween.kill()
	if animate:
		_tween = create_tween()
		_tween.tween_property(_bar, "value", current, tween_time)
	else:
		_bar.value = current
