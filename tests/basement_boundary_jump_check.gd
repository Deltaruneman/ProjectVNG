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
func jump_press() -> void:
	Input.action_press("jump")
	await frames(2)
	Input.action_release("jump")
func _ready() -> void:
	if not "ArcanaFloorVisibility-20261127" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	run.call_deferred()
func run() -> void:
	SaveSystem.save_path = "user://boundary-fixture.json"
	for path: String in ["res://levels/level_1/basement_full.tscn","res://levels/level_1/basement_b3.tscn"]:
		GameManager.reset()
		GameManager.flags["story_possession"] = true
		stage = load(path).instantiate()
		add_child(stage)
		player = stage.get_node("Player")
		player.invincible = true
		await frames(20)
		for branch: String in (["B1","B2"] if path.ends_with("basement_full.tscn") else ["B3"]):
			for side: String in ["west","east","north","south"]:
				await perimeter(branch,side)
		stage.queue_free()
		await frames()
	print("BOUNDARY_RESULT ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
func perimeter(branch: String,side: String) -> void:
	var wall: GridMap = stage.get_node(branch+"/World/Wall")
	var floor_map: GridMap = stage.get_node(branch+"/World/Floor")
	var cells := wall.get_used_cells()
	var x_side := side in ["west","east"]
	var high_side := side in ["east","south"]
	var edge := -2147483647 if high_side else 2147483647
	for cell: Vector3i in cells:
		var coordinate := cell.x if x_side else cell.z
		edge = maxi(edge,coordinate) if high_side else mini(edge,coordinate)
	var boundary_cells: Array[Vector3i] = []
	for cell: Vector3i in cells:
		if (cell.x if x_side else cell.z) == edge: boundary_cells.append(cell)
	boundary_cells.sort_custom(func(a: Vector3i,b: Vector3i) -> bool: return a.z < b.z if x_side else a.x < b.x)
	# The middle B2 north sample overlaps the authored door body; use clear wall beside it.
	var sample_index := boundary_cells.size()/3 if branch == "B2" and side == "north" else boundary_cells.size()/2
	var selected: Vector3i = boundary_cells[sample_index]
	var item := wall.get_cell_item(selected)
	var mesh := wall.mesh_library.get_item_mesh(item)
	var transform := wall.global_transform * Transform3D(wall.get_cell_item_basis(selected).scaled(Vector3.ONE*wall.cell_scale),wall.map_to_local(selected)) * wall.mesh_library.get_item_mesh_transform(item)
	var bounds: AABB = transform * mesh.get_aabb()
	var inward := Vector3.RIGHT if side == "west" else (Vector3.LEFT if side == "east" else (Vector3.BACK if side == "north" else Vector3.FORWARD))
	var center := bounds.get_center()
	var half_width := bounds.size.x*0.5 if x_side else bounds.size.z*0.5
	var floor_cell: Vector3i = floor_map.get_used_cells()[0]
	var floor_y := floor_map.to_global(floor_map.map_to_local(floor_cell)).y
	var at := center+inward*(half_width+1.2)
	at.y = floor_y+0.15
	player.stop_automatic_stairs()
	player.global_position = at
	player.velocity = Vector3.ZERO
	wall.visible = true
	stage.get_node("CameraRig").snap_to_target()
	await frames(20)
	check(player.is_on_floor(),branch+" "+side+" start is supported inside perimeter")
	var ray := PhysicsRayQueryParameters3D.create(player.global_position+Vector3.UP,Vector3(center.x,player.global_position.y+1,center.z)-inward*0.4,1)
	ray.exclude = [player.get_rid()]
	wall.visible = false
	var hit := player.get_world_3d().direct_space_state.intersect_ray(ray)
	check(not hit.is_empty() and hit.collider == wall,branch+" "+side+" hidden GridMap retains its solid wall collision")
	wall.visible = true
	var action := "left" if side == "west" else ("right" if side == "east" else ("up" if side == "north" else "down"))
	Input.action_press(action)
	await jump_press()
	check(player.velocity.y > 0.0,branch+" "+side+" actually begins ground jump before boundary challenge")
	var contained := true
	var max_height := player.global_position.y
	for i in 70:
		await frames()
		contained = contained and (player.global_position-center).dot(inward) >= half_width-0.1
		max_height = maxf(max_height,player.global_position.y)
		if i == 15: await jump_press()
	Input.action_release(action)
	check(contained,branch+" "+side+" held movement plus repeated jump stays inside wall")
	print("PERIMETER_SAMPLE ",branch," ",side," cell=",selected," start=",at," end=",player.global_position," peak=",max_height)
