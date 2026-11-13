extends Node
## Run rendered in a disposable project with custom user dir ArcanaSettings-T085.
var checks := 0
var failures := 0
var stage: Node

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
	print("PASS " if ok else "FAIL ", label)

func frames(count: int = 3) -> void:
	for index in count:
		await get_tree().process_frame

func key(code: Key, pressed: bool = true) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func tap(code: Key) -> void:
	key(code)
	await frames(2)
	key(code, false)
	await frames(3)

func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	print("LAYOUT ", label, " viewport=", get_viewport().get_visible_rect().size, " panel=", PauseMenu._panel.size, " min=", PauseMenu._panel.get_combined_minimum_size(), " scale=", PauseMenu._panel.scale)
	check(get_viewport().get_visible_rect().encloses(Rect2(PauseMenu._panel.position, PauseMenu._panel.size * PauseMenu._panel.scale)), "layout fits: " + label)
	get_viewport().get_texture().get_image().save_png("user://settings-%s.png" % label)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not "ArcanaSettings-T085" in OS.get_user_data_dir():
		push_error("Refusing to test against real game saves/settings")
		get_tree().quit(2)
		return
	if OS.get_cmdline_user_args().has("--verify-settings-restart"):
		check(is_equal_approx(GameSettings.values.sfx, 0.37) and is_equal_approx(GameSettings.values.sensitivity, 0.21), "fresh process restores saved preferences")
		check(GameSettings.bindings.attack[0] == {"key": KEY_B}, "fresh process restores saved key mapping")
		print("SETTINGS_RESTART_RESULT ", checks - failures, "/", checks)
		get_tree().quit(1 if failures else 0)
		return
	GameSettings.settings_path = "user://test-settings.cfg"
	GameSettings.reset_defaults()
	stage = load("res://levels/level_1/basement_full.tscn").instantiate()
	stage.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(stage)
	var player: Node3D = stage.get_node("Player")
	player.set("invincible", true)
	var rig: Node = stage.get_node("CameraRig")
	await frames(60)
	var skill_tree: Node = stage.get_node("Hud/SkillTreeLayer/SkillTree")
	check(skill_tree != null, "real basement Skill Tree present")
	await tap(KEY_ESCAPE)
	check(PauseMenu.is_open and get_tree().paused, "Escape pauses real basement")
	check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "menu explicitly shows cursor")
	var position_before := player.global_position
	key(KEY_W)
	await frames(15)
	key(KEY_W, false)
	check(player.global_position.is_equal_approx(position_before), "movement does not run while paused")
	await tap(KEY_T)
	check(not skill_tree.visible, "Skill Tree shortcut cannot open behind pause menu")
	await capture("home")
	await tap(KEY_TAB)
	await tap(KEY_ENTER)
	check(PauseMenu._page == "settings", "keyboard activates Settings from pause menu")
	await frames()
	await capture("controls")
	(PauseMenu._body.get_node("ContentScroll") as ScrollContainer).scroll_vertical = 10000
	await frames()
	await capture("controls-bottom")
	var old_bindings: Dictionary = GameSettings.bindings.duplicate(true)
	var event := InputEventKey.new()
	event.physical_keycode = KEY_W
	check(not GameSettings.bind_event("attack", 0, event).is_empty(), "duplicate gameplay key is rejected")
	check(GameSettings.bindings == old_bindings, "conflict leaves complete binding map unchanged")
	event.physical_keycode = KEY_ESCAPE
	check(not GameSettings.bind_event("attack", 0, event).is_empty(), "Escape reserved for menus")
	event.physical_keycode = KEY_F5
	check(not GameSettings.bind_event("attack", 0, event).is_empty(), "new-game shortcut reserved")
	event.physical_keycode = KEY_B
	check(GameSettings.bind_event("attack", 0, event).is_empty(), "unused key can be rebound")
	check(InputMap.action_has_event("attack", event), "rebind updates actual InputMap")
	event.physical_keycode = KEY_O
	check(GameSettings.bind_event("active_skill_1", 0, event).is_empty(), "skill slot key can be rebound")
	var hud: Node = stage.get_node("Hud")
	hud.call("_refresh_skill_bar")
	check(hud.get("_input_key_labels")[0].text == "O", "HUD shows rebound skill slot key")
	check(GameSettings.clear_binding("jump", 0) != "", "cannot remove the final action binding")
	PauseMenu._start_binding("skill", 0)
	await tap(KEY_ESCAPE)
	check(PauseMenu._binding_action.is_empty() and PauseMenu._page == "settings", "Escape cancels capture without leaving settings")
	PauseMenu._edit("sensitivity", 0.26)
	PauseMenu._edit("invert_y", true)
	PauseMenu._edit("fov", 74.0)
	check(is_equal_approx(rig.get("mouse_sensitivity"), 0.26) and rig.get("invert_y"), "camera receives live sensitivity/invert settings")
	check(is_equal_approx((rig.get_node("Camera3D") as Camera3D).fov, 74.0), "camera FOV preview applied")
	PauseMenu._show_tab(1)
	PauseMenu._edit("sfx", 0.25)
	check(is_equal_approx(AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("SFX")), 0.25), "SFX slider controls live mixer")
	PauseMenu._edit("mute", true)
	check(AudioServer.is_bus_mute(0), "master mute takes effect")
	PauseMenu._edit("mute", false)
	GameSettings._notification(NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(AudioServer.is_bus_mute(0), "background mute on focus loss")
	GameSettings._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
	check(not AudioServer.is_bus_mute(0), "focus gain restores audio")
	await capture("audio")
	PauseMenu._cancel_settings()
	check(GameSettings.bindings == old_bindings and is_equal_approx(rig.get("mouse_sensitivity"), 0.12), "cancel restores bindings and camera")
	check(is_equal_approx(AudioServer.get_bus_volume_linear(AudioServer.get_bus_index("SFX")), 1.0), "cancel restores mixer")
	PauseMenu.open_settings()
	PauseMenu._edit("sfx", 0.41)
	PauseMenu._edit("show_fps", true)
	PauseMenu._apply_settings()
	check(FileAccess.file_exists(GameSettings.settings_path), "Apply writes settings file")
	var saved: Dictionary = GameSettings.snapshot()
	GameSettings.values.sfx = 0.0
	GameSettings.load_settings()
	check(GameSettings.snapshot() == saved, "ConfigFile reload round trip")
	PauseMenu._edit("sfx", 0.55)
	PauseMenu._apply_settings()
	GameSettings.load_settings()
	check(is_equal_approx(GameSettings.values.sfx, 0.55), "second Apply replaces existing settings file")
	PauseMenu._show_tab(2)
	await capture("display")
	var previous_mode: int = GameSettings.values.window_mode
	PauseMenu._edit("window_mode", 2)
	PauseMenu._apply_settings()
	check(PauseMenu._confirmation == "display", "mode change requires confirmation")
	await tap(KEY_TAB)
	check(PauseMenu._dialog.is_ancestor_of(get_viewport().gui_get_focus_owner()), "confirmation traps keyboard focus")
	check(get_window().mode == Window.MODE_FULLSCREEN, "fullscreen applied by DisplayServer")
	PauseMenu._display_seconds = 0.01
	PauseMenu._process(0.02)
	check(GameSettings.values.window_mode == previous_mode and get_window().mode == Window.MODE_WINDOWED, "timeout restores original window mode")
	check(PauseMenu._confirmation.is_empty(), "timeout dismisses confirmation")
	PauseMenu._edit("window_mode", 1)
	PauseMenu._apply_settings()
	check(get_window().borderless, "borderless mode applied")
	await tap(KEY_ESCAPE)
	check(not get_window().borderless and PauseMenu._page == "settings", "Escape reverts risky display mode")
	PauseMenu._edit("resolution", 0)
	PauseMenu._apply_settings()
	PauseMenu._accept_confirmation()
	PauseMenu._show_tab(2)
	await frames(6)
	check(get_window().size == Vector2i(960, 540), "confirmed 960x540 window size")
	await capture("small-display")
	var panel_rect := Rect2(PauseMenu._panel.position, PauseMenu._panel.size * PauseMenu._panel.scale)
	check(get_viewport().get_visible_rect().encloses(panel_rect), "menu fits smaller viewport")
	PauseMenu._show_confirmation("reset", "reset", "reset")
	PauseMenu._accept_confirmation()
	check(GameSettings.values == GameSettings.defaults and GameSettings.bindings == GameSettings.default_bindings, "defaults restore all preferences and action slots")
	PauseMenu._cancel_settings()
	PauseMenu.open_settings()
	GameSettings.settings_path = "user://missing-directory/settings.cfg"
	PauseMenu._apply_settings()
	check(PauseMenu._status.text.begins_with("Chưa lưu"), "write failure is surfaced instead of claiming saved")
	GameSettings.settings_path = "user://test-settings.cfg"
	PauseMenu._cancel_settings()
	await tap(KEY_ESCAPE)
	await frames(4)
	check(not PauseMenu.is_open and not get_tree().paused, "Escape resumes gameplay")
	check(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED, "camera recaptures gameplay cursor after resume")
	await tap(KEY_T)
	await get_tree().create_timer(1.2, true).timeout
	check(skill_tree.visible and get_tree().paused, "existing Skill Tree opens normally")
	print("SKILL_TREE_STATE ", skill_tree.visible, " open=", skill_tree.get("_is_open"), " paused=", get_tree().paused, " transitioning=", skill_tree.get("_transitioning"))
	print("PAUSE_MENU_STATE ", PauseMenu.is_open)
	for tree in stage.find_children("SkillTree", "", true, false):
		print("TREE ", tree.get_path(), " visible=", tree.visible, " open=", tree.get("_is_open"))
	check(not PauseMenu.open_menu(), "pause menu refuses to steal another pause owner")
	await tap(KEY_ESCAPE)
	await get_tree().create_timer(1.2, true).timeout
	check(not skill_tree.visible and not PauseMenu.is_open and not get_tree().paused, "Escape closes Skill Tree without opening pause menu")
	get_tree().paused = true
	await tap(KEY_ESCAPE)
	check(not PauseMenu.is_open and get_tree().paused, "cinematic pause remains owned externally")
	get_tree().paused = false
	var config := ConfigFile.new()
	config.set_value("meta", "version", 1)
	config.set_value("settings", "sfx", -10.0)
	config.set_value("settings", "resolution", 999)
	config.set_value("settings", "sensitivity", "bad")
	config.set_value("bindings", "jump", [{"key": KEY_W}, {}])
	config.save(GameSettings.settings_path)
	GameSettings.load_settings()
	check(GameSettings.values.sfx == 0.0 and GameSettings.values.resolution == 4 and GameSettings.values.sensitivity == 0.12, "invalid settings types and bounds normalized")
	check(GameSettings.bindings == GameSettings.default_bindings, "corrupt/conflicting map falls back atomically")
	GameSettings.reset_defaults()
	GameSettings.values.sfx = 0.37
	GameSettings.values.sensitivity = 0.21
	event.physical_keycode = KEY_B
	GameSettings.bind_event("attack", 0, event)
	GameSettings.settings_path = GameSettings.PATH
	check(GameSettings.save_settings() == OK, "write fixture for separate-process restart test")
	print("SETTINGS_MENU_RESULT ", checks - failures, "/", checks, " USER_DATA ", OS.get_user_data_dir())
	get_tree().quit(1 if failures else 0)
