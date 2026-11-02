extends Control

const TREE_GRAPH := preload("res://ui/skill_tree_graph.gd")
const TREE_NODE := preload("res://ui/skill_tree_node.gd")
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

var _panel: PanelContainer
var _balance_label: Label
var _progress: ProgressBar
var _content: VBoxContainer
var _tab := "weapon"


func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_match_parent_canvas_scale()
	z_index = 100
	z_as_relative = false
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_build()
	GameManager.skill_progress_changed.connect(_refresh)
	_refresh()


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
		set_open(not visible)
		get_viewport().set_input_as_handled()
	elif visible and event.is_action_pressed("ui_cancel"):
		set_open(false)
		get_viewport().set_input_as_handled()


func set_open(open: bool) -> void:
	visible = open
	var hud := get_parent()
	if hud != null and hud.has_method("set_skill_tree_open"):
		hud.call("set_skill_tree_open", open)
	get_tree().paused = open
	if open:
		var player := get_tree().get_first_node_in_group("player") as Player
		if player != null:
			player.health += int(GameManager.skill_allocations.get("char_heal", 0))
		_refresh()


func _build() -> void:
	var shade := ColorRect.new()
	shade.color = Color(0.015, 0.025, 0.04, 0.88)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(shade)

	_panel = PanelContainer.new()
	_panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_panel.offset_left = 12.0
	_panel.offset_top = 10.0
	_panel.offset_right = -12.0
	_panel.offset_bottom = -10.0
	_panel.add_theme_stylebox_override("panel", _panel_style())
	add_child(_panel)

	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 4)
	_panel.add_child(layout)

	var header := HBoxContainer.new()
	header.custom_minimum_size.y = 23.0
	layout.add_child(header)
	var title := Label.new()
	title.text = "CÂY KỸ NĂNG"
	title.add_theme_font_size_override("font_size", 15)
	title.add_theme_color_override("font_color", Color("f4e8c4"))
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	_balance_label = Label.new()
	_balance_label.add_theme_font_size_override("font_size", 10)
	_balance_label.add_theme_color_override("font_color", Color("d9e7ef"))
	header.add_child(_balance_label)

	_progress = ProgressBar.new()
	_progress.custom_minimum_size.y = 8.0
	_progress.show_percentage = false
	_progress.max_value = 100.0
	_progress.add_theme_stylebox_override("background", _progress_style(Color("263847")))
	_progress.add_theme_stylebox_override("fill", _progress_style(Color("6dc6d8")))
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

	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	layout.add_child(scroll)
	_content = VBoxContainer.new()
	_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content.add_theme_constant_override("separation", 5)
	scroll.add_child(_content)

	var footer := HBoxContainer.new()
	footer.custom_minimum_size.y = 24.0
	layout.add_child(footer)
	var hint := Label.new()
	hint.text = "Cuộn chuột để xem cây  ·  1–4 chọn skill  ·  U dùng  ·  I tuyệt kỹ  ·  T / Esc đóng"
	hint.add_theme_font_size_override("font_size", 8)
	hint.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(hint)
	var reset := Button.new()
	reset.text = "Reset miễn phí"
	reset.custom_minimum_size = Vector2(88.0, 22.0)
	reset.add_theme_font_size_override("font_size", 9)
	reset.pressed.connect(func() -> void: GameManager.reset_skill_tree())
	footer.add_child(reset)
	var close := Button.new()
	close.text = "Đóng"
	close.custom_minimum_size = Vector2(42.0, 22.0)
	close.add_theme_font_size_override("font_size", 9)
	close.pressed.connect(func() -> void: set_open(false))
	footer.add_child(close)


func _add_tab(parent: HBoxContainer, tab_id: String, label_text: String) -> void:
	var button := Button.new()
	button.text = label_text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.custom_minimum_size.y = 20.0
	button.add_theme_font_size_override("font_size", 9)
	button.pressed.connect(func() -> void:
		_tab = tab_id
		_refresh())
	parent.add_child(button)


func _refresh() -> void:
	if not is_instance_valid(_content):
		return
	var total_points: int = GameManager.total_skill_points()
	var spent_points: int = GameManager.allocated_skill_points()
	_balance_label.text = "✦ %d SP   ·   %d / %d" % [GameManager.skill_points, spent_points, total_points]
	_progress.value = 0.0 if total_points == 0 else 100.0 * float(spent_points) / float(total_points)
	for child in _content.get_children():
		child.queue_free()
	if _tab == "weapon":
		_build_weapon_tree()
	else:
		_build_character_tree()


func _build_weapon_tree() -> void:
	var current_form: String = GameManager.weapon_form
	_content.add_child(_section("DAO GĂM BASIC  →  CHỌN MỘT DẠNG VŨ KHÍ"))
	if current_form != "":
		_content.add_child(_section("KỸ NĂNG · MỐC 1 / 4 / 6 / 9 SP     —     TIẾN HÓA · MỐC 3–10 SP     —     TUYỆT KỸ · MỐC 5 / 8 SP"))
	var graph: SkillTreeGraph = TREE_GRAPH.new()
	graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	graph.custom_minimum_size.y = 380.0 if current_form == "" else 560.0
	_content.add_child(graph)
	var root_color := Color("e5d08d")
	var root_position := Vector2(0.5, 0.90 if current_form == "" else 0.93)
	_make_node(graph, root_position, "D", "Dao Găm", "BASIC", root_color, false, false, false, "Dao Găm Basic")
	if current_form == "":
		var form_positions: Array[Vector2] = [Vector2(0.27, 0.57), Vector2(0.73, 0.57), Vector2(0.27, 0.31), Vector2(0.73, 0.31)]
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
			_make_node(graph, position, form_id.substr(0, 1).to_upper(), str(form_data["short"]), "0/1", form_color, can_choose, already_chosen, false, str(form_data["name"]), form_callback, _skill_icon_path(form_id + "_orb"))
		_content.add_child(_section("Dùng 1 SP để chọn một nhánh nguyên tố. Cây vũ khí sẽ phát triển theo nhánh đã chọn."))
		return

	var selected_form: Dictionary = _form_data(current_form)
	var form_color: Color = selected_form.color
	var form_position := Vector2(0.5, 0.75)
	graph.add_link(root_position, form_position, form_color, true)
	_make_node(graph, form_position, current_form.substr(0, 1).to_upper(), str(selected_form.short), "ĐÃ CHỌN", form_color, false, true, true, str(selected_form.name), Callable(), _skill_icon_path(current_form + "_orb"))
	var active_names: Array = ACTIVE_SKILLS[current_form]
	var short_names: Array = ACTIVE_SHORT_NAMES[current_form]
	var active_positions: Array[Vector2] = [Vector2(0.12, 0.52), Vector2(0.37, 0.52), Vector2(0.63, 0.52), Vector2(0.88, 0.52)]
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
		evolution_positions = [Vector2(0.2, 0.30), Vector2(0.5, 0.30), Vector2(0.8, 0.30)]
	else:
		evolution_positions = [Vector2(0.35, 0.30), Vector2(0.65, 0.30)]
	for index in evolution_data.size():
		var required_skill: String = str(evolution_data[index]["requires"])
		var required_slot := clampi(int(required_skill.get_slice("_", 2)) - 1, 0, active_positions.size() - 1)
		graph.add_link(active_positions[required_slot], evolution_positions[index], form_color.darkened(0.4), GameManager.skill_allocations.has(evolution_data[index]["id"]))
		_add_evolution_node(graph, evolution_positions[index], evolution_data[index], form_color)
	var ultimate_positions: Array[Vector2] = [Vector2(0.37, 0.10), Vector2(0.63, 0.10)]
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
	_content.add_child(_section("CÂY NHÂN VẬT  ·  ĐIỂM DÙNG CHUNG  ·  CẤP ĐỘ CỘNG DỒN"))
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
	graph.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	graph.custom_minimum_size.y = 380.0
	_content.add_child(graph)
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


func _make_node(graph: SkillTreeGraph, position: Vector2, icon: String, title: String, rank: String, accent: Color, available: bool, purchased: bool, selected: bool, tooltip: String, callback: Callable = Callable(), icon_path: String = "") -> SkillTreeNode:
	var node: SkillTreeNode = TREE_NODE.new()
	node.icon_text = icon
	if icon_path != "":
		node.icon_texture = load(icon_path) as Texture2D
	node.title_text = title
	node.rank_text = rank
	node.accent_color = accent
	node.available = available
	node.purchased = purchased
	node.selected = selected
	node.tooltip_text = tooltip
	if callback.is_valid():
		node.activated.connect(callback)
	graph.add_tree_node(node, position)
	return node


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


func _section(text: String) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color("a8d9e2"))
	label.add_theme_font_size_override("font_size", 8)
	return label


func _panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color("101c28")
	style.border_color = Color("74c5d6")
	style.set_border_width_all(2)
	style.set_content_margin_all(8)
	style.set_corner_radius_all(5)
	return style


func _progress_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(4)
	return style
