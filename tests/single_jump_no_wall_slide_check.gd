extends Node3D
var checks := 0
var failures := 0
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
func tap_jump() -> void:
	for pressed in [true,false]:
		var e := InputEventKey.new()
		e.keycode = KEY_SPACE
		e.physical_keycode = KEY_SPACE
		e.pressed = pressed
		Input.parse_input_event(e)
		await frames(2)
func body_box(at: Vector3, dimensions: Vector3) -> void:
	var body := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = dimensions
	collider.shape = shape
	body.add_child(collider)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = dimensions
	mesh.mesh = box
	body.add_child(mesh)
	body.position = at
	add_child(body)
func capture(label: String) -> void:
	if DisplayServer.get_name() != "headless": get_viewport().get_texture().get_image().save_png("user://movement-"+label+".png")
func _ready() -> void:
	if not "ArcanaFloorVisibility-20261127" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	run.call_deferred()
func run() -> void:
	SaveSystem.save_path = "user://single-jump-fixture.json"
	GameManager.reset()
	GameManager.skill_allocations["char_double_jump"] = 1
	body_box(Vector3(0,-0.1,0),Vector3(60,0.2,60))
	body_box(Vector3(4,4,0),Vector3(0.5,8,12))
	player = load("res://scenes/player/player.tscn").instantiate()
	player.position = Vector3(0,0.1,0)
	add_child(player)
	var camera: CameraRig = load("res://scenes/camera/camera_rig.tscn").instantiate()
	camera.target = player
	add_child(camera)
	await frames(20)
	check(player.maxjump == 1,"legacy rank cannot restore multiple jumps")
	check(not player.fsm.states.has("wall_slide"),"Wall_slide state absent from real Player FSM")
	check(player.is_on_floor(),"actual Player starts grounded")
	await tap_jump()
	check(player.velocity.y > 0 and player.global_position.y > 0.1,"Space starts ordinary ground jump")
	var peak := player.global_position.y
	for i in 90:
		await frames()
		peak = maxf(peak,player.global_position.y)
		if player.velocity.y < -0.5: break
	check(not player.is_on_floor() and player.velocity.y < -0.5,"Player reaches falling phase")
	var no_impulse := true
	for i in 4:
		var before := player.velocity.y
		await tap_jump()
		no_impulse = no_impulse and player.velocity.y <= before + 0.05 and player.curjump <= 1
	check(no_impulse,"four falling Space presses cannot create second jump impulse")
	await capture("falling-no-second-jump")
	await frames(90)
	check(player.is_on_floor(),"Player lands normally")
	await tap_jump()
	check(player.velocity.y > 0,"landing restores one ground jump")
	await frames(100)
	player.global_position = Vector3(2.8,6,0)
	player.velocity = Vector3.ZERO
	Input.action_press("right")
	await frames(15)
	var touched_wall := false
	var no_wall_impulse := true
	for i in 4:
		touched_wall = touched_wall or player.is_on_wall()
		var before := player.velocity.y
		await tap_jump()
		no_wall_impulse = no_wall_impulse and player.velocity.y <= before + 0.05
	check(touched_wall,"actual airborne Player contacts solid wall while holding movement")
	check(player.velocity.y < -3.0,"wall contact retains ordinary gravity, no slide speed clamp")
	check(no_wall_impulse,"Space during wall contact cannot wall-jump or reset air jump")
	check(player.fsm.current_state != null and player.fsm.current_state.name != "Wall_slide","wall contact stays outside removed state")
	await capture("wall-fall")
	Input.action_release("right")
	await frames(100)
	var progression := load("res://scripts/skill_progression.gd")
	check(progression.definition("char_double_jump").is_empty(),"retired upgrade has no purchase definition")
	GameManager.skill_points = 50
	check(not GameManager.can_purchase_skill("char_double_jump"),"retired upgrade cannot consume SP")
	var node_present := false
	for data: Dictionary in load("res://ui/skill_tree_layout.gd").CHARACTER_NODES:
		node_present = node_present or data.id == "char_double_jump"
	check(not node_present,"skill tree no longer advertises aerial jump")
	SaveSystem.save_data({"skill_points":7,"skill_allocations":{"char_double_jump":1,"char_health":1},"skill_spending":{"char_double_jump":3,"char_health":1},"flags":{"unrelated_gate":true},"sentinel":{"preserve":"yes"}})
	GameManager.load_game()
	check(GameManager.skill_points == 10 and not GameManager.skill_allocations.has("char_double_jump") and not GameManager.skill_spending.has("char_double_jump"),"load refunds exactly3 recorded SP and retires old allocation")
	check(GameManager.skill_allocations.get("char_health") == 1 and GameManager.flags.get("unrelated_gate") == true,"other allocation and gate flag preserved")
	GameManager.save_game()
	var saved := SaveSystem.load_data()
	check(saved.get("sentinel",{}).get("preserve") == "yes","unknown save payload survives migration")
	GameManager.load_game()
	check(GameManager.skill_points == 10,"save/load cannot duplicate the refund")
	SaveSystem.save_data({"skill_points":2,"skill_allocations":{"char_double_jump":1}})
	GameManager.load_game()
	check(GameManager.skill_points == 3,"old one-SP-per-rank save refunds its original basis")
	print("MOVEMENT_RESULT ",checks-failures,"/",checks," PEAK ",peak)
	get_tree().quit(1 if failures else 0)
