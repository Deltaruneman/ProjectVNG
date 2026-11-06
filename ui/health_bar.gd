class_name HealthHUD
extends CanvasLayer

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


func _ready() -> void:
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
