extends Node3D
var checks := 0
var failures := 0
var stage: Node3D
var player: Player
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int = 3) -> void:
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame
		if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw
func capture(label: String) -> void:
	if DisplayServer.get_name() != "headless": get_viewport().get_texture().get_image().save_png("user://door-"+label+".png")
func tap_f() -> void:
	for pressed in [true,false]:
		var e := InputEventKey.new()
		e.physical_keycode = KEY_F
		e.keycode = KEY_F
		e.pressed = pressed
		Input.parse_input_event(e)
		await frames(2)
func walk(action: String,n: int = 15) -> void:
	Input.action_press(action)
	await frames(n)
	Input.action_release(action)
	await frames(3)
func place(at: Vector3) -> void:
	player.stop_automatic_stairs()
	player.global_position = at
	player.velocity = Vector3.ZERO
	stage.get_node("CameraRig").snap_to_target()
	await frames(12)
func door_overlap(door: Node3D,at: Vector3) -> bool:
	var capsule: CollisionShape3D = player.get_node("CollisionShape3D")
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule.shape
	query.transform = Transform3D(player.global_basis,at) * capsule.transform
	query.collision_mask = 1
	query.exclude = [player.get_rid()]
	for hit: Dictionary in player.get_world_3d().direct_space_state.intersect_shape(query,16):
		if hit.collider == door.get_node("StaticBody3D"): return true
	return false
func load_stage(path: String) -> void:
	if is_instance_valid(stage):
		stage.queue_free()
		await frames()
	GameManager.reset()
	GameManager.flags["story_possession"] = true
	GameManager.flags["b2_cleared"] = true
	stage = load(path).instantiate()
	get_tree().root.add_child(stage)
	get_tree().current_scene = stage
	player = stage.get_node("Player")
	player.invincible = true
	await frames(20)
func _ready() -> void:
	if not "ArcanaDoorClearance-20261128" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	run.call_deferred()
func run() -> void:
	SaveSystem.save_path = "user://door-clearance-fixture.json"
	await load_stage("res://levels/level_1/basement_b3.tscn")
	var door: Node3D = stage.get_node("B3/Door_b3_down")
	for x: float in [-1.9,0.0,1.9]:
		var at := door.to_global(Vector3(x,0.05,1.15))
		check(not door_overlap(door,at),"B3 visible front apron clear at x="+str(x))
		await place(at)
		var before := player.global_position
		await walk("down",15)
		check(player.global_position.z > before.z+1.0,"actual down input leaves front/side of door x="+str(x))
		if is_zero_approx(x): await capture("center-clear")
		print("APRON_MOVE x=",x," start=",before," end=",player.global_position," floor=",player.is_on_floor())
	await capture("b3-apron")
	if OS.get_cmdline_user_args().has("--before"):
		print("DOOR_BEFORE_RESULT ",checks-failures,"/",checks)
		get_tree().quit(1 if failures else 0)
		return
	for path: String in ["res://levels/level_1/basement_full.tscn","res://levels/level_1/garden.tscn","res://levels/level_1/castle.tscn","res://levels/level_1/basement_b3.tscn"]:
		await load_stage(path)
		var doors: Array[Node] = []
		for candidate: Node in get_tree().get_nodes_in_group("spawn_points"):
			if stage.is_ancestor_of(candidate) and candidate.scene_file_path.ends_with("door.tscn"): doors.append(candidate)
		for candidate: Node3D in doors:
			for x: float in [-1.9,0.0,1.9]:
				check(not door_overlap(candidate,candidate.to_global(Vector3(x,0.05,1.15))),candidate.id+" clear visible apron "+str(x))
			var ray := PhysicsRayQueryParameters3D.create(candidate.to_global(Vector3(0,1.5,0.4)),candidate.to_global(Vector3(0,1.5,-0.4)),1)
			ray.exclude = [player.get_rid()]
			var hit := player.get_world_3d().direct_space_state.intersect_ray(ray)
			print("DOOR_SOLID_SAMPLE ",candidate.id," collider=",hit.get("collider")," point=",candidate.to_local(hit.position) if not hit.is_empty() else Vector3.INF)
			check(not hit.is_empty() and hit.collider == candidate.get_node("StaticBody3D") and absf(candidate.to_local(hit.position).z-0.25)<0.05,candidate.id+" solid collision aligned with visible door plane")
			check(stage.place_player_at(candidate.id),candidate.id+" arrival ID resolves")
			await frames(20)
			check(player.is_on_floor(),candidate.id+" arrival remains supported")
			var origin := player.global_position
			await walk("up",20)
			check(player.is_on_floor() and player.global_position.distance_to(origin) > 0.1,candidate.id+" can approach from spawn")
			origin = player.global_position
			await walk("down",15)
			check(player.global_position.z > origin.z+1,candidate.id+" can back away after contact")
	await load_stage("res://levels/level_1/basement_b3.tscn")
	door = stage.get_node("B3/Door_b3_down")
	await place(door.to_global(Vector3(-3.2,0.05,0.3)))
	await walk("right",30)
	var side_origin := player.global_position
	await walk("down",20)
	check(player.global_position.z > side_origin.z+1,"wall-side approach can escape toward room")
	await capture("side-escape")
	var locked_exit: Node3D = stage.get_node("B3/Door_b3_exit")
	check(locked_exit.is_locked(),"B3 exit lock remains active before boss clear")
	await place(locked_exit.to_global(Vector3(0,0.05,1.2)))
	await tap_f()
	await frames(8)
	check(get_tree().current_scene == stage and not GameManager.is_changing(),"locked F cannot bypass stage progression")
	if Dialogic.current_timeline != null: Dialogic.end_timeline(true)
	await frames(10)
	check(not player.is_talking,"locked-door conversation releases player controls")
	check(stage.place_player_at("b3_down"),"B3 round-trip starts at safe spawn")
	await walk("up",18)
	check(door.get_node("InteractiveArea3D").get_overlapping_bodies().has(player),"F area reachable in front of aligned door")
	await tap_f()
	await frames(90)
	stage = get_tree().current_scene
	player = stage.get_node("Player")
	check(stage.scene_file_path.ends_with("basement_full.tscn"),"real F travels B3 -> B2")
	check(player.is_on_floor(),"real B2 transition arrival supported")
	await walk("up",18)
	await tap_f()
	await frames(90)
	stage = get_tree().current_scene
	player = stage.get_node("Player")
	check(stage.scene_file_path.ends_with("basement_b3.tscn"),"real F travels B2 -> B3")
	check(player.is_on_floor(),"real B3 transition arrival supported")
	var origin := player.global_position
	await walk("left",18)
	check(player.global_position.x < origin.x-1,"can move sideways after actual arrival")
	await capture("roundtrip")
	print("DOOR_RESULT ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
