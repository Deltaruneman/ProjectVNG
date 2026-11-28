extends Node3D
var checks := 0
var failures := 0
var stage: Node3D
var player: Player
var rig: CameraRig
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int = 3) -> void:
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
func capture(label: String) -> void:
	get_viewport().get_texture().get_image().save_png("user://basement-fade-"+label+".png")
func place(at: Vector3) -> void:
	player.stop_automatic_stairs()
	player.global_position = at
	player.velocity = Vector3.ZERO
	rig.snap_to_target()
	await frames(35)
func near_wall(branch: String,side: String) -> Vector3:
	var map: GridMap = stage.get_node(branch+"/World/Wall")
	var cells := map.get_used_cells()
	var edge := -2147483647 if side == "south" else 2147483647
	for cell: Vector3i in cells: edge = maxi(edge,cell.z) if side == "south" else mini(edge,cell.x)
	var samples: Array[Vector3i] = []
	for cell: Vector3i in cells:
		if (cell.z if side == "south" else cell.x) == edge: samples.append(cell)
	samples.sort_custom(func(a: Vector3i,b: Vector3i) -> bool: return a.x < b.x if side == "south" else a.z < b.z)
	var cell: Vector3i = samples[samples.size()/2]
	var item := map.get_cell_item(cell)
	var mesh := map.mesh_library.get_item_mesh(item)
	var transform := map.global_transform * Transform3D(map.get_cell_item_basis(cell).scaled(Vector3.ONE*map.cell_scale),map.map_to_local(cell)) * map.mesh_library.get_item_mesh_transform(item)
	var bounds: AABB = transform * mesh.get_aabb()
	var inward := Vector3.FORWARD if side == "south" else Vector3.RIGHT
	var half_width := bounds.size.z*0.5 if side == "south" else bounds.size.x*0.5
	var point := bounds.get_center()+inward*(half_width+0.82)
	var floor_map: GridMap = stage.get_node(branch+"/World/Floor")
	point.y = floor_map.to_global(floor_map.map_to_local(floor_map.get_used_cells()[0])).y+0.1
	return point
func faded_count(map: GridMap) -> int:
	if rig._wall_occlusion == null or not rig._wall_occlusion._grids.has(map): return 0
	var count := 0
	for record: Dictionary in rig._wall_occlusion._grids[map].records:
		if record.blend > 0.9: count += 1
	return count
func _ready() -> void:
	if not "ArcanaWallFade-20261126" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	run.call_deferred()
func run() -> void:
	SaveSystem.save_path = "user://basement-wall-fade-fixture.json"
	GameManager.reset()
	GameManager.flags["story_possession"] = true
	stage = load("res://levels/level_1/basement_full.tscn").instantiate()
	add_child(stage)
	player = stage.get_node("Player")
	rig = stage.get_node("CameraRig")
	player.invincible = true
	await frames(15)
	await place(near_wall("B1","south"))
	check(rig._wall_occlusion != null,"basement has active wall-fade helper")
	if rig._wall_occlusion == null:
		await capture("disabled-before")
		print("BASEMENT_FADE_BEFORE ",checks-failures,"/",checks)
		get_tree().quit(1)
		return
	var map: GridMap = stage.get_node("B1/World/Wall")
	var cells := map.get_used_cells().duplicate()
	var library := map.mesh_library
	rig.set_physics_process(false)
	await frames(5)
	await capture("opaque")
	rig.set_physics_process(true)
	await frames(45)
	check(faded_count(map)>0,"actual B1 foreground wall fades near Player")
	check(stage.get_node("B1/World").is_visible_in_tree() and stage.get_node("B1/World/Floor").is_visible_in_tree(),"fading wall cannot hide its parent World or sibling Floor")
	check(not stage.get_node("B2").visible,"upper floor remains hidden while on B1")
	check(not rig._wall_occlusion._grids.has(stage.get_node("B1/World")) and not rig._wall_occlusion._grids.has(stage.get_node("B1/World/Floor")),"container GridMap and support Floor are excluded from replacement")
	check(map.get_used_cells()==cells and map.mesh_library==library,"actual wall retains all cells and shared mesh library")
	var ray := PhysicsRayQueryParameters3D.create(player.global_position+Vector3.UP,player.global_position+Vector3.UP+Vector3.BACK*4,1)
	ray.exclude = [player.get_rid()]
	var hit := player.get_world_3d().direct_space_state.intersect_ray(ray)
	check(not hit.is_empty() and hit.collider==map,"actual faded wall still blocks physics ray")
	await capture("b1-player-visible")
	await place(Vector3(0,0.1,10))
	await frames(40)
	check(map.visible and faded_count(map)==0,"moving away restores opaque B1 wall")
	await place(near_wall("B1","west"))
	check(faded_count(map)>0,"side wall covering sprite edge also fades")
	await capture("side-wall")
	await place(near_wall("B2","south"))
	var upper_wall: GridMap = stage.get_node("B2/World/Wall")
	check(faded_count(upper_wall)>0,"translated B2 foreground wall fades")
	check(stage.get_node("B2/World/Floor").is_visible_in_tree() and not stage.get_node("B1").visible,"B2 floor remains visible and lower floor stays hidden")
	await capture("b2-player-visible")
	await place(Vector3(17,1.1,2))
	var e := InputEventKey.new()
	e.physical_keycode = KEY_F
	e.keycode = KEY_F
	e.pressed = true
	Input.parse_input_event(e)
	await frames(2)
	e = e.duplicate()
	e.pressed = false
	Input.parse_input_event(e)
	var climbed := player.is_climbing_ladder()
	var stable := true
	for i in 180:
		await frames()
		var lower: Node3D = stage.get_node("B1")
		var upper: Node3D = stage.get_node("B2")
		var active: Node3D = lower if lower.visible else upper
		stable = stable and lower.visible != upper.visible and active.get_node("World/Floor").is_visible_in_tree()
	check(climbed,"actual F ladder remains usable with wall helper enabled")
	check(stable,"180 climb frames retain exactly one visible floor and solid floor rendering")
	await capture("ladder")
	print("BASEMENT_FADE_RESULT ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
