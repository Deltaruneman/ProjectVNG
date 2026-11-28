extends Node3D
var stage: Node3D
var player: Player
var rig: CameraRig
var checks := 0
var failures := 0

func check(ok: bool, label: String) -> void:
	checks += 1
	failures += 0 if ok else 1
	print("PASS " if ok else "FAIL ", label)

func frames(count: int = 1) -> void:
	for i in count:
		await get_tree().physics_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw

func capture(label: String) -> void:
	get_viewport().get_texture().get_image().save_png("user://wall-fade-"+label+".png")

func pixel() -> Color:
	var picture := get_viewport().get_texture().get_image()
	return picture.get_pixel(picture.get_width()/2,picture.get_height()/2)

func place(point: Vector3) -> void:
	player.global_position = point
	player.velocity = Vector3.ZERO
	rig.snap_to_target()

func map_wall(library: MeshLibrary, point: Vector3) -> GridMap:
	var map := GridMap.new()
	map.mesh_library = library
	map.cell_size = Vector3(3,5,3)
	map.cell_center_x = false
	map.cell_center_y = false
	map.cell_center_z = false
	map.set_cell_item(Vector3i.ZERO,7)
	stage.add_child(map)
	map.global_transform = Transform3D(rig.camera.global_basis,point)
	return map

func _ready() -> void:
	if not "ArcanaWallFade-20261126" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	_run.call_deferred()

func _run() -> void:
	SaveSystem.save_path = "user://wall-fade-fixture.json"
	GameManager.reset()
	GameManager.flags["story_possession"] = true
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
	var floor_body := StaticBody3D.new()
	var floor_shape := CollisionShape3D.new()
	var floor_box := BoxShape3D.new()
	floor_box.size = Vector3(80,1,80)
	floor_shape.shape = floor_box
	floor_body.add_child(floor_shape)
	stage.add_child(floor_body)
	floor_body.position = Vector3(400,-0.5,400)
	place(Vector3(400,0.1,400))
	await frames(10)
	var basis := rig.camera.global_basis
	var offset := rig.camera.global_position-rig.global_position
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.1,0.8,0.2)
	var box := BoxMesh.new()
	box.size = Vector3(2.4,4,0.4)
	box.material = material
	var shape := BoxShape3D.new()
	shape.size = box.size
	var library := MeshLibrary.new()
	library.create_item(7)
	library.set_item_mesh(7,box)
	library.set_item_shapes(7,[shape,Transform3D.IDENTITY])
	var wall := map_wall(library,rig.global_position+rig._boom_direction()*3.0)
	for cell: Vector3i in [Vector3i(0,0,1),Vector3i(1,0,0),Vector3i(2,0,0),Vector3i(0,1,0)]:
		wall.set_cell_item(cell,7)
	var upper_screen_wall := map_wall(library,rig.global_position-rig._boom_direction()*7.0)
	var transformed_library := library.duplicate() as MeshLibrary
	transformed_library.set_item_mesh_transform(7,Transform3D(Basis.from_euler(Vector3(0.0,0.2,0.0)),Vector3(0.3,0.4,0.5)))
	var scaled_map := map_wall(transformed_library,rig.global_position+Vector3(30,0,0))
	scaled_map.cell_scale = 1.8
	scaled_map.set_cell_item(Vector3i.ZERO,7,22)
	var cells := wall.get_used_cells().duplicate()
	var lower_screen_direction: Vector3 = -rig.camera.global_basis.y
	lower_screen_direction.y = 0.0
	lower_screen_direction = lower_screen_direction.normalized()
	var sight_anchor := player.global_position + Vector3.UP * 1.15
	var lower_screen_bounds := AABB(player.global_position + lower_screen_direction * 2.8 - Vector3(0.2, 0.0, 0.2), Vector3(0.4, 4.0, 0.4))
	var upper_screen_bounds := AABB(player.global_position - lower_screen_direction * 2.8 - Vector3(0.2, 0.0, 0.2), Vector3(0.4, 4.0, 0.4))
	var side_direction: Vector3 = rig.camera.global_basis.x
	side_direction.y = 0.0
	side_direction = side_direction.normalized()
	var side_bounds := AABB(player.global_position + side_direction * 2.8 - Vector3(0.2, 0.0, 0.2), Vector3(0.4, 4.0, 0.4))
	var lower_origin := player.global_position + lower_screen_direction * 5.0 + Vector3.UP * 1.5
	check(rig._wall_occlusion._blocks(Transform3D.IDENTITY,lower_screen_bounds,lower_origin,[sight_anchor]),"lower-screen wall can fade when it covers Player")
	check(not rig._wall_occlusion._blocks(Transform3D.IDENTITY,upper_screen_bounds,player.global_position-lower_screen_direction*5.0+Vector3.UP*1.5,[sight_anchor]),"upper-screen wall stays opaque")
	check(not rig._wall_occlusion._blocks(Transform3D.IDENTITY,side_bounds,player.global_position+side_direction*5.0+Vector3.UP*1.5,[sight_anchor]),"side wall stays opaque")
	rig.set_physics_process(false)
	await frames(10)
	var opaque := pixel()
	check(opaque.g > opaque.r+0.2 and wall.visible,"wall remains opaque when camera fading is inactive")
	await capture("opaque")
	rig.set_physics_process(true)
	await frames(45)
	var state: Dictionary = rig._wall_occlusion._grids[wall]
	var source_meshes := scaled_map.get_meshes()
	var scaled_record: Dictionary = rig._wall_occlusion._grids[scaled_map].records[0]
	check(source_meshes.size() == 2 and scaled_record.local.is_equal_approx(source_meshes[0]),"temporary wall visual matches Godot cell scale, orientation and mesh offset")
	var faded := 0
	var solid := 0
	for record: Dictionary in state.records:
		if record.cell.x == 0 and record.cell.y == 0:
			if record.blend > 0.99: faded += 1
		else:
			if is_zero_approx(float(record.blend)) and is_equal_approx(record.node.get_active_material(0).albedo_color.a,1.0): solid += 1
	check(faded == 2,"both stacked wall cells on Player sightlines fade")
	check(solid == 3,"wall cells outside Player sightlines stay opaque")
	check(upper_screen_wall.visible and not rig._wall_occlusion._grids[upper_screen_wall].active,"wall above Player on screen remains opaque")
	check(wall.get_used_cells() == cells and wall.mesh_library == library and library.get_item_shapes(7).size() == 2,"fade preserves source GridMap cells, library and collision shapes")
	check(box.material == material and is_equal_approx(material.albedo_color.a,1.0) and material.transparency == BaseMaterial3D.TRANSPARENCY_DISABLED,"shared source material is unchanged")
	var query := PhysicsRayQueryParameters3D.create(rig.camera.global_position,rig.global_position,1)
	query.exclude = [player.get_rid()]
	var hit := stage.get_world_3d().direct_space_state.intersect_ray(query)
	check(not hit.is_empty() and hit.collider == wall,"faded wall keeps its original physical collider")
	var translucent := pixel()
	print("FADE_PIXELS opaque=",opaque," faded=",translucent)
	check(translucent.r > opaque.r+0.15,"Player is visibly revealed through the faded wall")
	check(is_equal_approx(rig.camera.near,0.05) and rig.camera.global_basis.is_equal_approx(basis) and (rig.camera.global_position-rig.global_position).is_equal_approx(offset),"fade preserves fixed camera framing and normal near plane")
	await capture("player-visible")
	place(Vector3(414,0.1,400))
	await frames(40)
	check(wall.visible and not state.active and not state.visuals.visible,"moving away restores original opaque GridMap rendering")
	place(Vector3(400,0.1,400))
	await frames(40)
	check(state.active,"returning behind the wall fades it again")
	rig.set_physics_process(false)
	await frames(4)
	check(wall.visible and not state.active,"story camera takeover restores the authored wall visuals")
	rig.set_physics_process(true)
	await frames(30)
	wall.clear()
	await frames(8)
	check(wall.visible and wall.get_used_cells().is_empty() and rig._wall_occlusion._grids[wall].records.is_empty(),"clearing a breakable gate removes its temporary visuals without ghost walls")
	# Also cover a solid non-GridMap wall and its material restoration.
	upper_screen_wall.queue_free()
	var body := StaticBody3D.new()
	var mesh := MeshInstance3D.new()
	mesh.mesh = box
	body.add_child(mesh)
	var collision := CollisionShape3D.new()
	collision.shape = shape
	body.add_child(collision)
	stage.add_child(body)
	body.global_transform = Transform3D(basis,rig.global_position+rig._boom_direction()*3.0)
	await frames(45)
	check(mesh.get_active_material(0) != material and mesh.get_active_material(0).albedo_color.a < 0.3,"solid mesh wall uses a local transparent material copy")
	place(Vector3(414,0.1,400))
	await frames(40)
	check(mesh.get_active_material(0) == material and mesh.material_override == null,"solid mesh restores its exact original material")
	# The retained B3 roof must not cover Player; support floors stay opaque.
	var roof_mesh := BoxMesh.new()
	roof_mesh.size = Vector3(8,0.1,8)
	roof_mesh.material = material
	var roof_library := MeshLibrary.new()
	roof_library.create_item(7)
	roof_library.set_item_mesh(7,roof_mesh)
	var roof := map_wall(roof_library,player.global_position+Vector3(-2,4,2))
	roof.global_basis = Basis.IDENTITY
	var floor_visual_body := StaticBody3D.new()
	var floor_visual := MeshInstance3D.new()
	floor_visual.mesh = roof_mesh
	floor_visual_body.add_child(floor_visual)
	stage.add_child(floor_visual_body)
	floor_visual_body.position = player.global_position+Vector3(0,-0.15,0)
	await frames(45)
	var roof_state: Dictionary = rig._wall_occlusion._grids[roof]
	check(roof_state.active and roof_state.records[0].blend > 0.99,"overhead roof tile fades when it covers Player")
	check(floor_visual.get_active_material(0) == material and is_equal_approx(material.albedo_color.a,1.0),"supporting flat floor stays opaque beneath Player")
	await capture("overhead-player-visible")
	print("WALL_FADE_RESULT ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
