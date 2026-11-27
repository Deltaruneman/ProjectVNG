extends Node
## Run only in a disposable project using an ArcanaEXP custom user directory.
var checks := 0
var failures := 0
var level_events: Array[int] = []

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
	print("PASS " if ok else "FAIL ", label)

func ticks(count: int = 3) -> void:
	for index in count:
		await get_tree().physics_frame
		await get_tree().process_frame

func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("user://exp-%s.png" % label)

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	event = InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = false
	Input.parse_input_event(event)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not "ArcanaEXP" in OS.get_user_data_dir():
		push_error("Refusing progression test outside isolated user directory")
		get_tree().quit(2)
		return
	print("ISOLATED_USER_DATA ", OS.get_user_data_dir())
	if OS.get_cmdline_user_args().has("--stage-flow"):
		await _stage_flow()
		return
	SaveSystem.save_path = "user://exp-fixture.json"
	GameManager.reset()
	GameManager.level_gained.connect(func(level: int) -> void: level_events.append(level))
	check(GameManager.player_level == 1 and GameManager.exp_to_next_level() == 100, "new game starts at level 1 with 100 EXP threshold")
	check(not GameManager.award_experience(0) and not GameManager.award_experience(-20), "nonpositive EXP rejected")
	for index in 4:
		GameManager.award_exp_point("mob:%d" % index)
	check(GameManager.experience == 80 and GameManager.exp_points == 0, "four normal rewards produce 80 EXP and no SP")
	GameManager.award_exp_point("mob:4")
	check(GameManager.player_level == 2 and GameManager.experience == 0 and GameManager.exp_points == 3, "fifth normal reward grants level 2 and exactly 3 SP")
	check(not GameManager.award_exp_point("mob:4") and GameManager.experience == 0, "repeated unique reward rejected")
	GameManager.award_experience(370, "large")
	check(GameManager.player_level == 4 and GameManager.experience == 20 and GameManager.exp_points == 9, "multi-level award retains overflow and grants 3 SP per level")
	check(level_events == [2, 3, 4], "one ordered signal per earned level")
	check(GameManager.exp_to_next_level() == 250, "threshold rises by 50 each level")
	check(not GameManager.spend_exp_point("unknown") and not GameManager.spend_exp_point("active_fire_4"), "unknown and wrong-form purchases rejected")
	check(GameManager.spend_exp_point("form_fire", "fire"), "element selection costs 1 SP")
	check(not GameManager.spend_exp_point("form_ice", "ice"), "cannot buy second form")
	check(GameManager.spend_exp_point("active_fire_1") and GameManager.exp_points == 7, "first active costs 1 SP")
	check(not GameManager.spend_exp_point("active_fire_1"), "active skill cannot be purchased twice")
	check(not GameManager.spend_exp_point("evo_fire_meteor"), "evolution prerequisite enforced")
	check(GameManager.spend_exp_point("active_fire_4") and GameManager.exp_points == 3, "advanced active costs 4 SP")
	check(not GameManager.spend_exp_point("ultimate_fire_1"), "insufficient SP rejected despite reached milestone")
	check(GameManager.spend_exp_point("char_attack") and GameManager.exp_point_cost("char_attack") == 2, "second character rank quotes 2 SP")
	check(GameManager.spend_exp_point("char_attack") and GameManager.exp_points == 0 and GameManager.exp_point_cost("char_attack") == 3, "second character rank charges 2 SP and third quotes 3")
	check(GameManager.exp_point_cost("ultimate_fire_1") == 4 and GameManager.exp_point_cost("ultimate_fire_2") == 5 and GameManager.exp_point_cost("evo_fire_meteor") == 4, "ultimate and late evolution quote their higher costs")
	check(GameManager.allocated_exp_points() == 9 and GameManager.total_exp_points() == 9, "weighted spending total remains exact")
	GameManager.save_game()
	GameManager.reset()
	GameManager.load_game()
	check(GameManager.player_level == 4 and GameManager.experience == 20 and GameManager.exp_points == 0 and GameManager.allocated_exp_points() == 9, "new save round trip retains level EXP and weighted purchases")
	GameManager.reset_skill_tree()
	check(GameManager.exp_points == 9 and GameManager.skill_spending.is_empty() and GameManager.skill_allocations.is_empty(), "reset refunds exact weighted cost")
	GameManager.reset_skill_tree()
	check(GameManager.exp_points == 9 and GameManager.player_level == 4 and GameManager.experience == 20, "repeat reset creates no SP and preserves EXP")
	GameManager.spend_exp_point("char_attack")
	GameManager.spend_exp_point("char_attack")
	GameManager.spend_exp_point("char_attack")
	check(not GameManager.spend_exp_point("char_attack") and GameManager.exp_points == 3, "maximum character rank enforced")
	SaveSystem.save_data({"exp_points": 2, "skill_allocations": {"char_attack": 2, "form_ice": 1, "active_ice_1": 1}, "weapon_form": "ice", "unlocked_skills": ["active_ice_1"], "collected_exp_points": ["old:0"], "flags": {"sentinel": true}, "other": {"keep": 123}})
	GameManager.load_game()
	check(GameManager.player_level == 1 and GameManager.experience == 0 and GameManager.exp_points == 2 and GameManager.weapon_form == "ice" and GameManager.unlocked_skills.has("active_ice_1"), "legacy save preserves SP skills and form without retroactive charges")
	check(GameManager.allocated_exp_points() == 4 and not GameManager.award_exp_point("old:0"), "legacy purchase basis and collected IDs retained")
	GameManager.spend_exp_point("char_health")
	GameManager.save_game()
	GameManager.load_game()
	GameManager.reset_skill_tree()
	check(GameManager.exp_points == 6, "mixed legacy and new purchases refund exact amount after reload")
	check(SaveSystem.load_data().get("other", {}).get("keep") == 123 and GameManager.flags.get("sentinel"), "unknown payload and world flags survive progression saves")
	GameManager.reset()
	GameManager.save_game()
	var stage := Node3D.new()
	add_child(stage)
	var camera := Camera3D.new()
	stage.add_child(camera)
	camera.position = Vector3(0, 6, 10)
	camera.look_at(Vector3(0, 0.8, 0))
	camera.make_current()
	var light := DirectionalLight3D.new()
	stage.add_child(light)
	light.rotation_degrees = Vector3(-45, -20, 0)
	var floor_mesh := MeshInstance3D.new()
	floor_mesh.mesh = PlaneMesh.new()
	floor_mesh.scale = Vector3(20, 1, 20)
	stage.add_child(floor_mesh)
	var player = load("res://scenes/player/player.tscn").instantiate()
	stage.add_child(player)
	player.set_physics_process(false)
	var hud = load("res://ui/hud.tscn").instantiate()
	stage.add_child(hud)
	await ticks(5)
	check(hud._experience_bar.value == 0 and hud._level_label.text == "LV. 1" and not hud._book_badge.visible, "HUD starts level 1 with empty EXP and no book badge")
	var enemy = load("res://scenes/enemies/crab/crab.tscn").instantiate()
	stage.add_child(enemy)
	enemy.position = Vector3(7, 0, 0)
	enemy.set_physics_process(false)
	enemy.health = 0
	await ticks(2)
	var pickups := get_tree().get_nodes_in_group("exp_point_pickups")
	check(pickups.size() == 1, "unchanged enemy death path spawns an EXP pickup")
	if not pickups.is_empty():
		var pickup = pickups[0]
		pickup.set_physics_process(false)
		var distance: float = pickup.position.distance_to(player.position)
		pickup._physics_process(0.3)
		check(pickup.position.distance_to(player.position) < distance and GameManager.experience == 0, "EXP homes from distance before contact without early award")
		for index in 60:
			if pickup._collected:
				break
			pickup._physics_process(0.05)
		check(pickup._collected and GameManager.experience == 20, "automatic homing awards exactly 20 EXP on arrival")
		pickup._collect(player)
		check(GameManager.experience == 20, "repeat contact cannot double award")
	await ticks(2)
	var dead_pickup = load("res://levels/objects/experience_point/exp_point.tscn").instantiate()
	stage.add_child(dead_pickup)
	dead_pickup.position = Vector3(8, 0, 0)
	dead_pickup.set_physics_process(false)
	player.health = 0
	dead_pickup._physics_process(2.0)
	dead_pickup._collect(player)
	check(not dead_pickup._collected and GameManager.experience == 20 and dead_pickup.position.x == 8.0, "dead Player cannot attract or collect EXP")
	player.health = player.max_health
	dead_pickup.queue_free()
	var unique_pickup = load("res://levels/objects/experience_point/exp_point.tscn").instantiate()
	unique_pickup.pickup_id = "boss-fixture"
	unique_pickup.points = 5
	stage.add_child(unique_pickup)
	unique_pickup._collect(player)
	check(GameManager.player_level == 2 and GameManager.experience == 20 and GameManager.exp_points == 3, "five-unit boss pickup converts to 100 EXP with overflow")
	await ticks(3)
	check(hud._book_badge.visible and hud._book_badge.text == "3" and hud._level_label.text == "LV. 2" and hud._experience_bar.value == 20, "level EXP and red SP badge refresh after pickup")
	check(hud._level_notice.text.contains("+3 SP") and hud._level_notice.modulate.a > 0.0, "level-up notice shows +3 SP")
	var duplicate = load("res://levels/objects/experience_point/exp_point.tscn").instantiate()
	duplicate.pickup_id = "boss-fixture"
	duplicate.points = 5
	stage.add_child(duplicate)
	check(duplicate.is_queued_for_deletion(), "unique boss drop stays consumed")
	await capture("level-up")
	for viewport_size in [Vector2i(480, 270), Vector2i(800, 270), Vector2i(360, 360)]:
		get_viewport().size = viewport_size
		await ticks(4)
		var rect: Rect2 = hud._experience_bar.get_global_rect()
		check(absf(rect.size.x - get_viewport().get_visible_rect().size.x) < 1.0 and absf(rect.end.y - get_viewport().get_visible_rect().size.y) < 1.0, "EXP bar spans bottom viewport %s" % viewport_size)
	await capture("square-hud")
	get_viewport().size = Vector2i(800, 270)
	await ticks(4)
	await capture("wide-hud")
	get_viewport().size = Vector2i(480, 270)
	var tree = hud.get_node("SkillTreeLayer/SkillTree")
	key(KEY_T)
	await ticks(90)
	check(get_tree().paused and not hud.get_node("ExperienceHUD").visible, "T opens Skill Tree and hides gameplay EXP HUD")
	check(tree._balance_label.text.contains("3 SP"), "Skill Tree shows actual SP balance")
	GameManager.spend_exp_point("form_fire", "fire")
	GameManager.spend_exp_point("active_fire_1")
	GameManager.spend_exp_point("char_health")
	await ticks(4)
	check(GameManager.exp_points == 0 and not hud._book_badge.visible, "spending all SP removes red badge")
	var cost_nodes: Array = tree._active_graph.get_children()
	var advanced_cost_visible := false
	for node in cost_nodes:
		if node is SkillTreeNode and node.title_text == "Thiên Thạch":
			advanced_cost_visible = node.rank_text == "4 SP" and node.description_text.contains("Tốn 4 SP") and not node.action_available
	check(advanced_cost_visible, "advanced skill UI displays actual 4 SP price and disables purchase")
	await capture("weapon-costs")
	tree._tab = "character"
	tree._refresh()
	await ticks(4)
	await capture("character-costs")
	key(KEY_ESCAPE)
	await ticks(90)
	check(not get_tree().paused and hud.get_node("ExperienceHUD").visible, "Escape restores EXP HUD")
	await capture("spent-hud")
	var saved_level := GameManager.player_level
	stage.queue_free()
	await ticks(3)
	check(GameManager.player_level == saved_level and GameManager.experience == 20, "stage teardown preserves progression in autoload")
	GameManager.reset()
	check(GameManager.player_level == 1 and GameManager.experience == 0 and GameManager.exp_points == 0 and GameManager.skill_spending.is_empty(), "new-game memory reset clears progression")
	print("EXP_RESULT ", checks, " checks, ", failures, " failures")
	get_tree().quit(1 if failures else 0)


func _isolate_exp_stage(stage: Stage) -> void:
	stage.player.invincible = true
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if stage.is_ancestor_of(enemy):
			enemy.set_physics_process(false)
	for timer in stage.find_children("*", "Timer", true, false):
		if timer.get_parent() is EnemyZone:
			timer.stop()


func _check_stage_progress(label: String) -> void:
	var saved := SaveSystem.load_data()
	check(GameManager.player_level == 3 and GameManager.experience == 45 and GameManager.exp_points == 6, "in-memory level/EXP/SP " + label)
	check(int(saved.get("player_level", -1)) == 3 and int(saved.get("experience", -1)) == 45 and int(saved.get("exp_points", -1)) == 6, "saved level/EXP/SP " + label)
	check(saved.get("sentinel", {}).get("keep") == 123 and GameManager.collected_exp_points.has("stage-exp:0"), "payload and collected EXP IDs " + label)


func _stage_flow() -> void:
	SaveSystem.save_path = "user://exp-stage-fixture.json"
	SaveSystem.save_data({"stage": GameManager.FIRST_STAGE, "checkpoint": "b2_start", "flags": {"b2_cleared": true}, "player_level": 3, "experience": 45, "exp_points": 6, "skill_allocations": {"char_attack": 1}, "skill_spending": {"char_attack": 1}, "collected_exp_points": ["stage-exp:0"], "sentinel": {"keep": 123}})
	GameManager.reset()
	GameManager.load_game()
	get_tree().current_scene = null
	GameManager.stage_changed.connect(_isolate_exp_stage)
	GameManager.change_stage(GameManager.FIRST_STAGE, "b2_start", false)
	await get_tree().scene_changed
	await ticks(5)
	check(GameManager.current_stage.scene_file_path == GameManager.FIRST_STAGE, "actual basement B2 launch")
	_check_stage_progress("B2 launch")
	GameManager.change_stage(GameManager.B3_STAGE, "b3_down", false)
	await get_tree().scene_changed
	await ticks(5)
	check(GameManager.current_stage.scene_file_path == GameManager.B3_STAGE, "actual B2 to B3 transition")
	_check_stage_progress("B3 arrival")
	check(GameManager.activate_basement_checkpoint(GameManager.B3_STAGE, "b3_start") == "accepted", "actual B3 checkpoint saves progression")
	_check_stage_progress("B3 checkpoint")
	GameManager.current_stage.player.die()
	await get_tree().scene_changed
	await ticks(5)
	check(GameManager.current_stage.scene_file_path == GameManager.B3_STAGE and GameManager.current_stage.player.health == GameManager.current_stage.player.max_health, "actual Player death respawns in B3")
	_check_stage_progress("B3 death recovery")
	GameManager.change_stage(GameManager.FIRST_STAGE, "b2_up", false)
	await get_tree().scene_changed
	await ticks(5)
	check(GameManager.current_stage.scene_file_path == GameManager.FIRST_STAGE, "actual B3 return to B2")
	GameManager.save_game()
	GameManager.load_game()
	_check_stage_progress("B2 return and reload")
	print("EXP_STAGE_RESULT ", checks, " checks, ", failures, " failures")
	get_tree().quit(1 if failures else 0)
