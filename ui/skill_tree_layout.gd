extends Control

const TREE_GRAPH := preload("res://ui/skill_tree_graph.gd")
const TREE_NODE := preload("res://ui/skill_tree_node.gd")
const MAGIC_BOOK_ROOT := "res://assets/ui/craftpix-net-809047-free-animated-magic-book-pixel-art-asset-pack/PNG/"
const BOOK_OPEN_SHEET := MAGIC_BOOK_ROOT + "Open_book.png"
const BOOK_CLOSE_SHEET := MAGIC_BOOK_ROOT + "Close_book.png"
const BOOK_TURN_LEFT_SHEET := MAGIC_BOOK_ROOT + "Turning_pages_left.png"
const BOOK_TURN_RIGHT_SHEET := MAGIC_BOOK_ROOT + "Turning_pages_right.png"
const BOOK_OPEN_FRAME := Rect2(816.0, 544.0, 272.0, 272.0)
const BOOK_DESIGN_SIZE := Vector2(1088.0, 1088.0)
const BOOK_ART_SIZE := Vector2(984.0, 732.0)
const BOOK_PIVOT := Vector2(544.0, 702.0)
const INK := Color("513b2b")
const FOLIO := preload("res://ui/skill_tree_folio.gd")
const SKILL_ICON_ROOT := "res://assets/sprites/Pixel_Skill_Spell_Icons_v1.0/PNG/32x32/"

const FORMS := [
	{"id": "wind", "name": "Kiếm Lốc · Wind", "short": "Phong", "color": Color("6acfff")},
	{"id": "fire", "name": "Kiếm Lửa · Fire", "short": "Hỏa", "color": Color("ff8155")},
	{"id": "ice", "name": "Kiếm Băng · Ice", "short": "Băng", "color": Color("a4efff")},
	{"id": "lightning", "name": "Kiếm Sấm Sét · Lightning", "short": "Lôi", "color": Color("ffe16b")},
]
const ACTIVE_SKILLS := {
	"wind": ["Phi Dao Gió", "Phong Bộc", "Quét Kiếm Phi Gió", "Lốc Xoáy"],
	"fire": ["Hỏa Cầu", "Ma Hỏa", "Hỏa Nộ", "Mưa Thiên Thạch"],
	"ice": ["Băng Cầu", "Hầm Mộ Băng Giá", "Khiên Băng", "Bão Băng"],
	"lightning": ["Lôi Cầu", "Xích Lôi", "Sét Đánh", "Lôi Bạo"],
}
const ACTIVE_SHORT_NAMES := {
	"wind": ["Phi Dao", "Phong Bộc", "Quét Kiếm", "Lốc Xoáy"],
	"fire": ["Hỏa Cầu", "Ma Hỏa", "Hỏa Nộ", "Thiên Thạch"],
	"ice": ["Băng Cầu", "Hầm Băng", "Khiên Băng", "Bão Băng"],
	"lightning": ["Lôi Cầu", "Xích Lôi", "Sét Đánh", "Lôi Bạo"],
}
const ULTIMATE_SKILLS := {
	"wind": ["Cái Chết Tựa Cơn Gió", "Trăng Tối"],
	"fire": ["Hỏa Kiếm", "Hỏa Thần Giáng Lâm"],
	"ice": ["Chân Băng", "Kỷ Băng Hà"],
	"lightning": ["Tâm Bão", "Thiên Lôi"],
}
const ULTIMATE_SHORT_NAMES := {
	"wind": ["Tử Phong", "Trăng Tối"],
	"fire": ["Hỏa Kiếm", "Hỏa Thần"],
	"ice": ["Chân Băng", "Kỷ Băng Hà"],
	"lightning": ["Tâm Bão", "Thiên Lôi"],
}
const WEAPON_EVOLUTIONS := {
	"wind": [
		{"id": "evo_wind_return", "name": "Hồi Phong", "short": "Hồi Phong", "icon": "↩", "icon_asset": "wind_shard", "desc": "Phi dao bay xa hơn 25% và quay về nhanh hơn 20%.", "req": 3, "requires": "active_wind_1"},
		{"id": "evo_wind_gale", "name": "Tàn Ảnh", "short": "Tàn Ảnh", "icon": "➤", "icon_asset": "wind_strike", "desc": "Quét Kiếm lướt xa hơn 0.5m và gây thêm 50% sát thương.", "req": 7, "requires": "active_wind_3"},
		{"id": "evo_wind_tornado", "name": "Cuồng Phong", "short": "Cuồng Phong", "icon": "✧", "icon_asset": "wind_nova", "desc": "Lốc Xoáy lớn hơn và làm chậm lâu hơn.", "req": 10, "requires": "active_wind_4"},
	],
	"fire": [
		{"id": "evo_fire_ember", "name": "Tàn Hỏa", "short": "Tàn Hỏa", "icon": "✦", "icon_asset": "fire_star", "desc": "Hỏa cầu gây thêm 1 sát thương thiêu đốt mỗi giây trong 1 giây.", "req": 3, "requires": "active_fire_1"},
		{"id": "evo_fire_inferno", "name": "Bùng Nổ", "short": "Bùng Nổ", "icon": "✹", "icon_asset": "fire_nova", "desc": "Ma Hỏa, Hỏa Nộ và Hỏa Thần có bán kính nổ tăng 1m.", "req": 7, "requires": "active_fire_2"},
		{"id": "evo_fire_meteor", "name": "Mưa Lửa", "short": "Mưa Lửa", "icon": "☄", "icon_asset": "fire_nova", "desc": "Mưa Thiên Thạch gây thêm sát thương và thiêu đốt.", "req": 10, "requires": "active_fire_4"},
	],
	"ice": [
		{"id": "evo_ice_frostbite", "name": "Hàn Khí", "short": "Hàn Khí", "icon": "❄", "icon_asset": "ice_star", "desc": "Băng cầu làm chậm thêm 1 giây; Hầm Băng đóng băng thêm 0.5 giây.", "req": 3, "requires": "active_ice_1"},
		{"id": "evo_ice_shatter", "name": "Vỡ Băng", "short": "Vỡ Băng", "icon": "✧", "icon_asset": "ice_nova", "desc": "Hầm Băng gây thêm 50% sát thương lên kẻ địch đang đóng băng.", "req": 6, "requires": "active_ice_2"},
		{"id": "evo_ice_storm", "name": "Băng Tâm", "short": "Băng Tâm", "icon": "❄", "icon_asset": "ice_nova", "desc": "Bão Băng đóng băng lâu hơn và tăng bán kính.", "req": 10, "requires": "active_ice_4"},
	],
	"lightning": [
		{"id": "evo_lightning_chain", "name": "Dẫn Điện", "short": "Dẫn Điện", "icon": "⚡", "icon_asset": "lightning_strike", "desc": "Xích Lôi đánh xa hơn và làm choáng lâu hơn.", "req": 4, "requires": "active_lightning_2"},
		{"id": "evo_lightning_storm", "name": "Tụ Lôi", "short": "Tụ Lôi", "icon": "✦", "icon_asset": "lightning_nova", "desc": "Sét Đánh và Lôi Bạo gây thêm sát thương.", "req": 8, "requires": "active_lightning_3"},
	],
}
const SKILL_DESCRIPTIONS := {
	"Phi Dao Gió": "Phóng dao gió xuyên qua nhiều kẻ địch.",
	"Phong Bộc": "Trong 5 giây, tăng tốc độ chạy và sát thương đòn đánh.",
	"Quét Kiếm Phi Gió": "Lướt nhanh về phía trước và đánh bật kẻ địch trên đường.",
	"Hỏa Cầu": "Phóng quả cầu lửa bay thẳng, không quay về; gây sát thương và thiêu đốt mục tiêu trong 3 giây.",
	"Ma Hỏa": "Triệu hồi ma hỏa, phát nổ sau 5 giây quanh vị trí người chơi.",
	"Hỏa Nộ": "Mất 25% máu hiện tại, gây sát thương vòng lửa trong 3 giây.",
	"Băng Cầu": "Phóng quả cầu băng bay thẳng, không quay về; gây sát thương và làm chậm mục tiêu trong 2 giây.",
	"Hầm Mộ Băng Giá": "Đóng băng kẻ địch trong vùng hình nón phía trước.",
	"Khiên Băng": "Tạo khiên hấp thụ sát thương bằng 25% máu tối đa.",
	"Lốc Xoáy": "Triệu hồi lốc xoáy quanh bạn, gây sát thương và làm chậm địch.",
	"Mưa Thiên Thạch": "Gọi thiên thạch xuống vùng phía trước và thiêu đốt mục tiêu.",
	"Bão Băng": "Tạo bão băng quanh bạn, gây sát thương và đóng băng kẻ địch.",
	"Lôi Cầu": "Phóng quả cầu điện bay thẳng, không quay về; làm choáng mục tiêu trong thoáng chốc.",
	"Xích Lôi": "Phóng tia sét thẳng, gây sát thương và dịch chuyển ra sau lưng kẻ địch đầu tiên trúng phải.",
	"Sét Đánh": "Triệu hồi phân thân sét đuổi theo kẻ địch, đánh thường trong 5 giây rồi phát nổ gây sát thương và choáng.",
	"Lôi Bạo": "Phóng thích vụ nổ điện quanh người, làm choáng kẻ địch.",
	"Cái Chết Tựa Cơn Gió": "Tuyệt kỹ diện rộng; tăng tốc độ di chuyển.",
	"Trăng Tối": "Trong 3,6 giây, lướt vòng quanh địch gần nhất, gây sát thương và làm chậm kẻ địch trên đường đi. Miễn sát thương khi thi triển; kết thúc sẽ hồi kỹ năng Wind đã mở khóa.",
	"Hỏa Kiếm": "Tuyệt kỹ lửa gây sát thương diện rộng.",
	"Hỏa Thần Giáng Lâm": "Hy sinh 50% máu hiện tại để bùng nổ diện rộng.",
	"Chân Băng": "Đóng băng và gây sát thương kẻ địch quanh bạn.",
	"Kỷ Băng Hà": "Đóng băng kẻ địch toàn khu vực và gây sát thương băng.",
	"Tâm Bão": "Gây bão điện diện rộng quanh người.",
	"Thiên Lôi": "Sét đánh toàn bộ kẻ địch trong khu vực.",
}
const CHARACTER_NODES := [
	{"id": "char_attack", "name": "Tấn Công", "short": "Tấn Công", "icon": "ATK", "desc": "+1 sát thương đòn đánh thường", "branch": "Tấn công", "color": Color("ff9c73"), "max": 3, "req": 0},
	{"id": "char_crit", "name": "Sắc Bén", "short": "Sắc Bén", "icon": "CRT", "desc": "+10% sát thương dao phóng", "branch": "Tấn công", "color": Color("ff9c73"), "max": 3, "req": 1},
	{"id": "char_element", "name": "Cộng Hưởng", "short": "Cộng Hưởng", "icon": "ELM", "desc": "+1 sát thương kỹ năng nguyên tố", "branch": "Tấn công", "color": Color("ff9c73"), "max": 3, "req": 2},
	{"id": "char_health", "name": "Sinh Lực", "short": "Sinh Lực", "icon": "HP", "desc": "+1 giới hạn máu tối đa", "branch": "Phòng thủ", "color": Color("73d6c0"), "max": 3, "req": 0},
	{"id": "char_heal", "name": "Hồi Phục", "short": "Hồi Phục", "icon": "RGN", "desc": "Hồi 1 máu khi mở cây kỹ năng", "branch": "Phòng thủ", "color": Color("73d6c0"), "max": 3, "req": 1},
	{"id": "char_parry", "name": "Phản Đòn", "short": "Phản Đòn", "icon": "DEF", "desc": "+25% thời gian Parry", "branch": "Phòng thủ", "color": Color("73d6c0"), "max": 2, "req": 2},
	{"id": "char_dash", "name": "Bước Gió", "short": "Bước Gió", "icon": "DSH", "desc": "Giảm 15% hồi chiêu Dash", "branch": "Cơ động", "color": Color("e4cb78"), "max": 3, "req": 0},
	{"id": "char_speed", "name": "Nhanh Nhẹn", "short": "Nhanh Nhẹn", "icon": "SPD", "desc": "+8% tốc độ di chuyển", "branch": "Cơ động", "color": Color("e4cb78"), "max": 3, "req": 1},
	{"id": "char_double_jump", "name": "Nhảy Linh Hoạt", "short": "Nhảy", "icon": "JMP", "desc": "+1 lần nhảy trên không", "branch": "Cơ động", "color": Color("e4cb78"), "max": 1, "req": 2},
]

var _balance_label: Label
var _progress: ProgressBar
var _content: VBoxContainer
var _description_title: Label
var _description_body: Label
var _confirm_button: Button
var _selected_node: SkillTreeNode
var _hovered_node: SkillTreeNode
var _zoom_percent: Label
var _active_graph: SkillTreeGraph
var _graph_zoom := 1.15
var _tab := "weapon"
var _is_open := false
var _book_animation: Tween
var _book_body: Control
var _book_art: TextureRect
var _page_content: Control
var _transition: TextureRect
var _transition_atlas: AtlasTexture
var _shade: ColorRect
var _chapter_title: Label
var _page_number: Label
var _input_shield: Control
var _tabs: Dictionary = {}
var _page_turning := false
var _transitioning := false:
	set(value):
		_transitioning = value
		if is_instance_valid(_input_shield):
			_input_shield.visible = value
var _pause_before_open := false
var _owns_pause := false
var _mouse_mode_before_open := Input.MOUSE_MODE_VISIBLE
var _presentation := 1.0
var _frame_bounds := Rect2(Vector2(52.0, 336.0), BOOK_ART_SIZE)
var _sheet_cache: Dictionary = {}
var _sheet_bounds: Dictionary = {}


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var menu_canvas := get_parent() as CanvasLayer
	if menu_canvas != null:
		menu_canvas.layer = PlayerHUD.MENU_CANVAS_LAYER
	_match_parent_canvas_scale()
	z_index = 100
	z_as_relative = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()
	call_deferred("_layout_book")
	GameManager.skill_progress_changed.connect(_refresh)
	_refresh()


func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED and is_instance_valid(_book_body):
		_layout_book()


func _process(_delta: float) -> void:
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _match_parent_canvas_scale() -> void:
	var parent_canvas := get_parent() as CanvasLayer
	if parent_canvas == null:
		return
	var canvas_transform: Transform2D = parent_canvas.transform
	var scale_x := canvas_transform.x.length()
	var scale_y := canvas_transform.y.length()
	if scale_x > 0.001 and scale_y > 0.001:
		scale = Vector2(1.0 / scale_x, 1.0 / scale_y)


func _input(event: InputEvent) -> void:
	var pause_menu := get_node_or_null("/root/PauseMenu")
	if pause_menu != null and pause_menu.is_open:
		return
	if event.is_echo():
		return
	if event.is_action_pressed("skill_tree"):
		set_open(not _is_open)
		get_viewport().set_input_as_handled()
	elif visible and event.is_action_pressed("ui_cancel"):
		set_open(false)
		get_viewport().set_input_as_handled()


func _notify_hud(open: bool) -> void:
	var hud: Node = get_parent()
	while hud != null and not hud.has_method("set_skill_tree_open"):
		hud = hud.get_parent()
	if hud != null:
		hud.call("set_skill_tree_open", open)


func set_open(open: bool) -> void:
	if open == _is_open:
		return
	_is_open = open
	# Finish the current leaf before reversing. Rapid T/Escape changes only
	# the final intent, without jumping to an unrelated sprite frame.
	if _transitioning:
		return
	if open:
		_begin_open()
	else:
		_begin_close()


func _begin_open() -> void:
	_transitioning = true
	if not _owns_pause:
		_pause_before_open = get_tree().paused
		_mouse_mode_before_open = Input.mouse_mode
		_owns_pause = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_notify_hud(true)
	visible = true
	_book_body.visible = true
	_page_content.visible = false
	_page_content.modulate.a = 0.0
	_book_art.visible = false
	_presentation = 0.78
	_shade.modulate.a = 0.0
	_layout_book()
	_refresh()
	var player := get_tree().get_first_node_in_group("player") as Player
	if player != null:
		player.health += int(GameManager.skill_allocations.get("char_heal", 0))
	_new_sequence()
	_book_animation.tween_property(_shade, "modulate:a", 1.0, 0.14)
	_append_sheet(BOOK_OPEN_SHEET, 4, 3)
	_book_animation.tween_callback(_show_open_frame)
	_book_animation.tween_property(_page_content, "modulate:a", 1.0, 0.18)
	_book_animation.tween_callback(_finish_open)


func _begin_close() -> void:
	_transitioning = true
	_page_content.process_mode = Node.PROCESS_MODE_DISABLED
	_new_sequence()
	_book_animation.tween_property(_page_content, "modulate:a", 0.0, 0.12)
	_book_animation.tween_callback(func() -> void:
		_page_content.visible = false
		_book_art.visible = false)
	_append_sheet(BOOK_CLOSE_SHEET, 4, 3)
	_book_animation.tween_property(_shade, "modulate:a", 0.0, 0.14)
	_book_animation.tween_callback(_finish_close)


func _new_sequence() -> void:
	if _book_animation != null and _book_animation.is_valid():
		_book_animation.kill()
	_book_animation = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)


func _append_sheet(path: String, columns: int, rows: int) -> void:
	var sheet: Texture2D = _sheet_cache.get(path) as Texture2D
	if sheet == null:
		push_warning("SkillTree: missing book animation sheet: %s" % path)
		return
	var frame_size := Vector2(sheet.get_width() / columns, sheet.get_height() / rows)
	var frame_count := columns * rows
	for index in frame_count:
		var region := Rect2(Vector2(index % columns, int(index / columns)) * frame_size, frame_size)
		var progress := float(index) / float(frame_count - 1)
		_book_animation.tween_callback(_set_transition_frame.bind(sheet, region, progress, path, _sheet_bounds[path][index]))
		_book_animation.tween_interval(0.065 if index == 0 or index == frame_count - 1 else 0.045)


func _set_transition_frame(sheet: Texture2D, region: Rect2, progress: float, path: String, bounds: Rect2) -> void:
	_transition_atlas.atlas = sheet
	_transition_atlas.region = region
	_transition.visible = true
	if path == BOOK_OPEN_SHEET:
		_presentation = lerpf(0.78, 1.0, progress)
	elif path == BOOK_CLOSE_SHEET:
		_presentation = lerpf(1.0, 0.78, progress)
	else:
		_presentation = 1.0
	_frame_bounds = bounds
	_layout_book()


func _show_open_frame() -> void:
	_transition.visible = false
	_book_art.visible = true
	_page_content.visible = true
	_page_content.process_mode = Node.PROCESS_MODE_DISABLED
	_presentation = 1.0
	_frame_bounds = Rect2(Vector2(52.0, 336.0), BOOK_ART_SIZE)
	_layout_book()


func _finish_open() -> void:
	_transitioning = false
	_page_turning = false
	_page_content.process_mode = Node.PROCESS_MODE_INHERIT
	if not _is_open:
		_begin_close()


func _finish_close() -> void:
	_transition.visible = false
	visible = false
	_transitioning = false
	if _is_open:
		_begin_open()
		return
	_notify_hud(false)
	_restore_pause()


func _restore_pause() -> void:
	if _owns_pause:
		get_tree().paused = _pause_before_open
		Input.mouse_mode = _mouse_mode_before_open
		_owns_pause = false


func _exit_tree() -> void:
	if _book_animation != null and _book_animation.is_valid():
		_book_animation.kill()
	if _owns_pause:
		_notify_hud(false)
		_restore_pause()


func is_open() -> bool:
	return visible


func _turn_to_tab(tab_id: String) -> void:
	if tab_id == _tab or _transitioning or not _is_open:
		return
	_page_turning = true
	_transitioning = true
	_page_content.process_mode = Node.PROCESS_MODE_DISABLED
	_new_sequence()
	_book_animation.tween_property(_page_content, "modulate:a", 0.0, 0.10)
	_book_animation.tween_callback(func() -> void:
		_page_content.visible = false
		_book_art.visible = false)
	_append_sheet(BOOK_TURN_LEFT_SHEET if tab_id == "character" else BOOK_TURN_RIGHT_SHEET, 4, 4)
	_book_animation.tween_callback(func() -> void:
		_tab = tab_id
		_refresh()
		_show_open_frame())
	_book_animation.tween_property(_page_content, "modulate:a", 1.0, 0.16)
	_book_animation.tween_callback(_finish_open)


func _build() -> void:
	for path in [BOOK_OPEN_SHEET, BOOK_CLOSE_SHEET, BOOK_TURN_LEFT_SHEET, BOOK_TURN_RIGHT_SHEET]:
		_sheet_cache[path] = load(path)
		var sheet := _sheet_cache[path] as Texture2D
		var bounds: Array[Rect2] = []
		if sheet != null:
			var source := sheet.get_image()
			for index in (12 if path == BOOK_OPEN_SHEET or path == BOOK_CLOSE_SHEET else 16):
				var cell := Rect2i(Vector2i(index % 4, int(index / 4)) * 272, Vector2i(272, 272))
				var used := source.get_region(cell).get_used_rect()
				bounds.append(Rect2(Vector2(used.position) * 4.0, Vector2(used.size) * 4.0))
		_sheet_bounds[path] = bounds
	_shade = ColorRect.new()
	_shade.color = Color(0.055, 0.038, 0.028, 0.9)
	_shade.mouse_filter = Control.MOUSE_FILTER_STOP
	_shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_shade)

	_book_body = Control.new()
	_book_body.name = "Spellbook"
	_book_body.size = BOOK_DESIGN_SIZE
	_book_body.pivot_offset = BOOK_PIVOT
	_book_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_book_body)
	_book_art = _make_book_texture("OpenBookArtwork")
	var book_atlas := AtlasTexture.new()
	book_atlas.atlas = _sheet_cache[BOOK_OPEN_SHEET]
	book_atlas.region = BOOK_OPEN_FRAME
	book_atlas.filter_clip = true
	_book_art.texture = book_atlas
	_book_body.add_child(_book_art)

	_page_content = Control.new()
	_page_content.name = "BookPageContent"
	_page_content.size = BOOK_DESIGN_SIZE
	_page_content.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_book_body.add_child(_page_content)
	var folio := FOLIO.new()
	folio.size = BOOK_DESIGN_SIZE
	_page_content.add_child(folio)

	var left := VBoxContainer.new()
	left.name = "LeftPage"
	left.position = Vector2(104.0, 390.0)
	left.size = Vector2(384.0, 580.0)
	left.add_theme_constant_override("separation", 12)
	_page_content.add_child(left)
	var imprint := _label("T O W E R   O F   A R C A N A", 12, Color("8b6a40"))
	imprint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left.add_child(imprint)
	var title := _label("Cổ thư kỹ năng", 34, INK)
	var serif := SystemFont.new()
	serif.font_names = PackedStringArray(["Georgia", "Noto Serif", "Times New Roman"])
	title.add_theme_font_override("font", serif)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left.add_child(title)
	_balance_label = _label("", 16, INK)
	_balance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	left.add_child(_balance_label)
	_progress = ProgressBar.new()
	_progress.custom_minimum_size.y = 4.0
	_progress.show_percentage = false
	_progress.max_value = 100.0
	_progress.add_theme_stylebox_override("background", _progress_style(Color("c3a875")))
	_progress.add_theme_stylebox_override("fill", _progress_style(Color("89602f")))
	_progress.tooltip_text = "Tổng điểm đã phân bổ"
	left.add_child(_progress)
	var tabs := HBoxContainer.new()
	tabs.add_theme_constant_override("separation", 10)
	left.add_child(tabs)
	_add_tab(tabs, "weapon", "I · VŨ KHÍ")
	_add_tab(tabs, "character", "II · NHÂN VẬT")
	_description_title = _label("", 22, INK)
	_description_title.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	left.add_child(_description_title)
	# Scroll long descriptions on the paper while keeping the action pinned.
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	left.add_child(scroll)
	_description_body = _label("", 18, Color("655039"))
	_description_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_description_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(_description_body)
	_confirm_button = Button.new()
	_confirm_button.custom_minimum_size.y = 40.0
	_confirm_button.add_theme_font_size_override("font_size", 15)
	_style_book_button(_confirm_button)
	_confirm_button.visible = false
	_confirm_button.pressed.connect(_confirm_selected_node_action)
	left.add_child(_confirm_button)
	var footer := HBoxContainer.new()
	footer.add_theme_constant_override("separation", 12)
	left.add_child(footer)
	var reset := Button.new()
	reset.text = "Hoàn điểm miễn phí"
	reset.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	reset.add_theme_font_size_override("font_size", 14)
	_style_book_button(reset)
	reset.pressed.connect(func() -> void:
		if not _transitioning:
			GameManager.reset_skill_tree())
	footer.add_child(reset)
	var close := Button.new()
	close.text = "Khép sách · T"
	close.add_theme_font_size_override("font_size", 14)
	_style_book_button(close)
	close.pressed.connect(func() -> void: set_open(false))
	footer.add_child(close)

	var right := VBoxContainer.new()
	right.name = "RightPage"
	right.position = Vector2(580.0, 390.0)
	right.size = Vector2(404.0, 580.0)
	right.add_theme_constant_override("separation", 8)
	_page_content.add_child(right)
	_chapter_title = _label("", 22, INK)
	_chapter_title.add_theme_font_override("font", serif)
	_chapter_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right.add_child(_chapter_title)
	_content = VBoxContainer.new()
	_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 6)
	right.add_child(_content)
	var hint := _label("Cuộn: thu / phóng · Chuột giữa: kéo", 12, Color("806743"))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right.add_child(hint)
	_page_number = _label("", 14, Color("806743"))
	_page_number.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	right.add_child(_page_number)
	_transition = _make_book_texture("BookAnimation")
	_transition_atlas = AtlasTexture.new()
	_transition_atlas.filter_clip = true
	_transition.texture = _transition_atlas
	_transition.visible = false
	_book_body.add_child(_transition)
	_input_shield = Control.new()
	_input_shield.name = "MovingPageInputShield"
	_input_shield.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_input_shield.mouse_filter = Control.MOUSE_FILTER_STOP
	_input_shield.visible = false
	add_child(_input_shield)
	_layout_book()


func _make_book_texture(node_name: String) -> TextureRect:
	var art := TextureRect.new()
	art.name = node_name
	art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	art.stretch_mode = TextureRect.STRETCH_SCALE
	art.size = BOOK_DESIGN_SIZE
	art.modulate = Color(1.0, 0.94, 0.83)
	return art


func _label(value: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return label


func _add_tab(parent: HBoxContainer, tab_id: String, label_text: String) -> void:
	var button := Button.new()
	button.text = label_text
	button.toggle_mode = true
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = 36.0
	button.add_theme_font_size_override("font_size", 15)
	_style_book_button(button)
	button.pressed.connect(func() -> void:
		button.set_pressed_no_signal(tab_id == _tab)
		_turn_to_tab(tab_id))
	_tabs[tab_id] = button
	parent.add_child(button)


func _layout_book() -> void:
	if not is_instance_valid(_book_body):
		return
	var viewport_size := get_viewport_rect().size
	var fit := minf(viewport_size.x * 0.94 / BOOK_ART_SIZE.x, viewport_size.y * 0.92 / BOOK_ART_SIZE.y)
	# Fit upright leaves too, without cropping the cover or changing frame geometry.
	fit = minf(fit, viewport_size.y * 0.92 / maxf(_frame_bounds.size.y, 1.0))
	fit = minf(fit, viewport_size.x * 0.94 / maxf(_frame_bounds.size.x, 1.0))
	_book_body.scale = Vector2.ONE * fit * _presentation
	var top := viewport_size.y * 0.5 + (_frame_bounds.position.y - BOOK_PIVOT.y) * _book_body.scale.y
	var bottom := top + _frame_bounds.size.y * _book_body.scale.y
	var shift := clampf(0.0, viewport_size.y * 0.04 - top, viewport_size.y * 0.96 - bottom)
	var left := viewport_size.x * 0.5 + (_frame_bounds.position.x - BOOK_PIVOT.x) * _book_body.scale.x
	var right := left + _frame_bounds.size.x * _book_body.scale.x
	var shift_x := clampf(0.0, viewport_size.x * 0.03 - left, viewport_size.x * 0.97 - right)
	_book_body.position = viewport_size * 0.5 - BOOK_PIVOT + Vector2(shift_x, shift)


func _refresh() -> void:
	if not is_instance_valid(_content):
		return
	if is_instance_valid(_selected_node):
		_selected_node.focused = false
		_selected_node.queue_redraw()
	_selected_node = null
	_hovered_node = null
	_confirm_button.release_focus()
	_confirm_button.visible = false
	var total_points: int = GameManager.total_skill_points()
	var spent_points: int = GameManager.allocated_skill_points()
	_balance_label.text = "%d SP còn lại   ·   %d / %d đã ghi" % [GameManager.skill_points, spent_points, total_points]
	_progress.value = 0.0 if total_points == 0 else 100.0 * float(spent_points) / float(total_points)
	_chapter_title.text = "I. Binh khí & nguyên tố" if _tab == "weapon" else "II. Tu luyện bản thân"
	_page_number.text = "—  2  —" if _tab == "weapon" else "—  4  —"
	for tab_id: String in _tabs:
		(_tabs[tab_id] as Button).set_pressed_no_signal(tab_id == _tab)
	_reset_skill_description()
	for child in _content.get_children():
		_content.remove_child(child)
		child.queue_free()
	if _tab == "weapon":
		_build_weapon_tree()
	else:
		_build_character_tree()

func _build_weapon_tree() -> void:
	var current_form: String = GameManager.weapon_form
	if current_form == "":
		_description_title.text = "CHỌN NGUYÊN TỐ"
		_description_body.text = "Chọn nguyên tố rồi xác nhận bên trái. Mỗi nhánh cần 1 SP.\n\nCuộn để zoom; chuột giữa để kéo."
	else:
		_description_title.text = "CÂY VŨ KHÍ"
		var ultimate_milestones := "5 / 8 SP"
		if current_form == "wind":
			ultimate_milestones = "5 / 10 SP"
		_description_body.text = "Mốc kỹ năng: 1 / 4 / 6 / 9 SP; tuyệt kỹ %s. Tiến hóa và tuyệt kỹ cần mở nhánh trước. Chọn kỹ năng rồi xác nhận bên trái.\n\nCuộn để zoom; chuột giữa để kéo." % ultimate_milestones
	var graph: SkillTreeGraph = TREE_GRAPH.new()
	_prepare_graph(graph)
	var root_color := Color("e5d08d")
	var root_position := Vector2(0.5, 0.84)
	_make_node(graph, root_position, "D", "Dao Găm", "CƠ BẢN", root_color, false, false, false, "Dao Găm Cơ Bản")
	if current_form == "":
		var form_positions: Array[Vector2] = [Vector2(0.27, 0.65), Vector2(0.73, 0.65), Vector2(0.27, 0.35), Vector2(0.73, 0.35)]
		for index in FORMS.size():
			var form_data: Dictionary = FORMS[index]
			var position: Vector2 = form_positions[index]
			var form_id: String = str(form_data["id"])
			var form_color: Color = form_data["color"]
			var already_chosen := int(GameManager.skill_allocations.get("form_" + form_id, 0)) > 0
			var can_choose := GameManager.skill_points > 0 and not already_chosen
			graph.add_link(root_position, position, form_color.darkened(0.15), already_chosen)
			var form_callback := func() -> void:
				GameManager.spend_skill_point("form_" + form_id, form_id)
			var form_tooltip := "%s\nChọn nguyên tố này để mở cây kỹ năng tương ứng." % str(form_data["name"])
			_make_node(graph, position, form_id.substr(0, 1).to_upper(), str(form_data["short"]), "0/1", form_color, can_choose, already_chosen, false, form_tooltip, form_callback, _skill_icon_path(form_id + "_orb"), true, "CHỌN NGUYÊN TỐ")
		return

	var selected_form: Dictionary = _form_data(current_form)
	var form_color: Color = selected_form.color
	var form_position := Vector2(0.5, 0.67)
	graph.add_link(root_position, form_position, form_color, true)
	_make_node(graph, form_position, current_form.substr(0, 1).to_upper(), str(selected_form.short), "ĐÃ CHỌN", form_color, false, true, true, str(selected_form.name), Callable(), _skill_icon_path(current_form + "_orb"))
	var active_names: Array = ACTIVE_SKILLS[current_form]
	var short_names: Array = ACTIVE_SHORT_NAMES[current_form]
	var active_positions: Array[Vector2] = [Vector2(0.18, 0.50), Vector2(0.39, 0.50), Vector2(0.61, 0.50), Vector2(0.82, 0.50)]
	for index in active_names.size():
		var skill_id := "active_%s_%d" % [current_form, index + 1]
		var required: int = [1, 4, 6, 9][index]
		var position: Vector2 = active_positions[index]
		graph.add_link(form_position, position, form_color.darkened(0.3), GameManager.unlocked_skills.has(skill_id))
		_add_skill_node(graph, position, skill_id, str(active_names[index]), str(short_names[index]), str(index + 1), required, str(SKILL_DESCRIPTIONS.get(active_names[index], "Kỹ năng vũ khí.")), false, form_color)

	var ultimate_names: Array = ULTIMATE_SKILLS[current_form]
	var ultimate_short: Array = ULTIMATE_SHORT_NAMES[current_form]
	var evolution_data: Array = WEAPON_EVOLUTIONS[current_form]
	var evolution_positions: Array[Vector2] = []
	if evolution_data.size() == 3:
		evolution_positions = [Vector2(0.2, 0.33), Vector2(0.5, 0.33), Vector2(0.8, 0.33)]
	else:
		evolution_positions = [Vector2(0.35, 0.33), Vector2(0.65, 0.33)]
	for index in evolution_data.size():
		var required_skill: String = str(evolution_data[index]["requires"])
		var required_slot := clampi(int(required_skill.get_slice("_", 2)) - 1, 0, active_positions.size() - 1)
		graph.add_link(active_positions[required_slot], evolution_positions[index], form_color.darkened(0.4), GameManager.skill_allocations.has(evolution_data[index]["id"]))
		_add_evolution_node(graph, evolution_positions[index], evolution_data[index], form_color)
	var ultimate_positions: Array[Vector2] = [Vector2(0.35, 0.16), Vector2(0.65, 0.16)]
	for index in evolution_positions.size():
		graph.add_link(evolution_positions[index], ultimate_positions[mini(index, 1)], form_color.darkened(0.45), GameManager.skill_allocations.has(evolution_data[index]["id"]))
	graph.add_link(active_positions[0], ultimate_positions[0], form_color.darkened(0.45), GameManager.unlocked_skills.has("active_%s_1" % current_form))
	graph.add_link(active_positions[1], ultimate_positions[0], form_color.darkened(0.45), GameManager.unlocked_skills.has("active_%s_2" % current_form))
	graph.add_link(active_positions[2], ultimate_positions[1], form_color.darkened(0.45), GameManager.unlocked_skills.has("active_%s_3" % current_form))
	graph.add_link(active_positions[3], ultimate_positions[1], form_color.darkened(0.45), GameManager.unlocked_skills.has("active_%s_4" % current_form))
	for index in ultimate_names.size():
		var skill_id := "ultimate_%s_%d" % [current_form, index + 1]
		var required: int = [5, 8][index]
		if current_form == "wind" and index == 1:
			required = 10
		_add_skill_node(graph, ultimate_positions[index], skill_id, str(ultimate_names[index]), str(ultimate_short[index]), "I", required, str(SKILL_DESCRIPTIONS.get(ultimate_names[index], "Tuyệt kỹ.")), true, form_color)


func _add_evolution_node(graph: SkillTreeGraph, position: Vector2, data: Dictionary, color: Color) -> void:
	var rank := int(GameManager.skill_allocations.get(data.id, 0))
	var prerequisite_unlocked: bool = GameManager.unlocked_skills.has(data.requires)
	var can_buy := rank == 0 and prerequisite_unlocked and GameManager.skill_points > 0 and GameManager.total_skill_points() >= int(data.req)
	var tooltip := "%s\n%s\nCần mở kỹ năng nhánh · Mốc %d SP · Tốn 1 SP" % [data.name, data.desc, data.req]
	if rank > 0:
		tooltip = "%s\n%s\nĐã tiến hóa" % [data.name, data.desc]
	var purchase_callback := func() -> void:
		GameManager.spend_skill_point(str(data.id))
	_make_node(graph, position, str(data.icon), str(data.short), "1/1" if rank > 0 else "%d SP" % int(data.req), color.lightened(0.12), can_buy, rank > 0, false, tooltip, purchase_callback, _skill_icon_path(str(data.icon_asset)), false, "TIẾN HÓA")


func _add_skill_node(graph: SkillTreeGraph, position: Vector2, skill_id: String, skill_name: String, short_name: String, icon: String, requirement: int, description: String, ultimate: bool, color: Color) -> void:
	var unlocked: bool = GameManager.unlocked_skills.has(skill_id)
	var can_buy := (unlocked and ultimate) or (not unlocked and GameManager.skill_points > 0 and GameManager.total_skill_points() >= requirement)
	var rank_text := "1/1" if unlocked else "%d SP" % requirement
	var is_selected := ultimate and skill_id == GameManager.selected_ultimate_skill
	if is_selected:
		rank_text = "ĐANG DÙNG"
	var tooltip := "%s\n%s\n%s" % [skill_name, description, "Đã mở khóa" if unlocked else "Mốc %d điểm · Tốn 1 SP" % requirement]
	var skill_callback := func() -> void:
		if unlocked and ultimate:
			GameManager.select_ultimate_skill(skill_id)
		elif GameManager.spend_skill_point(skill_id) and ultimate:
			GameManager.select_ultimate_skill(skill_id)
	var action_label := "HỌC TUYỆT KỸ" if ultimate else "HỌC CHIÊU"
	if unlocked and ultimate:
		action_label = "CHỌN TUYỆT KỸ"
	_make_node(graph, position, icon, short_name, rank_text, color, can_buy, unlocked, is_selected, tooltip, skill_callback, _skill_icon_path(_icon_kind_for_skill(skill_id)), false, action_label)


func _build_character_tree() -> void:
	_description_title.text = "CÂY NHÂN VẬT"
	_description_body.text = "Điểm dùng chung cho các nhánh. Rê chuột xem chi tiết; chọn kỹ năng rồi xác nhận bên trái."
	var branch_header := HBoxContainer.new()
	for data in [
		{"name": "TẤN CÔNG", "color": Color("ff9c73")},
		{"name": "PHÒNG THỦ", "color": Color("73d6c0")},
		{"name": "CƠ ĐỘNG", "color": Color("e4cb78")},
	]:
		var label := Label.new()
		label.text = str(data.name)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 12)
		label.add_theme_color_override("font_color", Color("72523a"))
		branch_header.add_child(label)
	_content.add_child(branch_header)

	var graph: SkillTreeGraph = TREE_GRAPH.new()
	_prepare_graph(graph)
	var branches := ["Tấn công", "Phòng thủ", "Cơ động"]
	var columns := [0.17, 0.5, 0.83]
	for column in branches.size():
		var branch_nodes: Array[Dictionary] = []
		for node_data: Dictionary in CHARACTER_NODES:
			if node_data.branch == branches[column]:
				branch_nodes.append(node_data)
		for row in branch_nodes.size():
			var node_data: Dictionary = branch_nodes[row]
			var position := Vector2(columns[column], [0.16, 0.5, 0.84][row])
			if row > 0:
				graph.add_link(Vector2(columns[column], [0.16, 0.5, 0.84][row - 1]), position, node_data.color.darkened(0.3))
			var rank := int(GameManager.skill_allocations.get(node_data.id, 0))
			var required := int(node_data.req)
			var can_buy := GameManager.skill_points > 0 and GameManager.total_skill_points() >= required and rank < int(node_data.max)
			var tooltip := "%s\n%s\nNhánh %s · Mốc %d điểm" % [node_data.name, node_data.desc, node_data.branch, required]
			var upgrade_callback := func() -> void:
				GameManager.spend_skill_point(str(node_data.id))
			_make_node(graph, position, str(node_data.icon), str(node_data.short), "%d/%d" % [rank, node_data.max], node_data.color, can_buy, rank > 0, false, tooltip, upgrade_callback, "", false, "NÂNG CẤP")


func _make_node(graph: SkillTreeGraph, position: Vector2, icon: String, title: String, rank: String, accent: Color, available: bool, purchased: bool, selected: bool, tooltip: String, callback: Callable = Callable(), icon_path: String = "", prominent_icon: bool = false, action_label: String = "HỌC KỸ NĂNG") -> SkillTreeNode:
	var node: SkillTreeNode = TREE_NODE.new()
	node.prominent_icon = prominent_icon
	node.layout_size = SkillTreeNode.LARGE_NODE_SIZE if prominent_icon else SkillTreeNode.NODE_SIZE
	node.icon_text = icon
	if icon_path != "":
		node.icon_texture = load(icon_path) as Texture2D
	node.title_text = title
	node.rank_text = rank
	node.accent_color = accent
	var tooltip_lines := tooltip.split("\n", false)
	node.detail_title = tooltip_lines[0] if not tooltip_lines.is_empty() else title
	node.description_text = "\n".join(tooltip_lines.slice(1)) if tooltip_lines.size() > 1 else tooltip
	node.action_label = action_label
	node.action_callback = callback
	node.available = available
	node.action_available = available
	node.purchased = purchased
	node.selected = selected
	node.tooltip_text = ""
	node.hover_changed.connect(_show_skill_description)
	node.activated.connect(_on_skill_node_activated.bind(node))
	graph.add_tree_node(node, position)
	return node


func _prepare_graph(graph: SkillTreeGraph) -> void:
	graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	graph.size_flags_vertical = Control.SIZE_EXPAND_FILL
	graph.layout_offset_ratio = Vector2.ZERO
	graph.clip_contents = true
	graph.zoom_changed.connect(_on_graph_zoom_changed)
	_content.add_child(_make_zoom_controls())
	_content.add_child(graph)
	_active_graph = graph
	graph.set_zoom(_graph_zoom, _graph_zoom == 1.0)
	_update_zoom_label()


func _make_zoom_controls() -> HBoxContainer:
	var controls := HBoxContainer.new()
	controls.alignment = BoxContainer.ALIGNMENT_END
	controls.custom_minimum_size.y = 30.0
	controls.add_theme_constant_override("separation", 2)
	var zoom_out := Button.new()
	zoom_out.text = "−"
	zoom_out.custom_minimum_size = Vector2(32.0, 28.0)
	zoom_out.add_theme_font_size_override("font_size", 12)
	_style_book_button(zoom_out)
	zoom_out.pressed.connect(func() -> void: _set_graph_zoom(_graph_zoom - 0.15))
	controls.add_child(zoom_out)
	_zoom_percent = Label.new()
	_zoom_percent.text = "100%"
	_zoom_percent.custom_minimum_size.x = 52.0
	_zoom_percent.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_zoom_percent.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_zoom_percent.add_theme_font_size_override("font_size", 14)
	_zoom_percent.add_theme_color_override("font_color", INK)
	controls.add_child(_zoom_percent)
	var zoom_in := Button.new()
	zoom_in.text = "+"
	zoom_in.custom_minimum_size = Vector2(32.0, 28.0)
	zoom_in.add_theme_font_size_override("font_size", 12)
	_style_book_button(zoom_in)
	zoom_in.pressed.connect(func() -> void: _set_graph_zoom(_graph_zoom + 0.15))
	controls.add_child(zoom_in)
	var zoom_reset := Button.new()
	zoom_reset.text = "↺"
	zoom_reset.custom_minimum_size = Vector2(32.0, 28.0)
	zoom_reset.add_theme_font_size_override("font_size", 10)
	zoom_reset.tooltip_text = "Đặt lại zoom"
	_style_book_button(zoom_reset)
	zoom_reset.pressed.connect(func() -> void: _set_graph_zoom(1.0, true))
	controls.add_child(zoom_reset)
	return controls


func _set_graph_zoom(value: float, reset_pan: bool = false) -> void:
	_graph_zoom = clampf(value, 0.65, 2.0)
	if is_instance_valid(_active_graph):
		_active_graph.set_zoom(_graph_zoom, reset_pan)
	_update_zoom_label()


func _on_graph_zoom_changed(value: float) -> void:
	_graph_zoom = value
	_update_zoom_label()


func _update_zoom_label() -> void:
	if is_instance_valid(_zoom_percent):
		_zoom_percent.text = "%d%%" % roundi(_graph_zoom * 100.0)


func _reset_skill_description() -> void:
	if not is_instance_valid(_description_title) or not is_instance_valid(_description_body):
		return
	if is_instance_valid(_confirm_button):
		_confirm_button.visible = false
	_description_title.add_theme_color_override("font_color", INK)
	if _tab == "character":
		_description_title.text = "CÂY NHÂN VẬT"
		_description_body.text = "Điểm dùng chung cho các nhánh. Rê chuột xem chi tiết; chọn kỹ năng rồi xác nhận bên trái.\n\nCuộn để zoom; chuột giữa để kéo."
	elif GameManager.weapon_form == "":
		_description_title.text = "CHỌN NGUYÊN TỐ"
		_description_body.text = "Chọn nguyên tố rồi xác nhận bên trái. Mỗi nhánh cần 1 SP.\n\nCuộn để zoom; chuột giữa để kéo."
	else:
		_description_title.text = "CÂY VŨ KHÍ"
		_description_body.text = "Mốc kỹ năng: 1 / 4 / 6 / 9 SP. Tiến hóa và tuyệt kỹ cần mở nhánh trước. Chọn kỹ năng rồi xác nhận bên trái.\n\nCuộn để zoom; chuột giữa để kéo."


func _show_skill_description(source: Control, title: String, description: String, color: Color) -> void:
	if _transitioning or is_instance_valid(_selected_node):
		return
	if not is_instance_valid(_description_title) or not is_instance_valid(_description_body):
		return
	if title.is_empty():
		if source == _hovered_node:
			_hovered_node = null
		if is_instance_valid(_hovered_node):
			return
		if is_instance_valid(_selected_node):
			_show_selected_node()
		else:
			_reset_skill_description()
		return
	_hovered_node = source as SkillTreeNode
	_description_title.text = title
	_description_body.text = description
	_description_title.add_theme_color_override("font_color", Color("60472f").lerp(color.darkened(0.48), 0.25))
	if is_instance_valid(_confirm_button):
		var show_action := is_instance_valid(_selected_node) and source == _selected_node \
			and _selected_node.action_callback.is_valid()
		if not show_action:
			_confirm_button.release_focus()
		_confirm_button.visible = show_action


func _on_skill_node_activated(node: SkillTreeNode) -> void:
	if _transitioning or not _is_open:
		return
	if is_instance_valid(_selected_node):
		_selected_node.focused = false
		_selected_node.queue_redraw()
	_selected_node = node
	_selected_node.focused = true
	_selected_node.queue_redraw()
	_show_selected_node()


func _show_selected_node() -> void:
	if not is_instance_valid(_selected_node):
		return
	_description_title.text = _selected_node.detail_title
	_description_body.text = _selected_node.description_text
	_description_title.add_theme_color_override("font_color", Color("60472f").lerp(_selected_node.accent_color.darkened(0.48), 0.25))
	if not is_instance_valid(_confirm_button) or not _selected_node.action_callback.is_valid():
		if is_instance_valid(_confirm_button):
			_confirm_button.release_focus()
			_confirm_button.visible = false
		return
	_confirm_button.visible = true
	_confirm_button.disabled = not _selected_node.action_available
	if _selected_node.selected:
		_confirm_button.text = "ĐANG DÙNG"
		_confirm_button.disabled = true
	elif _selected_node.purchased and not _selected_node.action_available:
		_confirm_button.text = "ĐÃ HỌC"
	else:
		_confirm_button.text = _selected_node.action_label if _selected_node.action_available else "CHƯA ĐỦ ĐIỀU KIỆN"


func _confirm_selected_node_action() -> void:
	if _transitioning or not _is_open:
		return
	if not is_instance_valid(_selected_node) or not _selected_node.action_available \
			or not _selected_node.action_callback.is_valid():
		return
	_selected_node.action_callback.call()


func _skill_icon_path(icon_name: String) -> String:
	var element := icon_name.get_slice("_", 0)
	return SKILL_ICON_ROOT + element + "/" + icon_name + ".png"


func _icon_kind_for_skill(skill_id: String) -> String:
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
		return element + "_" + ultimate_icons[clampi(index, 0, ultimate_icons.size() - 1)]
	return ""


func _form_data(form_id: String) -> Dictionary:
	for data: Dictionary in FORMS:
		if data.id == form_id:
			return data
	return FORMS[0]


func _style_book_button(button: Button) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.54, 0.38, 0.19, 0.07)
	normal.border_color = Color("a28453")
	normal.border_width_bottom = 1
	normal.set_corner_radius_all(2)
	normal.content_margin_left = 9.0
	normal.content_margin_right = 9.0
	normal.content_margin_top = 6.0
	normal.content_margin_bottom = 6.0
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color(0.54, 0.38, 0.19, 0.18)
	hover.border_color = Color("765132")
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("775033")
	pressed.border_color = Color("513323")
	var disabled := normal.duplicate() as StyleBoxFlat
	disabled.bg_color = Color(0.54, 0.38, 0.19, 0.04)
	disabled.border_color = Color("bca77d")
	var focus := StyleBoxFlat.new()
	focus.bg_color = Color.TRANSPARENT
	focus.border_color = Color("926537")
	focus.set_border_width_all(1)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover_pressed", pressed)
	button.add_theme_stylebox_override("disabled", disabled)
	button.add_theme_stylebox_override("focus", focus)
	button.add_theme_color_override("font_color", INK)
	button.add_theme_color_override("font_hover_color", Color("392618"))
	button.add_theme_color_override("font_pressed_color", Color("f5e4bc"))
	button.add_theme_color_override("font_hover_pressed_color", Color("f5e4bc"))
	button.add_theme_color_override("font_disabled_color", Color("97815e"))


func _progress_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(1)
	return style
