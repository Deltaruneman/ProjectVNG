extends Node3D
var checks := 0
var failures := 0
var stage: Node3D
var player: Player
var lower: Node3D
var upper: Node3D
var upper_y := 0.0
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int = 3) -> void:
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame
		if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw
func capture(label: String) -> void:
	if DisplayServer.get_name() != "headless": get_viewport().get_texture().get_image().save_png("user://floor-"+label+".png")
func tap(code: Key) -> void:
	for pressed in [true,false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		Input.parse_input_event(event)
		await frames(2)
func place(at: Vector3) -> void:
	player.stop_automatic_stairs()
	player.global_position = at
	player.velocity = Vector3.ZERO
	stage.get_node("CameraRig").snap_to_target()
	await frames(20)
func only_floor(level: int, label: String) -> void:
	check(lower.visible == (level == 0) and upper.visible == (level == 1),label)
func _ready() -> void:
	if not "ArcanaFloorVisibility-20261127" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	run.call_deferred()
func run() -> void:
	SaveSystem.save_path = "user://floor-fixture.json"
	GameManager.reset()
	GameManager.flags["story_possession"] = true
	stage = load("res://levels/level_1/basement_full.tscn").instantiate()
	add_child(stage)
	player = stage.get_node("Player")
	player.invincible = true
	lower = stage.get_node("B1")
	upper = stage.get_node("B2")
	upper_y = upper.global_position.y + 6.0 # Authored Floor cells y3 * 2; brick surface is at the cell origin.
	print("AUTHORED_FLOORS lower=0 upper=",upper_y)
	await frames(20)
	await place(Vector3(14,1.2,14))
	only_floor(0,"lower overlap area shows B1 only")
	await capture("lower-overlap")
	await place(Vector3(30,upper_y+0.2,14))
	only_floor(1,"upper floor shows B2 only")
	await capture("upper")
	if OS.get_cmdline_user_args().has("--before"):
		print("FLOOR_BEFORE_RESULT ",checks-failures,"/",checks)
		get_tree().quit(1 if failures else 0)
		return
	check(absf(stage._floor_heights[1]-upper_y) < 0.05,"visibility height follows edited B2 transform")
	check(stage.place_player_at("b1_start"),"B1 checkpoint arrival")
	only_floor(0,"checkpoint selects B1 before physics settles")
	await frames(20)
	var only_lower := true
	await tap(KEY_SPACE)
	for i in 45:
		await frames()
		only_lower = only_lower and lower.visible and not upper.visible
	check(only_lower,"normal B1 jump never reveals overhead B2")
	check(stage.place_player_at("b2_up"),"B2 door arrival")
	only_floor(1,"door immediately selects B2")
	await frames(25)
	check(player.is_on_floor(),"B2 arrival stays supported")
	only_floor(1,"door proximity retains B2 only")
	await capture("door")
	await place(Vector3(17,1.1,2))
	only_floor(0,"ladder entry shows B1 only")
	await tap(KEY_F)
	var started := player.is_climbing_ladder()
	var exactly_one := true
	var premature_upper := false
	var max_y := player.global_position.y
	for i in 180:
		await frames()
		exactly_one = exactly_one and (lower.visible != upper.visible)
		max_y = maxf(max_y,player.global_position.y)
		if player.global_position.y < upper_y - 0.4 and upper.visible: premature_upper = true
	check(started,"real F enters current ladder route")
	check(exactly_one,"180 rendered climb frames always show exactly one normal floor")
	check(not premature_upper,"upper floor never hides player while feet remain below its surface")
	print("LADDER_MAX_Y ",max_y," END ",player.global_position," ACTIVE ",stage.current_level())
	await capture("ladder")
	player.stop_automatic_stairs()
	# Check both sides of the real upper-floor threshold while the climb API owns movement.
	await place(Vector3(17,1.1,2))
	player.set_physics_process(false)
	player._stair_route = PackedVector3Array([Vector3(17,upper_y+1,1)])
	player._ladder_climb = true
	player.global_position = Vector3(17,upper_y-0.5,1)
	stage._active_level = 0
	stage._apply(true)
	only_floor(0,"below actual landing retains lower floor")
	player.global_position.y = upper_y
	stage._apply(true)
	only_floor(1,"reaching actual upper surface switches to B2")
	player.global_position.y = upper_y-0.6
	stage._apply(true)
	only_floor(0,"descending below landing switches back without empty map")
	player.stop_automatic_stairs()
	player.set_physics_process(true)
	await place(Vector3(30,upper_y+0.2,14))
	check(not stage.get_node("B1_5").visible,"lower secret branch cannot appear while upstairs")
	check(not lower.get_node("World/Ceiling").visible and not upper.get_node("World/Ceiling").visible,"ceiling-only image hiding preserved")
	print("FLOOR_RESULT ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
