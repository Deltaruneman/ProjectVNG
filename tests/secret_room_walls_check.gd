extends Node3D
var checks := 0
var failures := 0
var stage: Node3D
var player: Player
var rig: CameraRig
var audit := {}

func check(ok: bool, label: String) -> void:
	checks += 1
	failures += 0 if ok else 1
	print("PASS " if ok else "FAIL ", label)

func frames(count: int = 1) -> void:
	for i in count:
		await get_tree().physics_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw

func ray(from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to, 1)
	query.exclude = [player.get_rid()]
	return stage.get_world_3d().direct_space_state.intersect_ray(query)

func capture(label: String) -> void:
	get_viewport().get_texture().get_image().save_png("user://secret-walls-" + label + ".png")

func release() -> void:
	for action: String in ["up", "down", "left", "right"]:
		Input.action_release(action)

func drive(point: Vector2, count: int = 240) -> Dictionary:
	var lowest := player.global_position.y
	var reached := false
	for i in count:
		var offset := point - Vector2(player.global_position.x, player.global_position.z)
		if offset.length() < 0.24:
			reached = true
			break
		if player.global_position.y < -2.0:
			break
		var local := offset.normalized().rotated(rig.yaw)
		release()
		Input.action_press("right", maxf(local.x,0.0))
		Input.action_press("left", maxf(-local.x,0.0))
		Input.action_press("down", maxf(local.y,0.0))
		Input.action_press("up", maxf(-local.y,0.0))
		await frames()
		lowest = minf(lowest,player.global_position.y)
	release()
	await frames(3)
	return {"reached":reached,"lowest":lowest,"position":str(player.global_position)}

func place(point: Vector3) -> void:
	release()
	player.global_position = point
	player.velocity = Vector3.ZERO
	rig.snap_to_target()

func _ready() -> void:
	if not "ArcanaSecretWalls-20261126" in OS.get_user_data_dir():
		push_error("Use an isolated secret-room test project/user directory")
		get_tree().quit(2)
		return
	_run.call_deferred()

func _run() -> void:
	SaveSystem.save_path = "user://secret-room-fixture.json"
	GameManager.reset()
	GameManager.flags["story_possession"] = true
	GameManager.flags["story_b1_clear"] = true
	stage = load("res://levels/level_1/basement_full.tscn").instantiate()
	add_child(stage)
	player = stage.get_node("Player")
	rig = stage.get_node("CameraRig")
	player.invincible = true
	await frames(10)
	for zone: Node in get_tree().get_nodes_in_group("enemies"):
		zone.set_physics_process(false)
	for timer: Node in stage.find_children("*","Timer",true,false):
		(timer as Timer).stop()
	var map := stage.get_node("B1_5/World") as GridMap
	var items: Array = []
	for id in [0,1,2,3,20,26]:
		var mesh := map.mesh_library.get_item_mesh(id)
		items.append({"id":id,"name":map.mesh_library.get_item_name(id),"shape_entries":map.mesh_library.get_item_shapes(id).size(),"aabb":str(mesh.get_aabb()) if mesh else "none"})
	audit["library_items"] = items
	print("SECRET_LIBRARY ",JSON.stringify(items))
	var supports: Array = []
	var supported := 0
	for x in [38.5,39.5,40.5,41.0,42.0,43.0,45.0,47.0,49.0,51.0,53.0,55.0]:
		var hit := ray(Vector3(x,3.0,13),Vector3(x,-3.0,13))
		if not hit.is_empty(): supported += 1
		supports.append({"x":x,"hit":str(hit.position) if not hit.is_empty() else "NONE","collider":str(hit.collider.get_path()) if not hit.is_empty() else "NONE"})
	audit["floor_rays"] = supports
	print("SECRET_SUPPORT ",JSON.stringify(supports))
	check(supported == supports.size(),"entry and secret-room center line have physical floor support")
	place(Vector3(35,1.2,13))
	await frames(15)
	var blocked := await drive(Vector2(43,13),100)
	check(not blocked.reached and player.global_position.x < 39.0,"closed secret gate blocks real movement")
	var gate = stage.get_node("B1/HiddenGate_B1_5")
	for i in 5:
		gate.get_node("HurtArea3D").take_damage(Vector3.RIGHT,1,player)
		await frames(14)
	check(gate._broken and gate.get_node("B1_5Side").get_used_cells().is_empty(),"existing five-hit gate opens without clearing other walls")
	check(stage.get_node("B1_5").visible and player.global_position.x < 39.0,"secret room is visible through the opened doorway before stepping inside")
	var holes: Array = []
	var samples := 0
	for ix in range(77,116):
		for iz in range(17,36):
			var x := ix * 0.5
			var z := iz * 0.5
			var support := ray(Vector3(x,1.4,z),Vector3(x,0.5,z))
			samples += 1
			if support.is_empty(): holes.append(Vector2(x,z))
	audit["entrance_and_room_samples"] = samples
	audit["floor_holes"] = str(holes)
	check(holes.is_empty(),"continuous floor support across doorway and secret-room floor seams")
	place(Vector3(38,1.2,13))
	await frames(10)
	await capture("opened-entry")
	var opened_supports: Array = []
	for x in [37.5,38.0,38.5,39.0,39.5,40.0,40.5]:
		var hit := ray(Vector3(x,1.5,13),Vector3(x,-3,13))
		opened_supports.append({"x":x,"hit":str(hit.position) if not hit.is_empty() else "NONE"})
	audit["opened_entry_support"] = opened_supports
	print("SECRET_OPENED_SUPPORT ", JSON.stringify(opened_supports))
	place(Vector3(36,1.2,13))
	await frames(12)
	var entered := await drive(Vector2(47,13))
	audit["entry_walk"] = entered
	print("SECRET_ENTRY ",JSON.stringify(entered))
	check(entered.reached and entered.lowest > 0.65 and player.is_on_floor(),"walk through opened gate into secret room without falling")
	if entered.reached:
		var chest := await drive(Vector2(49,15))
		check(chest.reached and chest.lowest > 0.65,"walk to secret chest without falling")
		await capture("inside-room")
		var returned := await drive(Vector2(36,13))
		check(returned.reached and returned.lowest > 0.65,"walk back from secret room without falling")
	await capture("room")
	var lanes: Array = []
	for z in [9.0,11.0,15.0,17.0]:
		place(Vector3(36,1.2,z))
		await frames(8)
		var inward := await drive(Vector2(44,z),150)
		var outward := await drive(Vector2(36,z),150)
		lanes.append({"z":z,"inward":inward,"outward":outward})
		if z == 17.0:
			check(not inward.reached and player.global_position.x < 39.0 and outward.reached and inward.lowest > 0.65,"authored wall at doorway edge remains solid without dropping Player")
		else:
			check(inward.reached and outward.reached and inward.lowest > 0.65 and outward.lowest > 0.65,"walk in/out at doorway z="+str(z)+" without falling")
	audit["doorway_lanes"] = lanes
	place(Vector3(41,1.2,19))
	await frames(40)
	var authored_wall := stage.get_node("B1/World/Wall") as GridMap
	var authored_state: Dictionary = rig._wall_occlusion._grids[authored_wall]
	var authored_fades := 0
	for record: Dictionary in authored_state.records:
		if record.blend > 0.5: authored_fades += 1
	audit["authored_faded_wall_cells"] = authored_fades
	check(authored_state.active and authored_fades > 0,"authored basement wall fades at the secret-room edge while retaining collision")
	await capture("authored-wall-player")
	place(Vector3(35,1.2,21))
	await frames(12)
	var wall_stop := await drive(Vector2(45,21),100)
	check(not wall_stop.reached and player.global_position.x < 39.0,"ordinary authored side wall blocks real movement")
	# Only the wall covering Player fades; the camera never clips it away.
	place(Vector3(24,1.2,13))
	await frames(8)
	# Compare the same idle pose/settled camera through the translucent wall.
	player.set_physics_process(false)
	player.anim_player.pause()
	await frames(30)
	var clear_picture := get_viewport().get_texture().get_image()
	var clear_pixel := clear_picture.get_pixel(clear_picture.get_width()/2,clear_picture.get_height()/2)
	var basis := rig.camera.global_basis
	var offset := rig.camera.global_position-rig.global_position
	var barrier := StaticBody3D.new()
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(6,5,0.4)
	mesh.mesh = box
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.1,0.8,0.2)
	mesh.material_override = material
	barrier.add_child(mesh)
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = box.size
	collider.shape = shape
	barrier.add_child(collider)
	stage.add_child(barrier)
	barrier.global_basis = basis
	barrier.global_position = rig.global_position + rig._boom_direction()*3.0
	await frames(45)
	audit["obstacle_near"] = rig.camera.near
	check(is_equal_approx(rig.camera.near,0.05),"nearby walls keep the normal near plane")
	check(rig.camera.global_basis.is_equal_approx(basis) and (rig.camera.global_position-rig.global_position).is_equal_approx(offset),"opaque wall does not change the fixed camera angle or zoom")
	var picture := get_viewport().get_texture().get_image()
	var pixel := picture.get_pixel(picture.get_width()/2,picture.get_height()/2)
	audit["occlusion_pixel"] = str(pixel)
	var expected_pixel := clear_pixel.lerp(Color(0.1,0.8,0.2),0.22)
	var pixel_error := Vector3(pixel.r-expected_pixel.r,pixel.g-expected_pixel.g,pixel.b-expected_pixel.b).length()
	audit["unobstructed_player_pixel"] = str(clear_pixel)
	audit["faded_wall_alpha"] = mesh.get_active_material(0).albedo_color.a
	audit["pixel_blend_error"] = pixel_error
	check(mesh.get_active_material(0).albedo_color.a < 0.3 and pixel_error < 0.1,"occluding wall fades locally so Player remains visible")
	await capture("faded-wall")
	barrier.queue_free()
	await frames(3)
	# Re-enter the saved-open room after loading its isolated save in a fresh Stage.
	stage.queue_free()
	await frames(4)
	GameManager.reset()
	GameManager.load_game()
	stage = load("res://levels/level_1/basement_full.tscn").instantiate()
	add_child(stage)
	player = stage.get_node("Player")
	rig = stage.get_node("CameraRig")
	player.invincible = true
	await frames(10)
	for enemy: Node in get_tree().get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	for timer: Node in stage.find_children("*","Timer",true,false):
		(timer as Timer).stop()
	place(Vector3(36,1.2,13))
	await frames(10)
	check(stage.get_node("B1/HiddenGate_B1_5")._broken and stage.get_node("B1_5").visible,"saved-open gate reveals the room after Stage replacement")
	var reentry := await drive(Vector2(47,13))
	audit["saved_open_entry"] = reentry
	check(reentry.reached and reentry.lowest > 0.65,"saved-open doorway remains walkable without falling")
	FileAccess.open("user://secret-room-audit.json",FileAccess.WRITE).store_string(JSON.stringify(audit,"\t"))
	print("SECRET_WALLS_RESULT ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
