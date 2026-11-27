extends Node3D
var failures := 0
var checks := 0
func check(ok: bool, label: String):
	checks += 1
	print("PASS " if ok else "FAIL ", label)
	if not ok: failures += 1
func frames(n: int):
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
func press_f():
	var event := InputEventAction.new()
	event.action = "interact"
	event.pressed = true
	Input.parse_input_event(event)
	await frames(1)
	event = InputEventAction.new()
	event.action = "interact"
	Input.parse_input_event(event)
	await frames(1)
func open_stage(scene: String) -> Stage:
	var old := GameManager.current_stage
	if is_instance_valid(old):
		old.queue_free()
		await frames(3)
	var stage := load("res://levels/level_1/"+scene+".tscn").instantiate() as Stage
	get_tree().root.add_child(stage)
	get_tree().current_scene = stage
	await frames(15)
	stage.player.invincible = true
	for zone in stage.find_children("*", "EnemyZone", true, false):
		zone.get_node("Timer").stop()
	return stage
func _ready():
	if not "ArcanaWorldInteractions-20261126" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	_run.call_deferred()
func _run():
	GameManager.reset()
	SaveSystem.save_path = "user://fixture.json"
	GameManager.flags["story_possession"] = true
	GameManager.flags["story_dark_fairy_intro"] = true
	var stage := await open_stage("castle")
	for path in ["F1/Transitions/Checkpoint_castle", "F2/Transitions/Checkpoint_f2"]:
		var cp = stage.get_node(path)
		stage.player.global_position = cp.global_position
		stage.player.velocity = Vector3.ZERO
		await frames(15)
		check(GameManager.checkpoint_id == cp.id, "contact activates " + cp.id)
		check(cp._prompt.visible and cp._sprite.billboard == BaseMaterial3D.BILLBOARD_ENABLED, "checkpoint visible with F prompt")
		await press_f()
		check(cp._feedback.visible and cp._feedback.text == "Đã lưu checkpoint", "F confirms checkpoint save")
		var saved := SaveSystem.load_data()
		check(saved.get("checkpoint") == cp.id and saved.get("stage") == stage.scene_file_path, "checkpoint reaches isolated save on disk")
		GameManager.checkpoint_id = ""
		GameManager.load_game()
		check(GameManager.checkpoint_id == cp.id, "loading saved data restores checkpoint ID")
		var spawn: Vector3 = cp.get_node("Spawn").global_position
		var checkpoint_id: String = cp.id
		get_viewport().get_texture().get_image().save_png("user://"+checkpoint_id+".png")
		GameManager.respawn()
		await frames(100)
		stage = GameManager.current_stage
		stage.player.invincible = true
		check(stage.scene_file_path.ends_with("castle.tscn") and stage.player.global_position.distance_to(spawn)<0.5 and stage.player.is_on_floor(), "respawn lands on correct floor: "+checkpoint_id)
		check(GameManager.checkpoint_id == checkpoint_id, "respawn preserves checkpoint ID")
	await check_pacing(stage, 1.0, 1.0)
	stage.player.global_position = Vector3(7, 1.1, 46)
	stage.player.velocity = Vector3.ZERO
	stage.camera_rig.snap_to_target()
	await frames(20)
	var stairs = stage.get_node("F1/Stairs/AutoClimb")
	check(stairs._prompt.visible, "authored Castle stair entrance displays F")
	await press_f()
	check(stage.player.is_climbing_stairs(), "F starts automatic ascent")
	var peak_lag := 0.0
	for i in 360:
		await frames(1)
		peak_lag = maxf(peak_lag, absf(stage.camera_rig.global_position.y-stage.player.global_position.y-stage.camera_rig.focus_offset.y))
		if not stage.player.is_climbing_stairs(): break
	await frames(15)
	print("AUTO_STAIRS final=",stage.player.global_position," grounded=",stage.player.is_on_floor()," lag=",peak_lag)
	check(stage.player.global_position.distance_to(Vector3(7,9,26.5))<0.6 and stage.player.is_on_floor(), "automatic ascent reaches actual Castle upper landing")
	check(not stage.player.is_climbing_stairs() and stage.player.can_interact(), "landing restores control")
	check(peak_lag < 0.5 and stage.current_level()==1, "camera follows slope and upper floor becomes visible")
	get_viewport().get_texture().get_image().save_png("user://castle-stairs.png")
	stage.player.global_position = Vector3(7,1.1,46)
	stage.player.velocity = Vector3.ZERO
	await frames(20)
	await press_f()
	Input.action_press("left")
	await frames(2)
	Input.action_release("left")
	check(not stage.player.is_climbing_stairs(), "movement key interrupts stair assist")
	stage.player.global_position = Vector3(7,1.1,46)
	stage.player.velocity = Vector3.ZERO
	await frames(20)
	await press_f()
	await press_f()
	check(not stage.player.is_climbing_stairs(), "F can cancel automatic ascent")
	var blocker := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(5,3,0.5)
	shape.shape = box
	blocker.add_child(shape)
	stage.add_child(blocker)
	blocker.position = Vector3(7,2,44.5)
	await frames(3)
	await press_f()
	await frames(140)
	check(not stage.player.is_climbing_stairs() and stage.player.global_position.z>44.5 and stage.player.is_on_floor(), "obstruction stops assist without passing through collision")
	blocker.queue_free()
	stage = await open_stage("basement_full")
	await check_pacing(stage, 1.5, 0.65)
	stage.player.global_position = Vector3(17,1.1,1.5)
	stage.player.velocity = Vector3.ZERO
	stage.camera_rig.snap_to_target()
	await frames(20)
	var ladder = stage.get_node("B1/LadderSpot_B1_B2/AutoClimb")
	check(ladder._prompt.visible, "B1 ladder shows F prompt at its foot")
	await press_f()
	check(stage.player.is_climbing_ladder(), "F starts B1 ladder climb")
	var ladder_peak_lag := 0.0
	var ladder_facing_samples := 0
	var ladder_facing_correct := true
	for i in 400:
		await frames(1)
		if stage.player.is_climbing_ladder() and stage.player.global_position.y>2.0 and stage.player.global_position.y<10.0:
			ladder_facing_samples += 1
			ladder_facing_correct = ladder_facing_correct and stage.player.forward().dot(Vector3.FORWARD)>0.999
		ladder_peak_lag = maxf(ladder_peak_lag,absf(stage.camera_rig.global_position.y-stage.player.global_position.y-stage.camera_rig.focus_offset.y))
		if not stage.player.is_climbing_stairs(): break
	await frames(20)
	print("B1_LADDER final=",stage.player.global_position," floor=",stage.player.is_on_floor()," level=",stage.current_level()," lag=",ladder_peak_lag)
	check(stage.player.global_position.distance_to(Vector3(19,11.01,1))<0.5 and stage.player.is_on_floor(), "B1 ladder reaches supported B2 landing")
	check(not stage.player.is_climbing_stairs() and stage.player.can_interact(), "B1 ladder restores controls on landing")
	check(stage.current_level()==1 and stage.get_node("B2").visible and ladder_peak_lag<0.5, "B1 ladder camera and floor visibility follow ascent")
	check(ladder_facing_samples>20 and ladder_facing_correct,"Foxy faces into B1 ladder throughout vertical climb")
	get_viewport().get_texture().get_image().save_png("user://b1-ladder-landing.png")
	stage = await open_stage("basement_b3")
	check(not stage.has_node("B3/World/Ceiling"), "B3 ceiling completely removed")
	check(stage.has_node("B3/World/WallUpper"), "B3 retains second wall course")
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if stage.is_ancestor_of(enemy) and "attack_cooldown" in enemy:
			check(is_equal_approx(enemy.attack_cooldown,1.95), "B3 Dark Fairy receives longer recovery")
	get_viewport().get_texture().get_image().save_png("user://b3-open.png")
	stage = await open_stage("garden")
	var farm = stage.get_node("Farm")
	for index in [0,5,31]:
		var plot: Node3D = farm.plots[index]
		stage.player.global_position = plot.global_position + Vector3(0,0.15,0)
		stage.player.velocity = Vector3.ZERO
		await frames(10)
		check(farm.hint is Label3D and farm.hint.global_position.distance_to(plot.global_position+Vector3.UP*2.6)<0.01 and farm.hint.text=="F: Chọn hạt và trồng", "plant prompt anchors above plot "+str(index))
		await press_f()
		check(farm.opened and farm.target_plot==plot and farm.hint.text.is_empty(), "F opens selected plot and hides world hint")
		farm._back()
		await frames(2)
	var last_plot: Node3D = farm.plots[31]
	farm.data.seeds["broccoli"] = 1
	await press_f()
	farm._choose(0)
	await frames(3)
	check(farm.hint.text.begins_with("Đang lớn:") and not farm.opened, "growing timer appears above planted soil")
	farm.data.plots[farm._plot_key(last_plot)]["planted_at"] = Time.get_unix_time_from_system()-100
	await frames(3)
	check(farm.hint.text=="F: Thu hoạch", "ready crop displays harvest hint above soil")
	await press_f()
	check(int(farm.data.produce.get("broccoli",0))==1 and farm.hint.text=="F: Chọn hạt và trồng", "F harvest works and plot prompt resets")
	get_viewport().get_texture().get_image().save_png("user://garden-plot.png")
	print("WORLD_INTERACTIONS_RESULT checks=",checks," failures=",failures)
	get_tree().quit(1 if failures else 0)
func check_pacing(stage: Stage, interval: float, speed: float):
	for scene in ["skeleton/skeleton_mage", "arcane/evil_wizard_1"]:
		var packed := load("res://scenes/enemies/"+scene+".tscn") as PackedScene
		var enemy = packed.instantiate()
		var original: float = enemy.attack_cooldown
		stage.add_child(enemy)
		enemy.global_position = stage.player.global_position + Vector3(0,0,5)
		enemy.set_physics_process(false)
		check(is_equal_approx(enemy.attack_cooldown,original*interval), stage.scene_file_path.get_file()+" "+scene+" recovery")
		enemy.state = &"attack"
		enemy.attack_target = enemy.global_position + Vector3(0,0,-10)
		enemy.attack()
		var bullet: RigidBody3D
		for child in stage.get_children():
			if child is RigidBody3D: bullet = child
		check(bullet!=null and is_equal_approx(bullet.linear_velocity.length(),7.0*speed), stage.scene_file_path.get_file()+" "+scene+" actual fired bullet speed")
		if bullet != null: bullet.queue_free()
		enemy.queue_free()
		await frames(2)
