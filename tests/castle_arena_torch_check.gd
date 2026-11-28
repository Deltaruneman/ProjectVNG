extends Node3D
var checks := 0
var failures := 0
var stage: Node3D
var player: Player
var rig: CameraRig
var measurements: Array = []
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int = 3) -> void:
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
func capture(label: String) -> void:
	get_viewport().get_texture().get_image().save_png("user://arena-torch-"+label+".png")
func place(at: Vector3) -> void:
	player.global_position = at
	player.velocity = Vector3.ZERO
	rig.snap_to_target()
	await frames(40)
func wall_boxes() -> Array[AABB]:
	var boxes: Array[AABB] = []
	for grid: GridMap in stage.find_children("*","GridMap",true,false):
		if grid.mesh_library == null: continue
		for cell: Vector3i in grid.get_used_cells():
			var item := grid.get_cell_item(cell)
			if not grid.mesh_library.get_item_list().has(item): continue
			if not "wall" in grid.mesh_library.get_item_name(item).to_lower(): continue
			var mesh := grid.mesh_library.get_item_mesh(item)
			if mesh == null: continue
			var transform := grid.global_transform * Transform3D(grid.get_cell_item_basis(cell).scaled(Vector3.ONE*grid.cell_scale),grid.map_to_local(cell)) * grid.mesh_library.get_item_mesh_transform(item)
			var box: AABB = transform * mesh.get_aabb()
			if box.size.y > 0.7: boxes.append(box)
	return boxes
func check_mounts() -> int:
	var boxes := wall_boxes()
	var count := 0
	for torch: Node3D in stage.find_children("Torch*","Node3D",true,false):
		if torch.scene_file_path != "res://scenes/map/torches/torch.tscn" and not torch.scene_file_path.ends_with("torch_mounted.gltf"): continue
		count += 1
		var normal := torch.global_basis.z.normalized()
		var at := torch.global_position
		var axis := 0 if absf(normal.x) > 0.9 else 2
		var tangent := 2 if axis == 0 else 0
		var contact := false
		for box: AABB in boxes:
			if at.y < box.position.y or at.y > box.end.y: continue
			if at[tangent] < box.position[tangent]-0.05 or at[tangent] > box.end[tangent]+0.05: continue
			var plane: float = box.end[axis] if normal[axis] > 0 else box.position[axis]
			var gap := (at[axis]-plane)*normal[axis]
			if absf(gap-0.02) > 0.001: continue
			var probe := at+normal*0.02
			var covered := false
			for other: AABB in boxes:
				if other != box and other.has_point(probe): covered = true; break
			if not covered: contact = true; break
		var upright := torch.global_basis.y.normalized().dot(Vector3.UP)>0.999
		var light := torch as OmniLight3D
		if light == null: light = torch.get_node_or_null("Light") as OmniLight3D
		var lit := light != null and light.light_energy>0 and light.omni_range>0
		var back := INF
		for mesh: MeshInstance3D in torch.find_children("*","MeshInstance3D",true,false):
			var box := mesh.get_aabb()
			for corner in 8:
				var offset := mesh.to_global(box.get_endpoint(corner))-at
				back = minf(back,offset.dot(normal))
		var mounted := contact and upright and lit and absf(back)<0.001
		if not mounted: print("MOUNT_DIAG ",torch.name," at=",at," normal=",normal," transform=",var_to_str(torch.transform))
		check(mounted,str(stage.get_path_to(torch))+" back mount touches exposed wall, upright/inward, lit")
		measurements.append({"scene":stage.scene_file_path,"node":str(stage.get_path_to(torch)),"contact":contact,"upright":upright,"lit":lit,"mesh_back_offset":back})
	return count
func faded_count(map: GridMap) -> int:
	if not rig._wall_occlusion._grids.has(map): return 0
	var count := 0
	for record: Dictionary in rig._wall_occlusion._grids[map].records:
		if record.blend>0.9: count += 1
	return count
func _ready() -> void:
	if not "ArcanaWallFade-20261126" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	run.call_deferred()
func run() -> void:
	SaveSystem.save_path = "user://castle-arena-torch-fixture.json"
	GameManager.reset()
	GameManager.flags["story_possession"] = true
	for path: String in ["res://levels/level_1/basement_full.tscn","res://levels/level_1/basement_b3.tscn","res://levels/level_1/castle.tscn"]:
		stage = load(path).instantiate()
		add_child(stage)
		player = stage.get_node("Player")
		rig = stage.get_node("CameraRig")
		player.invincible = true
		for enemy: Node in get_tree().get_nodes_in_group("enemies"): enemy.process_mode = Node.PROCESS_MODE_DISABLED
		await frames(8)
		var expected := 28 if path.ends_with("castle.tscn") else (4 if path.ends_with("basement_b3.tscn") else 12)
		check(check_mounts()==expected,path.get_file()+" retains all authored mounted torches")
		if path.ends_with("basement_full.tscn"):
			await place(Vector3(15,0.1,1))
			await capture("basement-north")
			await place(Vector3(35.5,0.1,7))
			await capture("basement-side")
		elif path.ends_with("basement_b3.tscn"):
			await place(Vector3(33,0.1,2))
			await capture("b3-north")
		else:
			var arena: GridMap = stage.get_node("F1/World/ArenaFloor")
			var cells := arena.get_used_cells().duplicate()
			var library := arena.mesh_library
			await place(Vector3(54,1.1,32))
			check(arena.is_visible_in_tree() and not rig._wall_occlusion._grids.has(arena),"actual mini-boss ArenaFloor stays authored and excluded from fade proxies")
			await capture("arena-center")
			var stable := true
			for at: Vector3 in [Vector3(48,1.1,26),Vector3(60,1.1,38),Vector3(54,1.1,45)]:
				await place(at)
				stable = stable and arena.is_visible_in_tree() and not rig._wall_occlusion._grids.has(arena)
			check(stable,"arena decoration stays visible at center and three interior edges")
			check(arena.get_used_cells()==cells and arena.mesh_library==library,"arena source cells and shared library remain unchanged")
			await place(Vector3(54,1.1,60.6))
			var wall: GridMap = stage.get_node("F1/World/Wall")
			check(faded_count(wall)>0,"Castle lower-screen wall still fades")
			await capture("castle-wall-fade")
			await place(Vector3(54,1.1,32))
			await frames(30)
			check(wall.visible and faded_count(wall)==0,"Castle wall restores when Player leaves it")
			await place(Vector3(23,1.1,5))
			await capture("castle-north")
		stage.queue_free()
		await frames(4)
	var file := FileAccess.open("user://torch-mount-verified.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(measurements,"  "))
	print("ARENA_TORCH_RESULT ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
