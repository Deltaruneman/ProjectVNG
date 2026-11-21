extends Node3D
## Run only in an isolated project/user directory, never against real saves.
var player: Player
var menu: SkillTreeUI
var checks := 0
var failures := 0
var pause_only := OS.get_cmdline_user_args().has("--pause-only")

func check(ok: bool, label: String) -> void:
	checks += 1
	failures += 0 if ok else 1
	print("PASS " if ok else "FAIL ", label)

func wait_seconds(seconds: float) -> void:
	await get_tree().create_timer(seconds, true).timeout

func press(action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	Input.parse_input_event(event)
	event = InputEventAction.new()
	event.action = action
	Input.parse_input_event(event)

func close_menu() -> void:
	menu.set_open(false)
	await wait_seconds(2.0)

func set_regen_rank(rank: int) -> void:
	GameManager.skill_allocations["char_heal"] = rank
	GameManager.skill_progress_changed.emit()

func check_health_regeneration() -> void:
	var saved_sp := GameManager.skill_points
	var saved_spending := GameManager.skill_spending.duplicate(true)
	for rank in range(1, 4):
		set_regen_rank(rank)
		player.health = player.max_health
		player.health = 1
		var interval: float = [60.0, 40.0, 20.0][rank - 1]
		player._update_health_regeneration(interval - 0.1)
		check(player.health == 1, "no early heal rank %d at %.1fs" % [rank, interval - 0.1])
		player._update_health_regeneration(0.11)
		check(player.health == 2, "one HP at approved interval rank %d" % rank)
		player._update_health_regeneration(interval)
		check(player.health == player.max_health and is_zero_approx(player._health_regen_elapsed), "cap and reset at full rank %d" % rank)
		player._update_health_regeneration(1000.0)
		player.health = 1
		player._update_health_regeneration(0.1)
		check(player.health == 1, "no full-health time bank rank %d" % rank)
	set_regen_rank(0)
	player._update_health_regeneration(1000.0)
	check(player.health == 1 and is_zero_approx(player._health_regen_elapsed), "unlearned skill never heals")
	set_regen_rank(1)
	player._update_health_regeneration(59.0)
	set_regen_rank(2)
	check(is_zero_approx(player._health_regen_elapsed) and player.health == 1, "rank change clears credit without healing")
	player._update_health_regeneration(39.0)
	set_regen_rank(0)
	set_regen_rank(2)
	check(is_zero_approx(player._health_regen_elapsed), "rank removal and relearn cannot retain credit")
	player._update_health_regeneration(39.0)
	player.health = player.max_health
	player.health = 1
	player._update_health_regeneration(1.0)
	check(player.health == 1, "instant full heal then damage resets previous credit")
	player.health = 0
	player._update_health_regeneration(1000.0)
	check(player.health == 0 and is_zero_approx(player._health_regen_elapsed), "dead Player cannot regenerate or bank credit")
	player.health = 1
	player._update_health_regeneration(10.0)
	get_tree().paused = true
	player._update_health_regeneration(1000.0)
	check(player.health == 1 and is_equal_approx(player._health_regen_elapsed, 10.0), "foreign pause retains only prior gameplay time")
	get_tree().paused = false
	player._update_health_regeneration(30.0)
	check(player.health == 2, "resume completes saved partial interval")
	check(GameManager.skill_points == saved_sp and GameManager.skill_spending == saved_spending, "regeneration does not alter SP or purchase history")
	set_regen_rank(3)
	player.health = player.max_health
	player.health = 1
	await wait_seconds(19.5)
	check(player.health == 1 and player._health_regen_elapsed > 19.0, "real physics gameplay does not heal before 20s")
	press("skill_tree")
	await wait_seconds(1.0)
	var paused_elapsed := player._health_regen_elapsed
	await wait_seconds(1.0)
	check(player.health == 1 and is_equal_approx(player._health_regen_elapsed, paused_elapsed), "book pause crossing wall-clock threshold cannot heal")
	await close_menu()
	check(player.health == 2, "real gameplay resumes and heals one HP after 20 active seconds")
	check(GameManager.skill_allocations.get("char_heal") == 3, "rank retained across menu and timed recovery")

func _ready() -> void:
	if not "ArcanaMenu-20261121" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	process_mode = Node.PROCESS_MODE_ALWAYS
	SaveSystem.save_path = "user://menu-fixture.json"
	GameManager.reset()
	var floor_body := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(40, 0.2, 40)
	collider.shape = shape
	floor_body.add_child(collider)
	floor_body.position.y = -0.1
	add_child(floor_body)
	player = preload("res://scenes/player/player.tscn").instantiate()
	player.process_mode = Node.PROCESS_MODE_PAUSABLE
	add_child(player)
	player.invincible = true
	var rig := preload("res://scenes/camera/camera_rig.tscn").instantiate()
	rig.process_mode = Node.PROCESS_MODE_PAUSABLE
	rig.target = player
	add_child(rig)
	menu = player.get_node("Hud/SkillTreeLayer/SkillTree")
	await wait_seconds(0.3)
	if not pause_only:
		await check_health_regeneration()
	set_regen_rank(3)
	player.health = player.max_health
	player.health = 1
	press("skill_tree")
	await wait_seconds(1.0)
	check(menu.is_open() and get_tree().paused, "ordinary T opens and pauses")
	if not pause_only:
		check(player.health == 1, "opening T at low health never heals")
	press("ui_cancel")
	await wait_seconds(1.0)
	check(not menu.is_open() and not get_tree().paused, "Escape closes and resumes")
	for i in 10:
		press("skill_tree")
		await wait_seconds(0.06)
	await close_menu()
	check(not menu.is_open() and not get_tree().paused, "rapid ordinary T reversals settle closed")
	if not pause_only:
		check(player.health == 1, "rapid reopen never heals")
	get_tree().paused = true
	menu.set_open(true)
	check(not menu.is_open(), "programmatic open refuses another system pause")
	await close_menu()
	check(get_tree().paused, "rejected menu preserves external pause")
	get_tree().paused = false
	for skill_id: String in ["ultimate_wind_1", "ultimate_fire_1", "ultimate_fire_2", "ultimate_ice_1", "ultimate_ice_2", "ultimate_lightning_1", "ultimate_lightning_2", "ultimate_wind_2"]:
		GameManager.unlocked_skills.append(skill_id)
		GameManager.selected_ultimate_skill = skill_id
		player.rage = player.MAX_RAGE
		player._ultimate_cooldown_remaining = 0.0
		check(player._start_ultimate_cinematic(skill_id), "cinematic starts " + skill_id)
		var regen_before_cinematic := player._health_regen_elapsed
		for i in 15:
			press("skill_tree")
			await wait_seconds(0.1)
		check(not menu.is_open(), "T spam cannot open during cinematic " + skill_id)
		if not pause_only:
			check(is_equal_approx(player._health_regen_elapsed, regen_before_cinematic), "cinematic freezes regeneration " + skill_id)
		await wait_seconds(1.0)
		await close_menu()
		check(not get_tree().paused and not player._ultimate_cinematic_running, "cinematic and menu release pause " + skill_id)
		check(player.rage == 0.0 and player._ultimate_cooldown_remaining > 0.0, "ultimate executes once " + skill_id)
		get_tree().paused = false
		await wait_seconds(player.WIND_ULTIMATE_DURATION if skill_id == "ultimate_wind_2" else 0.5)
		check(not player._wind_ultimate_active, "ultimate gameplay finishes " + skill_id)
		press("skill_tree")
		await wait_seconds(1.0)
		check(menu.is_open() and get_tree().paused, "T usable after ultimate " + skill_id)
		await close_menu()
		check(not get_tree().paused, "subsequent close resumes " + skill_id)
	player.rage = player.MAX_RAGE
	player._ultimate_cooldown_remaining = 0.0
	check(player._start_ultimate_cinematic("ultimate_wind_1"), "abort case starts")
	press("skill_tree")
	await wait_seconds(0.1)
	for child in get_children():
		if child.get_script() == player.ULTIMATE_CINEMATIC_SCRIPT:
			child.queue_free()
	await wait_seconds(0.2)
	check(not get_tree().paused and not player._ultimate_cinematic_running and not menu.is_open(), "cinematic teardown releases pause without stranded menu")
	press("skill_tree")
	await wait_seconds(1.0)
	check(not player._start_ultimate_cinematic("ultimate_wind_1"), "cinematic refuses existing book pause")
	await close_menu()
	press("skill_tree")
	await wait_seconds(0.1)
	menu.queue_free()
	await wait_seconds(0.2)
	check(not get_tree().paused, "book teardown during opening restores pause")
	GameManager.skill_allocations.clear()
	print("MENU_CHECK pause_only=", pause_only, " checks=", checks, " failures=", failures)
	get_tree().paused = false
	get_tree().quit(0 if failures == 0 else 1)
