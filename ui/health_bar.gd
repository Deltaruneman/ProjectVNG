class_name HealthHUD
extends CanvasLayer

const SKILL_ICON_ROOT := "res://assets/sprites/Pixel_Skill_Spell_Icons_v1.0/PNG/32x32/"
const BASIC_DAGGER_ICON := "res://assets/sprites/object/blade/blade_throw_1.png"

# Kích thước skill bar (chỉnh ở đây)
const SLOT_W := 38.0
const SLOT_H := 36.0
const SLOT_GAP := 4
const BAR_PAD := 4
const BAR_BOTTOM := 6.0
const SLOT_COUNT := 5

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
var _skill_slot_panels: Array[PanelContainer] = []
var _skill_slot_styles: Array[StyleBoxFlat] = []
var _skill_slot_icons: Array[TextureRect] = []
var _skill_slot_placeholders: Array[Label] = []
var _skill_slot_cooldown_overlays: Array[ColorRect] = []
var _skill_slot_cooldown_labels: Array[Label] = []
var _skill_icon_cache: Dictionary = {}


func _ready() -> void:
	layer = 1 # HUD nằm dưới menu; skill tree menu nên đặt layer cao hơn (vd 10)
	add_to_group("hud")
	if texture_progress != null:
		_build_texture_bar()
	else:
		_build_flat_bar()
	_build_label()

	_player = get_tree().get_first_node_in_group("player") as BaseCharacter
	if _player == null:
		push_warning("HealthHUD: không tìm thấy node nào thuộc group 'player'")
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
	for child in get_children():
		if child.name != "SkillTree":
			child.visible = not open


func _process(_delta: float) -> void:
	_refresh_skill_bar()


func _refresh_skill_points() -> void:
	if _skill_points_label != null:
		_skill_points_label.text = "✦ %d SP  ·  T: Cây kỹ năng" % GameManager.skill_points


func _on_active_skill_slot_changed(slot: int, skill_id: String) -> void:
	_refresh_skill_bar()


func _build_skill_bar() -> void:
	var bar_w := SLOT_COUNT * SLOT_W + (SLOT_COUNT - 1) * SLOT_GAP + BAR_PAD * 2.0
	var bar_h := SLOT_H + BAR_PAD * 2.0
	var frame := PanelContainer.new()
	frame.name = "SkillBar"
	frame.anchor_left = 0.3
	frame.anchor_right = 0.3
	frame.anchor_top = 1.0
	frame.anchor_bottom = 1.0
	frame.offset_left = -bar_w * 0.8
	frame.offset_right = bar_w * 0.8
	frame.offset_top = -(bar_h + BAR_BOTTOM)
	frame.offset_bottom = -BAR_BOTTOM
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var frame_style := StyleBoxFlat.new()
	frame_style.bg_color = Color(0.015, 0.025, 0.035, 0.55)
	frame_style.border_color = Color(0.19, 0.25, 0.28, 0.6)
	frame_style.set_border_width_all(1)
	frame_style.set_corner_radius_all(4)
	frame_style.set_content_margin_all(BAR_PAD)
	frame.add_theme_stylebox_override("panel", frame_style)
	add_child(frame)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", SLOT_GAP)
	frame.add_child(row)
	for index in SLOT_COUNT:
		var slot := PanelContainer.new()
		slot.custom_minimum_size = Vector2(SLOT_W, SLOT_H)
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
		content.custom_minimum_size = Vector2(SLOT_W - 4.0, SLOT_H - 4.0)
		content.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_child(content)
		var icon := TextureRect.new()
		icon.set_anchors_preset(Control.PRESET_FULL_RECT)
		icon.offset_left = 1.0
		icon.offset_top = 0.0
		icon.offset_right = -1.0
		icon.offset_bottom = 0.0
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
		placeholder.add_theme_font_size_override("font_size", 13)
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
		cooldown_label.add_theme_font_size_override("font_size", 11)
		cooldown_label.add_theme_color_override("font_color", Color("ffffff"))
		cooldown_label.visible = false
		cooldown_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(cooldown_label)
		_skill_slot_cooldown_labels.append(cooldown_label)

		var key_label := Label.new()
		key_label.position = Vector2(SLOT_W - 4.0 - 12.0, SLOT_H - 4.0 - 12.0)
		key_label.size = Vector2(12.0, 12.0)
		key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		key_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		key_label.text = "I" if index == SLOT_COUNT - 1 else str(index + 1)
		key_label.add_theme_font_size_override("font_size", 7)
		key_label.add_theme_color_override("font_color", Color("fff2cf"))
		key_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		content.add_child(key_label)


func _refresh_skill_bar() -> void:
	var player := _player as Player
	if player == null or _skill_slot_panels.size() != SLOT_COUNT:
		return
	for index in 4:
		var slot_number := index + 1
		var skill_id := player.get_active_skill_id_for_slot(slot_number)
		var icon_name := _skill_icon_name(skill_id)
		var icon_texture: Texture2D = _load_skill_icon(icon_name) if icon_name != "" else _load_basic_dagger_icon()
		_skill_slot_icons[index].texture = icon_texture
		_skill_slot_icons[index].modulate = Color.WHITE
		_skill_slot_placeholders[index].visible = icon_texture == null
		_skill_slot_placeholders[index].text = "D" if skill_id == "" else "?"
		var remaining := player.get_active_skill_cooldown_for_slot(slot_number)
		_skill_slot_cooldown_overlays[index].visible = remaining > 0.0
		_skill_slot_cooldown_labels[index].visible = remaining > 0.0
		_skill_slot_cooldown_labels[index].text = str(ceili(remaining)) if remaining > 0.0 else ""
		_skill_slot_styles[index].border_color = Color("52f19a") if player.selected_active_slot == slot_number else Color("68737a")
		_skill_slot_styles[index].set_border_width_all(2 if player.selected_active_slot == slot_number else 1)
		var title := _skill_display_name(skill_id)
		_skill_slot_panels[index].tooltip_text = "%d · %s · U thi triển" % [slot_number, title]

	var ultimate_id := GameManager.selected_ultimate_skill
	var ultimate_icon := _skill_icon_name(ultimate_id)
	var ultimate_texture: Texture2D = _load_skill_icon(ultimate_icon)
	var ultimate_slot := SLOT_COUNT - 1
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
	_skill_slot_panels[ultimate_slot].tooltip_text = "I · %s · Nộ khí %d%%" % [_skill_display_name(ultimate_id), int(player.rage)]


func _skill_display_name(skill_id: String) -> String:
	var names: Dictionary = {
		"": "Dao găm cơ bản",
		"active_wind_1": "Giải Phóng Kiếm Khí", "active_wind_2": "Phong Bộc", "active_wind_3": "Quét Kiếm Phi Gió",
		"active_fire_1": "Hỏa Ảnh Trảm", "active_fire_2": "Ma Hỏa", "active_fire_3": "Hỏa Nộ",
		"active_ice_1": "Cấp Đông Tức Thì", "active_ice_2": "Hầm Mộ Băng Giá", "active_ice_3": "Khiên Băng",
		"active_wind_4": "Lốc Xoáy", "active_fire_4": "Mưa Thiên Thạch", "active_ice_4": "Bão Băng",
		"active_lightning_1": "Phi Dao Lôi", "active_lightning_2": "Xích Lôi", "active_lightning_3": "Sét Đánh", "active_lightning_4": "Lôi Bạo",
		"ultimate_wind_1": "Cái Chết Tựa Cơn Gió", "ultimate_wind_2": "Phong Linh",
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


func _load_basic_dagger_icon() -> Texture2D:
	if not _skill_icon_cache.has("basic_dagger"):
		_skill_icon_cache["basic_dagger"] = load(BASIC_DAGGER_ICON) as Texture2D
	return _skill_icon_cache["basic_dagger"] as Texture2D


func _on_rage_changed(current: float, maximum: float) -> void:
	if _rage_bar == null:
		return
	_rage_bar.max_value = maximum
	_rage_bar.value = current
	_rage_label.text = "NỘ KHÍ · TUYỆT KỸ SẴN SÀNG" if current >= maximum else "NỘ KHÍ · %d%%" % int(current)


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
	if _fill != null:
		_fill.bg_color = low_color if current * 3 <= maximum else fill_color
	if _tween != null:
		_tween.kill()
	if animate:
		_tween = create_tween()
		_tween.tween_property(_bar, "value", current, tween_time)
	else:
		_bar.value = current
