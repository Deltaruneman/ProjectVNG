extends Control

const TREE_GRAPH := preload("res://ui/skill_tree_graph.gd")
const TREE_NODE := preload("res://ui/skill_tree_node.gd")
const MAGIC_BOOK_ROOT := "res://assets/ui/craftpix-net-809047-free-animated-magic-book-pixel-art-asset-pack/PNG/"
const BOOK_OPEN_SHEET := MAGIC_BOOK_ROOT + "Open_book.png"
const BOOK_CLOSE_SHEET := MAGIC_BOOK_ROOT + "Close_book.png"
const BOOK_TURN_LEFT_SHEET := MAGIC_BOOK_ROOT + "Turning_pages_left.png"
const BOOK_TURN_RIGHT_SHEET := MAGIC_BOOK_ROOT + "Turning_pages_right.png"
const BOOK_OPEN_ART_REGION := Rect2(829.0, 628.0, 246.0, 183.0)
const BOOK_FRAME_SIZE := 272.0
const SKILL_ICON_ROOT := "res://assets/sprites/Pixel_Skill_Spell_Icons_v1.0/PNG/32x32/"

const FORMS := [
	{"id": "wind", "name": "Kiếm Lốc · Wind", "short": "Wind Form", "color": Color("6acfff")},
	{"id": "fire", "name": "Kiếm Lửa · Fire", "short": "Fire Form", "color": Color("ff8155")},
	{"id": "ice", "name": "Kiếm Băng · Ice", "short": "Ice Form", "color": Color("a4efff")},
	{"id": "lightning", "name": "Kiếm Sấm Sét · Lightning", "short": "Lightning", "color": Color("ffe16b")},
]
const ACTIVE_SKILLS := {
	"wind": ["Phi Dao Gió", "Phong Bộc", "Quét Kiếm Phi Gió", "Lốc Xoáy"],
	"fire": ["Phi Dao Hỏa", "Ma Hỏa", "Hỏa Nộ", "Mưa Thiên Thạch"],
	"ice": ["Phi Dao Băng", "Hầm Mộ Băng Giá", "Khiên Băng", "Bão Băng"],
	"lightning": ["Phi Dao Lôi", "Xích Lôi", "Sét Đánh", "Lôi Bạo"],
}
const ACTIVE_SHORT_NAMES := {
	"wind": ["Phi Dao", "Phong Bộc", "Quét Kiếm", "Lốc Xoáy"],
	"fire": ["Phi Dao", "Ma Hỏa", "Hỏa Nộ", "Thiên Thạch"],
	"ice": ["Phi Dao", "Hầm Băng", "Khiên Băng", "Bão Băng"],
	"lightning": ["Phi Dao", "Xích Lôi", "Sét Đánh", "Lôi Bạo"],
}
const ULTIMATE_SKILLS := {
	"wind": ["Cái Chết Tựa Cơn Gió", "Phong Linh"],
	"fire": ["Hỏa Kiếm", "Hỏa Thần Giáng Lâm"],
	"ice": ["Chân Băng", "Kỷ Băng Hà"],
	"lightning": ["Tâm Bão", "Thiên Lôi"],
}
const ULTIMATE_SHORT_NAMES := {
	"wind": ["Tử Phong", "Phong Linh"],
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
		{"id": "evo_fire_ember", "name": "Tàn Hỏa", "short": "Tàn Hỏa", "icon": "✦", "icon_asset": "fire_star", "desc": "Phi dao gây thêm 1 sát thương thiêu đốt mỗi giây trong 1 giây.", "req": 3, "requires": "active_fire_1"},
		{"id": "evo_fire_inferno", "name": "Bùng Nổ", "short": "Bùng Nổ", "icon": "✹", "icon_asset": "fire_nova", "desc": "Ma Hỏa, Hỏa Nộ và Hỏa Thần có bán kính nổ tăng 1m.", "req": 7, "requires": "active_fire_2"},
		{"id": "evo_fire_meteor", "name": "Mưa Lửa", "short": "Mưa Lửa", "icon": "☄", "icon_asset": "fire_nova", "desc": "Mưa Thiên Thạch gây thêm sát thương và thiêu đốt.", "req": 10, "requires": "active_fire_4"},
	],
	"ice": [
		{"id": "evo_ice_frostbite", "name": "Hàn Khí", "short": "Hàn Khí", "icon": "❄", "icon_asset": "ice_star", "desc": "Phi dao làm chậm thêm 1 giây; Hầm Băng đóng băng thêm 0.5 giây.", "req": 3, "requires": "active_ice_1"},
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
	"Phi Dao Hỏa": "Phóng dao gây sát thương và thiêu đốt mục tiêu trong 3 giây.",
	"Ma Hỏa": "Triệu hồi ma hỏa, phát nổ sau 5 giây quanh vị trí người chơi.",
	"Hỏa Nộ": "Mất 25% máu hiện tại, gây sát thương vòng lửa trong 3 giây.",
	"Phi Dao Băng": "Phóng dao gây sát thương và làm chậm mục tiêu trong 2 giây.",
	"Hầm Mộ Băng Giá": "Đóng băng kẻ địch trong vùng hình nón phía trước.",
	"Khiên Băng": "Tạo khiên hấp thụ sát thương bằng 25% máu tối đa.",
	"Lốc Xoáy": "Triệu hồi lốc xoáy quanh bạn, gây sát thương và làm chậm địch.",
	"Mưa Thiên Thạch": "Gọi thiên thạch xuống vùng phía trước và thiêu đốt mục tiêu.",
	"Bão Băng": "Tạo bão băng quanh bạn, gây sát thương và đóng băng kẻ địch.",
	"Phi Dao Lôi": "Phóng phi đao mang điện, làm choáng mục tiêu trong thoáng chốc.",
	"Xích Lôi": "Phóng chuỗi sét vào nhóm kẻ địch phía trước.",
	"Sét Đánh": "Gọi sét đánh xuống vị trí phía trước.",
	"Lôi Bạo": "Phóng thích vụ nổ điện quanh người, làm choáng kẻ địch.",
	"Cái Chết Tựa Cơn Gió": "Tuyệt kỹ diện rộng; tăng tốc độ di chuyển.",
	"Phong Linh": "Tuyệt kỹ gió diện rộng kéo dài và tăng sức mạnh.",
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
var _description_panel: PanelContainer
var _description_title: Label
var _description_body: Label
var _zoom_percent: Label
var _active_graph: SkillTreeGraph
var _graph_zoom := 1.0
var _tab := "weapon"
var _is_open := false
var _book_animation: Tween
var _book_body: Control
var _book_art: TextureRect
var _page_content: Control
var _transition: TextureRect
var _transition_atlas: AtlasTexture
var _page_turning := false


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
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


func _match_parent_canvas_scale() -> void:
	var parent_canvas := get_parent() as CanvasLayer
	if parent_canvas == null:
		return
	var canvas_transform: Transform2D = parent_canvas.transform
	var scale_x := Vector2(canvas_transform.x.x, canvas_transform.x.y).length()
	var scale_y := Vector2(canvas_transform.y.x, canvas_transform.y.y).length()
	if scale_x > 0.001 and scale_y > 0.001:
		scale = Vector2(1.0 / scale_x, 1.0 / scale_y)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("skill_tree"):
		set_open(not _is_open)
		get_viewport().set_input_as_handled()
	elif _is_open and event.is_action_pressed("ui_cancel"):
		set_open(false)
		get_viewport().set_input_as_handled()


func set_open(open: bool) -> void:
	if open == _is_open:
		return
	_is_open = open
	_page_turning = false
	var hud := get_parent()
	if hud != null and hud.has_method("set_skill_tree_open"):
		hud.call("set_skill_tree_open", open)
	if _book_animation != null and _book_animation.is_running():
		_book_animation.kill()
	if open:
		visible = true
		get_tree().paused = true
		_book_body.visible = false
		_play_book_sheet(BOOK_OPEN_SHEET, 4, 3, func() -> void:
			if _is_open:
				_transition.visible = false
				_book_body.visible = true)
		var player := get_tree().get_first_node_in_group("player") as Player
		if player != null:
			player.health += int(GameManager.skill_allocations.get("char_heal", 0))
		_refresh()
	else:
		_book_body.visible = false
		_play_book_sheet(BOOK_CLOSE_SHEET, 4, 3, func() -> void:
			if not _is_open:
				_transition.visible = false
				visible = false
				get_tree().paused = false)


func is_open() -> bool:
	return _is_open


func _play_book_sheet(path: String, columns: int, rows: int, finished: Callable) -> void:
	var sheet := load(path) as Texture2D
	if sheet == null:
		push_warning("SkillTree: missing book animation sheet: %s" % path)
		finished.call()
		return
	if _book_animation != null and _book_animation.is_running():
		_book_animation.kill()
	var frame_size := Vector2(sheet.get_width() / columns, sheet.get_height() / rows)
	_transition_atlas = AtlasTexture.new()
	_transition_atlas.atlas = sheet
	_transition_atlas.filter_clip = true
	_transition.texture = _transition_atlas
	_transition.visible = true
	var frame_count := columns * rows
	_set_transition_frame(_transition_atlas, Rect2(Vector2.ZERO, frame_size))
	_book_animation = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	for frame_index in frame_count:
		var frame_x := frame_index % columns
		var frame_y := int(frame_index / columns)
		var frame_region := Rect2(Vector2(frame_x, frame_y) * frame_size, frame_size)
		_book_animation.tween_callback(_set_transition_frame.bind(_transition_atlas, frame_region)).set_delay(0.045)
	_book_animation.tween_callback(finished)


func _set_transition_frame(atlas: AtlasTexture, region: Rect2) -> void:
	atlas.region = region


func _turn_to_tab(tab_id: String) -> void:
	if tab_id == _tab or _page_turning or not _is_open:
		return
	_page_turning = true
	var sheet_path := BOOK_TURN_LEFT_SHEET if tab_id == "character" else BOOK_TURN_RIGHT_SHEET
	_play_book_sheet(sheet_path, 4, 4, func() -> void:
		if _is_open:
			_tab = tab_id
			_refresh()
		_transition.visible = false
		_page_turning = false)


func _build() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.04, 0.88)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	_book_body = Control.new()
	_book_body.name = "Spellbook"
	_book_body.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_book_body.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_book_body)

	_book_art = TextureRect.new()
	_book_art.name = "OpenBookArtwork"
	_book_art.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_book_art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_book_art.stretch_mode = TextureRect.STRETCH_SCALE
	var book_atlas := AtlasTexture.new()
	book_atlas.atlas = load(BOOK_OPEN_SHEET) as Texture2D
	book_atlas.region = BOOK_OPEN_ART_REGION
	book_atlas.filter_clip = true
	_book_art.texture = book_atlas
	_book_body.add_child(_book_art)

	_page_content = Control.new()
	_page_content.name = "BookPageContent"
	_book_body.add_child(_page_content)

	var layout := VBoxContainer.new()
	layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layout.add_theme_constant_override("separation", 4)
	_page_content.add_child(layout)

	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 23.0
	layout.add_child(header)
	var title := Label.new()
	title.text = "CÂY KỸ NĂNG"
	title.add_theme_font_size_override("font_size", 18)
	title.add_theme_color_override("font_color", Color("263856"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	_balance_label = Label.new()
	_balance_label.add_theme_font_size_override("font_size", 10)
	_balance_label.add_theme_color_override("font_color", Color("344565"))
	_balance_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	header.add_child(_balance_label)

	_progress = ProgressBar.new()
	_progress.custom_minimum_size.y = 8.0
	_progress.show_percentage = false
	_progress.max_value = 100.0
	_progress.add_theme_stylebox_override("background", _progress_style(Color("b8a486")))
	_progress.add_theme_stylebox_override("fill", _progress_style(Color("5284b5")))
	_progress.tooltip_text = "Tổng điểm đã phân bổ"
	layout.add_child(_progress)

	var tabs := HBoxContainer.new()
	tabs.custom_minimum_size.y = 22.0
	layout.add_child(tabs)
	_add_tab(tabs, "weapon", "VŨ KHÍ")
	_add_tab(tabs, "character", "NHÂN VẬT")

	var divider := HSeparator.new()
	divider.add_theme_stylebox_override("separator", _progress_style(Color("496170")))
	layout.add_child(divider)

	var content_row := HBoxContainer.new()
	content_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content_row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	content_row.add_theme_constant_override("separation", 10)
	layout.add_child(content_row)

	_description_panel = PanelContainer.new()
	_description_panel.custom_minimum_size.x = 120.0
	_description_panel.size_flags_horizontal = Control.SIZE_FILL
	_description_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_description_panel.clip_contents = true
	var description_style := StyleBoxFlat.new()
	description_style.bg_color = Color("e8dcb9")
	description_style.border_color = Color("9a825e")
	description_style.set_border_width_all(2)
	description_style.set_corner_radius_all(5)
	description_style.set_content_margin_all(8.0)
	_description_panel.add_theme_stylebox_override("panel", description_style)
	content_row.add_child(_description_panel)

	var description_content := Control.new()
	description_content.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_description_panel.add_child(description_content)
	var description_layout := VBoxContainer.new()
	description_layout.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	description_layout.add_theme_constant_override("separation", 8)
	description_content.add_child(description_layout)
	_description_title = Label.new()
	_description_title.text = "THÔNG TIN"
	_description_title.autowrap_mode = TextServer.AUTOWRAP_WORD
	_description_title.add_theme_font_size_override("font_size", 10)
	_description_title.add_theme_color_override("font_color", Color("35415a"))
	description_layout.add_child(_description_title)
	var detail_divider := HSeparator.new()
	detail_divider.add_theme_stylebox_override("separator", _progress_style(Color("a48b62")))
	description_layout.add_child(detail_divider)
	_description_body = Label.new()
	_description_body.text = "Chọn nguyên tố để mở cây. Mỗi node tốn 1 SP.\n\nRê chuột xem mô tả. Cuộn để zoom, giữ chuột giữa để kéo."
	_description_body.autowrap_mode = TextServer.AUTOWRAP_WORD
	_description_body.add_theme_font_size_override("font_size", 8)
	_description_body.add_theme_color_override("font_color", Color("59637a"))
	_description_body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_description_body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_description_body.clip_text = true
	description_layout.add_child(_description_body)

	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content.size_flags_stretch_ratio = 1.0
	_content.add_theme_constant_override("separation", 5)
	content_row.add_child(_content)

	var footer := HBoxContainer.new()
	footer.custom_minimum_size.y = 24.0
	footer.alignment = BoxContainer.ALIGNMENT_CENTER
	layout.add_child(footer)
	var reset := Button.new()
	reset.text = "Reset miễn phí"
	reset.custom_minimum_size = Vector2(88.0, 22.0)
	reset.add_theme_font_size_override("font_size", 9)
	_style_book_button(reset)
	reset.pressed.connect(func() -> void: GameManager.reset_skill_tree())
	footer.add_child(reset)
	var close := Button.new()
	close.text = "Đóng"
	close.custom_minimum_size = Vector2(42.0, 22.0)
	close.add_theme_font_size_override("font_size", 9)
	_style_book_button(close)
	close.pressed.connect(func() -> void: set_open(false))
	footer.add_child(close)

	_transition = TextureRect.new()
	_transition.name = "BookAnimation"
	_transition.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_transition.stretch_mode = TextureRect.STRETCH_SCALE
	_transition.visible = false
	add_child(_transition)
	_layout_book()


func _add_tab(parent: HBoxContainer, tab_id: String, label_text: String) -> void:
	var button := Button.new()
	button.text = label_text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = 20.0
	button.add_theme_font_size_override("font_size", 9)
	_style_book_button(button)
	button.pressed.connect(func() -> void: _turn_to_tab(tab_id))
	parent.add_child(button)


func _layout_book() -> void:
	if not is_instance_valid(_book_art) or not is_instance_valid(_page_content) or not is_instance_valid(_book_body):
		return
	var viewport_size := get_viewport_rect().size
	var cell_size := minf(viewport_size.x * 0.94 / (246.0 / BOOK_FRAME_SIZE), viewport_size.y * 0.94 / (183.0 / BOOK_FRAME_SIZE))
	var book_size := Vector2(cell_size * 246.0 / BOOK_FRAME_SIZE, cell_size * 183.0 / BOOK_FRAME_SIZE)
	_book_art.size = book_size
	_book_art.position = (viewport_size - book_size) * 0.5
	_page_content.position = _book_art.position + Vector2(book_size.x * 0.08, book_size.y * 0.10)
	_page_content.size = Vector2(book_size.x * 0.84, book_size.y * 0.80)
	_page_content.clip_contents = true
	var transition_size := Vector2.ONE * cell_size
	_transition.size = transition_size
	_transition.position = Vector2(viewport_size.x * 0.5 - cell_size * 0.5, viewport_size.y * 0.5 - cell_size * (175.5 / BOOK_FRAME_SIZE))


func _refresh() -> void:
	if not is_instance_valid(_content):
		return
	var total_points: int = GameManager.total_skill_points()
	var spent_points: int = GameManager.allocated_skill_points()
	_balance_label.text = "✦ %d SP   ·   %d / %d" % [GameManager.skill_points, spent_points, total_points]
	_progress.value = 0.0 if total_points == 0 else 100.0 * float(spent_points) / float(total_points)
	_reset_skill_description()
	for child in _content.get_children():
		child.queue_free()
	if _tab == "weapon":
		_build_weapon_tree()
	else:
		_build_character_tree()


func _build_weapon_tree() -> void:
	var current_form: String = GameManager.weapon_form
	if current_form == "":
		_description_title.text = "CHỌN NGUYÊN TỐ"
		_description_body.text = "Chọn một biểu tượng lớn để mở cây. Mỗi nhánh cần 1 SP.\n\nCuộn để zoom; chuột giữa để kéo."
	else:
		_description_title.text = "CÂY VŨ KHÍ"
		_description_body.text = "Mốc kỹ năng: 1 / 4 / 6 / 9 SP.\nTiến hóa và tuyệt kỹ cần mở kỹ năng trước.\n\nCuộn để zoom; chuột giữa để kéo."
	var graph: SkillTreeGraph = TREE_GRAPH.new()
	_prepare_graph(graph)
	if current_form != "":
		graph.layout_offset_ratio = Vector2(0.04, 0.0)
	var root_color := Color("e5d08d")
	var root_position := Vector2(0.5, 0.86)
	_make_node(graph, root_position, "D", "Dao Găm", "BASIC", root_color, false, false, false, "Dao Găm Basic")
	if current_form == "":
		var form_positions: Array[Vector2] = [Vector2(0.27, 0.60), Vector2(0.73, 0.60), Vector2(0.27, 0.34), Vector2(0.73, 0.34)]
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
			_make_node(graph, position, form_id.substr(0, 1).to_upper(), str(form_data["short"]), "0/1", form_color, can_choose, already_chosen, false, form_tooltip, form_callback, _skill_icon_path(form_id + "_orb"), true)
		return

	var selected_form: Dictionary = _form_data(current_form)
	var form_color: Color = selected_form.color
	var form_position := Vector2(0.5, 0.68)
	graph.add_link(root_position, form_position, form_color, true)
	_make_node(graph, form_position, current_form.substr(0, 1).to_upper(), str(selected_form.short), "ĐÃ CHỌN", form_color, false, true, true, str(selected_form.name), Callable(), _skill_icon_path(current_form + "_orb"))
	var active_names: Array = ACTIVE_SKILLS[current_form]
	var short_names: Array = ACTIVE_SHORT_NAMES[current_form]
	var active_positions: Array[Vector2] = [Vector2(0.12, 0.50), Vector2(0.37, 0.50), Vector2(0.63, 0.50), Vector2(0.88, 0.50)]
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
		evolution_positions = [Vector2(0.2, 0.32), Vector2(0.5, 0.32), Vector2(0.8, 0.32)]
	else:
		evolution_positions = [Vector2(0.35, 0.32), Vector2(0.65, 0.32)]
	for index in evolution_data.size():
		var required_skill: String = str(evolution_data[index]["requires"])
		var required_slot := clampi(int(required_skill.get_slice("_", 2)) - 1, 0, active_positions.size() - 1)
		graph.add_link(active_positions[required_slot], evolution_positions[index], form_color.darkened(0.4), GameManager.skill_allocations.has(evolution_data[index]["id"]))
		_add_evolution_node(graph, evolution_positions[index], evolution_data[index], form_color)
	var ultimate_positions: Array[Vector2] = [Vector2(0.37, 0.14), Vector2(0.63, 0.14)]
	for index in evolution_positions.size():
		graph.add_link(evolution_positions[index], ultimate_positions[mini(index, 1)], form_color.darkened(0.45), GameManager.skill_allocations.has(evolution_data[index]["id"]))
	graph.add_link(active_positions[0], ultimate_positions[0], form_color.darkened(0.45), GameManager.unlocked_skills.has("active_%s_1" % current_form))
	graph.add_link(active_positions[1], ultimate_positions[0], form_color.darkened(0.45), GameManager.unlocked_skills.has("active_%s_2" % current_form))
	graph.add_link(active_positions[2], ultimate_positions[1], form_color.darkened(0.45), GameManager.unlocked_skills.has("active_%s_3" % current_form))
	graph.add_link(active_positions[3], ultimate_positions[1], form_color.darkened(0.45), GameManager.unlocked_skills.has("active_%s_4" % current_form))
	for index in ultimate_names.size():
		var skill_id := "ultimate_%s_%d" % [current_form, index + 1]
		var required: int = [5, 8][index]
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
	_make_node(graph, position, str(data.icon), str(data.short), "1/1" if rank > 0 else "%d SP" % int(data.req), color.lightened(0.12), can_buy, rank > 0, false, tooltip, purchase_callback, _skill_icon_path(str(data.icon_asset)))


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
	_make_node(graph, position, icon, short_name, rank_text, color, can_buy, unlocked, is_selected, tooltip, skill_callback, _skill_icon_path(_icon_kind_for_skill(skill_id)))


func _build_character_tree() -> void:
	_description_title.text = "CÂY NHÂN VẬT"
	_description_body.text = "Điểm dùng chung cho các nhánh. Rê chuột lên kỹ năng để xem chi tiết."
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
		label.add_theme_font_size_override("font_size", 8)
		label.add_theme_color_override("font_color", data.color)
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
			var position := Vector2(columns[column], [0.19, 0.5, 0.81][row])
			if row > 0:
				graph.add_link(Vector2(columns[column], [0.19, 0.5, 0.81][row - 1]), position, node_data.color.darkened(0.3))
			var rank := int(GameManager.skill_allocations.get(node_data.id, 0))
			var required := int(node_data.req)
			var can_buy := GameManager.skill_points > 0 and GameManager.total_skill_points() >= required and rank < int(node_data.max)
			var tooltip := "%s\n%s\nNhánh %s · Mốc %d điểm" % [node_data.name, node_data.desc, node_data.branch, required]
			_make_node(graph, position, str(node_data.icon), str(node_data.short), "%d/%d" % [rank, node_data.max], node_data.color, can_buy, rank > 0, false, tooltip, func() -> void:
				GameManager.spend_skill_point(str(node_data.id)))


func _make_node(graph: SkillTreeGraph, position: Vector2, icon: String, title: String, rank: String, accent: Color, available: bool, purchased: bool, selected: bool, tooltip: String, callback: Callable = Callable(), icon_path: String = "", prominent_icon: bool = false) -> SkillTreeNode:
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
	node.description_text = tooltip_lines[1] if tooltip_lines.size() > 1 else tooltip
	node.available = available
	node.purchased = purchased
	node.selected = selected
	node.tooltip_text = ""
	node.hover_changed.connect(_show_skill_description)
	if callback.is_valid():
		node.activated.connect(callback)
	graph.add_tree_node(node, position)
	return node


func _prepare_graph(graph: SkillTreeGraph) -> void:
	graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	graph.size_flags_vertical = Control.SIZE_EXPAND_FILL
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
	controls.custom_minimum_size.y = 22.0
	controls.add_theme_constant_override("separation", 2)
	var zoom_out := Button.new()
	zoom_out.text = "−"
	zoom_out.custom_minimum_size = Vector2(24.0, 20.0)
	zoom_out.add_theme_font_size_override("font_size", 12)
	_style_book_button(zoom_out)
	zoom_out.pressed.connect(func() -> void: _set_graph_zoom(_graph_zoom - 0.15))
	controls.add_child(zoom_out)
	_zoom_percent = Label.new()
	_zoom_percent.text = "100%"
	_zoom_percent.custom_minimum_size.x = 38.0
	_zoom_percent.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_zoom_percent.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_zoom_percent.add_theme_font_size_override("font_size", 8)
	_zoom_percent.add_theme_color_override("font_color", Color("344565"))
	controls.add_child(_zoom_percent)
	var zoom_in := Button.new()
	zoom_in.text = "+"
	zoom_in.custom_minimum_size = Vector2(24.0, 20.0)
	zoom_in.add_theme_font_size_override("font_size", 12)
	_style_book_button(zoom_in)
	zoom_in.pressed.connect(func() -> void: _set_graph_zoom(_graph_zoom + 0.15))
	controls.add_child(zoom_in)
	var zoom_reset := Button.new()
	zoom_reset.text = "↺"
	zoom_reset.custom_minimum_size = Vector2(24.0, 20.0)
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
	_description_title.add_theme_color_override("font_color", Color("35415a"))
	if _tab == "character":
		_description_title.text = "CÂY NHÂN VẬT"
		_description_body.text = "Điểm dùng chung cho các nhánh. Rê chuột xem chi tiết.\n\nCuộn để zoom; chuột giữa để kéo."
	elif GameManager.weapon_form == "":
		_description_title.text = "CHỌN NGUYÊN TỐ"
		_description_body.text = "Chọn biểu tượng nguyên tố để mở cây. Mỗi nhánh cần 1 SP.\n\nCuộn để zoom; chuột giữa để kéo."
	else:
		_description_title.text = "CÂY VŨ KHÍ"
		_description_body.text = "Mốc kỹ năng: 1 / 4 / 6 / 9 SP. Tiến hóa và tuyệt kỹ cần mở kỹ năng trước.\n\nCuộn để zoom; chuột giữa để kéo."


func _show_skill_description(title: String, description: String, color: Color) -> void:
	if not is_instance_valid(_description_title) or not is_instance_valid(_description_body):
		return
	if title.is_empty():
		_reset_skill_description()
		return
	_description_title.text = title
	_description_body.text = description
	_description_title.add_theme_color_override("font_color", color.darkened(0.35))


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
	normal.bg_color = Color("dfd0b1")
	normal.border_color = Color("80674d")
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(3)
	normal.set_content_margin_all(3.0)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = Color("efe1c4")
	hover.border_color = Color("4b6f95")
	var pressed := normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color("cbb997")
	pressed.border_color = Color("4b6f95")
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_color_override("font_color", Color("35415a"))
	button.add_theme_color_override("font_hover_color", Color("243652"))


func _progress_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(4)
	return style
