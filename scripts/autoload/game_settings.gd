extends Node
## Preferences are independent of checkpoint progress. Only primitive data is loaded.
signal changed
const PATH := "user://settings.cfg"
const ACTIONS := {
	"inventory": "Túi đồ / Trang bị", "use_consumable": "Dùng vật phẩm nhanh", "lock_on": "Khóa mục tiêu",
	"up": "Di chuyển lên", "down": "Di chuyển xuống", "left": "Di chuyển trái",
	"right": "Di chuyển phải", "jump": "Nhảy", "dash": "Lướt", "attack": "Tấn công",
	"parry": "Đỡ đòn", "carry": "Nhấc / ném", "skill": "Dùng kỹ năng",
	"ultimate": "Tuyệt kỹ", "interact": "Tương tác", "skill_tree": "Cây kỹ năng",
	"active_skill_1": "Ô kỹ năng 1", "active_skill_2": "Ô kỹ năng 2",
	"active_skill_3": "Ô kỹ năng 3", "active_skill_4": "Ô kỹ năng 4",
}
const SIZES := [Vector2i(960, 540), Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080), Vector2i(2560, 1440)]
const LIMITS := [0, 30, 60, 90, 120, 144, 165, 240]
const BASE := {
	"sensitivity": 0.12, "invert_y": false, "fov": 60.0,
	"master": 1.0, "music": 0.8, "sfx": 1.0, "ui": 0.8,
	"mute": false, "background_mute": true, "window_mode": 0, "resolution": 1,
	"vsync": true, "fps_limit": 0, "render_scale": 1.0, "msaa": 0, "show_fps": false,
}
var values: Dictionary = {}
var defaults: Dictionary = {}
var bindings: Dictionary = {}
var default_bindings: Dictionary = {}
var settings_path := PATH
var load_notice := ""
var _focused := true

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for entry in [["inventory", KEY_B], ["use_consumable", KEY_Q], ["lock_on", KEY_G]]:
		if not InputMap.has_action(entry[0]):
			InputMap.add_action(entry[0])
			var key := InputEventKey.new()
			key.physical_keycode = entry[1]
			InputMap.action_add_event(entry[0], key)
	defaults = BASE.duplicate(true)
	for action: String in ACTIONS:
		var slots: Array = []
		for event in InputMap.action_get_events(action):
			var encoded := encode_event(event)
			if not encoded.is_empty() and slots.size() < 2:
				slots.append(encoded)
		while slots.size() < 2:
			slots.append({})
		default_bindings[action] = slots
	for bus in ["Music", "SFX", "UI"]:
		if AudioServer.get_bus_index(bus) == -1:
			AudioServer.add_bus()
			var index := AudioServer.bus_count - 1
			AudioServer.set_bus_name(index, bus)
			AudioServer.set_bus_send(index, "Master")
	load_settings()
	apply()

func snapshot() -> Dictionary:
	return {"values": values.duplicate(true), "bindings": bindings.duplicate(true)}

func restore(state: Dictionary) -> void:
	values = state.values.duplicate(true)
	bindings = state.bindings.duplicate(true)
	apply()

func reset_defaults() -> void:
	values = defaults.duplicate(true)
	bindings = default_bindings.duplicate(true)
	apply()

func load_settings() -> void:
	values = defaults.duplicate(true)
	bindings = default_bindings.duplicate(true)
	load_notice = ""
	var config := ConfigFile.new()
	var error := config.load(settings_path)
	if error == ERR_FILE_NOT_FOUND:
		return
	if error != OK or config.get_value("meta", "version", 0) != 1:
		load_notice = "Không đọc được cài đặt cũ; đang dùng mặc định."
		return
	for key: String in defaults:
		var value: Variant = config.get_value("settings", key, defaults[key])
		if typeof(value) == typeof(defaults[key]) or (defaults[key] is float and value is int):
			values[key] = value
	for key in ["master", "music", "sfx", "ui"]:
		values[key] = _finite_clamp(values[key], 0.0, 1.0, defaults[key])
	values.sensitivity = _finite_clamp(values.sensitivity, 0.02, 0.5, 0.12)
	values.fov = _finite_clamp(values.fov, 45.0, 85.0, 60.0)
	values.render_scale = _finite_clamp(values.render_scale, 0.5, 1.0, 1.0)
	values.window_mode = clampi(values.window_mode, 0, 2)
	values.resolution = clampi(values.resolution, 0, SIZES.size() - 1)
	values.fps_limit = values.fps_limit if values.fps_limit in LIMITS else 0
	values.msaa = clampi(values.msaa, 0, 3)
	var candidate := default_bindings.duplicate(true)
	for action: String in ACTIONS:
		var slots: Variant = config.get_value("bindings", action, candidate[action])
		if slots is Array and slots.size() == 2 and _valid_binding(slots[0]) and _valid_binding(slots[1]) \
				and (not slots[0].is_empty() or not slots[1].is_empty()):
			candidate[action] = slots
	# Preserve legacy custom keys when a newly introduced default would collide.
	for new_action in ["inventory", "use_consumable", "lock_on"]:
		if config.has_section_key("bindings", new_action):
			continue
		for slot in 2:
			var binding: Dictionary = candidate[new_action][slot]
			if binding.is_empty():
				continue
			for other: String in ACTIONS:
				if other != new_action and binding in candidate[other]:
					candidate[new_action][slot] = {}
	# Reject the entire saved map on any remaining conflict.
	var seen: Array = []
	for action: String in ACTIONS:
		for binding: Dictionary in candidate[action]:
			if binding.is_empty():
				continue
			if binding in seen:
				load_notice = "Phím đã lưu bị trùng; đã dùng bộ phím mặc định."
				return
			seen.append(binding)
	bindings = candidate

func _finite_clamp(value: float, low: float, high: float, fallback: float) -> float:
	return clampf(value, low, high) if is_finite(value) else fallback

func save_settings() -> Error:
	var config := ConfigFile.new()
	config.set_value("meta", "version", 1)
	for key: String in values:
		config.set_value("settings", key, values[key])
	for action: String in bindings:
		config.set_value("bindings", action, bindings[action])
	var error := config.save(settings_path + ".tmp")
	if error != OK:
		return error
	return DirAccess.rename_absolute(settings_path + ".tmp", settings_path)

func encode_event(event: InputEvent) -> Dictionary:
	if event is InputEventKey:
		return {"key": int(event.physical_keycode if event.physical_keycode != 0 else event.keycode)}
	if event is InputEventMouseButton:
		return {"mouse": int(event.button_index)}
	return {}

func _valid_binding(binding: Variant) -> bool:
	if not binding is Dictionary:
		return false
	if binding.is_empty():
		return true
	if binding.size() != 1:
		return false
	if binding.has("key") and binding.key is int:
		return binding.key > 0 and binding.key <= 0x7fffff and not OS.get_keycode_string(binding.key).is_empty() and not _reserved(binding.key)
	return binding.has("mouse") and binding.mouse is int and binding.mouse in [1, 2, 3, 8, 9]

func _reserved(code: int) -> bool:
	return code in [KEY_ESCAPE, KEY_ALT, KEY_TAB, KEY_ENTER, KEY_KP_ENTER, KEY_F5, KEY_F6, KEY_F8, KEY_F11]

func bind_event(action: String, slot: int, event: InputEvent) -> String:
	if not ACTIONS.has(action) or slot not in [0, 1]:
		return "Ô phím không hợp lệ."
	if event is InputEventKey and (event.alt_pressed or event.ctrl_pressed or event.meta_pressed):
		return "Dùng một phím đơn, không kèm Ctrl / Alt / Win."
	var binding := encode_event(event)
	if binding.is_empty() or not _valid_binding(binding):
		return "Phím này dành cho hệ thống / menu; hãy chọn phím khác."
	for other: String in bindings:
		for index in 2:
			if other == action and index == slot:
				continue
			if bindings[other][index] == binding:
				return "Đã dùng cho «%s». Chọn phím khác." % ACTIONS[other]
	bindings[action][slot] = binding
	apply_bindings()
	return ""

func clear_binding(action: String, slot: int) -> String:
	if bindings[action][1 - slot].is_empty():
		return "Mỗi hành động cần ít nhất một phím."
	bindings[action][slot] = {}
	apply_bindings()
	return ""

func binding_text(binding: Dictionary) -> String:
	if binding.has("key"):
		return OS.get_keycode_string(binding.key)
	if binding.has("mouse"):
		return {1: "Chuột trái", 2: "Chuột phải", 3: "Chuột giữa", 8: "Chuột 4", 9: "Chuột 5"}.get(binding.mouse, "Chuột")
	return "—"

func apply_bindings() -> void:
	for action: String in bindings:
		# Retain device bindings supplied elsewhere (e.g. a controller).
		for event in InputMap.action_get_events(action):
			if event is InputEventKey or event is InputEventMouseButton:
				InputMap.action_erase_event(action, event)
		for binding: Dictionary in bindings[action]:
			if binding.has("key"):
				var event := InputEventKey.new()
				event.physical_keycode = binding.key
				InputMap.action_add_event(action, event)
			elif binding.has("mouse"):
				var event := InputEventMouseButton.new()
				event.button_index = binding.mouse
				InputMap.action_add_event(action, event)

func apply() -> void:
	apply_bindings()
	apply_audio()
	apply_display()
	changed.emit()

func apply_audio() -> void:
	for pair in [["Master", "master"], ["Music", "music"], ["SFX", "sfx"], ["UI", "ui"]]:
		var index := AudioServer.get_bus_index(pair[0])
		AudioServer.set_bus_volume_db(index, linear_to_db(maxf(0.0001, values[pair[1]])))
		AudioServer.set_bus_mute(index, values[pair[1]] <= 0.0)
	AudioServer.set_bus_mute(0, values.mute or values.master <= 0.0 or (values.background_mute and not _focused))

func _notification(what: int) -> void:
	if values.is_empty():
		return
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT or what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_focused = what == NOTIFICATION_APPLICATION_FOCUS_IN
		apply_audio()

func apply_camera(rig: Node) -> void:
	rig.set("mouse_sensitivity", values.sensitivity)
	rig.set("invert_y", values.invert_y)
	rig.set("camera_fov", values.fov)
	var camera := rig.get_node_or_null("Camera3D") as Camera3D
	if camera != null:
		camera.fov = values.fov

func apply_display() -> void:
	Engine.max_fps = values.fps_limit
	get_viewport().scaling_3d_scale = values.render_scale
	get_viewport().msaa_3d = values.msaa
	if DisplayServer.get_name() == "headless":
		return
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if values.vsync else DisplayServer.VSYNC_DISABLED)
	var window := get_window()
	var mode: int = values.window_mode
	if mode == 2:
		window.mode = Window.MODE_FULLSCREEN
	else:
		var target_size: Vector2i = SIZES[values.resolution]
		var screen := DisplayServer.screen_get_usable_rect(window.current_screen)
		if mode == 1:
			target_size = screen.size
		else:
			target_size = target_size.min(screen.size)
		if window.mode != Window.MODE_WINDOWED or window.borderless != (mode == 1) or window.size != target_size:
			window.mode = Window.MODE_WINDOWED
			window.borderless = mode == 1
			window.size = target_size
			window.position = screen.position + (screen.size - target_size) / 2
