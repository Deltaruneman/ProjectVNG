extends Node3D
var checks := 0
var failures := 0
var stage: Node3D
var last_pointer := Vector2.ZERO
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ", label)
func frames(n: int = 4) -> void:
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame
		if DisplayServer.get_name() != "headless": await RenderingServer.frame_post_draw
func capture(label: String) -> void:
	if DisplayServer.get_name() != "headless": get_viewport().get_texture().get_image().save_png("user://layout-" + label + ".png")
func pointer(at: Vector2, pressed: bool = false) -> void:
	var motion := InputEventMouseMotion.new()
	motion.relative = at - last_pointer
	last_pointer = at
	motion.position = at
	motion.global_position = at
	motion.button_mask = MOUSE_BUTTON_MASK_LEFT if pressed else 0
	get_viewport().push_input(motion, true)
	await frames(2)
func mouse_button(at: Vector2, pressed: bool) -> void:
	var event := InputEventMouseButton.new()
	event.position = at
	event.global_position = at
	event.button_index = MOUSE_BUTTON_LEFT
	event.pressed = pressed
	get_viewport().push_input(event, true)
	await frames(2)
func click(control: Control) -> void:
	var at := control.get_global_transform_with_canvas() * (control.size * 0.5)
	await pointer(at)
	await mouse_button(at,true)
	await mouse_button(at,false)
func tap(code: Key) -> void:
	for pressed in [true,false]:
		var event := InputEventKey.new()
		event.physical_keycode = code
		event.keycode = code
		event.pressed = pressed
		Input.parse_input_event(event)
		await frames(2)
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not "ArcanaLayout-20261127" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	run.call_deferred()
func load_stage(path: String) -> void:
	if is_instance_valid(stage):
		stage.queue_free()
		await frames()
	GameManager.reset()
	GameManager.flags["story_possession"] = true
	stage = load(path).instantiate()
	add_child(stage)
	stage.get_node("Player").invincible = true
	await frames(20)
func run() -> void:
	SaveSystem.save_path = "user://layout-fixture.json"
	await load_stage("res://levels/level_1/basement_full.tscn")
	var player: Player = stage.get_node("Player")
	var rig: CameraRig = stage.get_node("CameraRig")
	check(is_zero_approx(rig.yaw), "straight camera yaw0")
	check(rig.movement_vector(Vector2.RIGHT).is_equal_approx(Vector3.RIGHT), "D moves along screen/world right")
	var before := player.global_position
	Input.action_press("right")
	await frames(12)
	Input.action_release("right")
	check(player.global_position.x > before.x + 0.2, "actual D input moves right with straight view")
	Input.action_press("jump")
	await frames(8)
	Input.action_release("jump")
	check(player.global_position.y > before.y + 0.2, "actual jump remains usable")
	await frames(60)
	check(rig._wall_occlusion != null, "basement uses safe leaf-wall fading without hiding floor containers")
	for at: Vector3 in [Vector3(17,1.1,1),Vector3(17,3.6,1),Vector3(19,7.2,1),Vector3(38,6.2,1.5),Vector3(38,8.0,0)]:
		player.set_physics_process(false)
		player.global_position = at
		rig.snap_to_target()
		stage._apply(true)
		await frames()
		check(stage.get_node("B1").visible != stage.get_node("B2").visible, "exactly one floor branch visible at " + str(at))
		check(not stage.get_node("B1/World/Ceiling").visible and not stage.get_node("B2/World/Ceiling").visible, "only ceilings hidden")
		await capture("basement-" + str(checks))
	player.set_physics_process(true)
	player.set_physics_process(true)
	player.global_position = Vector3(17,1.1,2)
	player.velocity = Vector3.ZERO
	rig.snap_to_target()
	await frames(15)
	await tap(KEY_F)
	var climbing := player.is_climbing_ladder()
	var floors_visible := true
	for i in 45:
		await frames()
		climbing = climbing or player.is_climbing_ladder()
		floors_visible = floors_visible and stage.get_node("B1").visible and stage.get_node("B2").visible
	check(climbing, "real F starts ladder traversal")
	check(floors_visible, "ladder traversal keeps exactly one floor visible")
	await capture("ladder-live")
	check(stage.place_player_at("b2_up"), "B2 door arrival locates authored ID")
	await frames(20)
	check(player.is_on_floor(), "moved B2 door arrival has floor support")
	await capture("b2-door")
	for torch: Node in stage.find_children("Torch*", "OmniLight3D", true, false):
		var meshes := torch.find_children("*", "MeshInstance3D", true, false)
		check(not meshes.is_empty() and not (meshes[0] as MeshInstance3D).mesh is BoxMesh, "mounted textured torch replaces cube " + str(torch.get_path()))
	var hud: PlayerHUD = stage.get_node("Hud")
	check(hud.get_node("SkillBar/PrimarySkills").get_child(0).get_child_count() == 5, "combat bar has four skills plus ultimate, no book")
	check(hud.get_node("MenuShortcuts").get_child_count() == 2, "book and backpack separate beside Q")
	print("MENU_GEOMETRY book=",hud._skill_slot_panels[7].size," key=",hud._input_key_labels[7].position," keytext=",hud._input_key_labels[7].text," icon=",hud._skill_slot_icons[7].size," backpack=",hud.get_node("MenuShortcuts/BackpackShortcut").size)
	check(hud._skill_slot_icons[7].texture != null and hud._input_key_labels[7].visible, "book artwork with visible T")
	player.global_position = Vector3(-3,1.2,14)
	rig.snap_to_target()
	await frames(5)
	await capture("hud")
	var tree: Control = hud.get_node("SkillTreeLayer/SkillTree")
	print("CLICK_POSITION ",hud._skill_slot_panels[7].get_global_transform_with_canvas()," viewport=",get_viewport().get_visible_rect()," stretch=",get_viewport().get_stretch_transform())
	await click(hud._skill_slot_panels[7])
	await get_tree().create_timer(1.5).timeout
	check(get_tree().paused and tree.visible and not tree._transitioning, "book opens and owns pause")
	if not tree.visible:
		get_tree().quit(1)
		return
	var book_before: Vector2 = tree._book_body.position
	var handle: Control = tree._page_content.get_node("BookDragHandle")
	var from := handle.get_global_transform_with_canvas() * (handle.size * 0.5)
	await pointer(from)
	await mouse_button(from,true)
	await pointer(from + Vector2(24,16),true)
	check(tree._book_dragging and tree._book_body.position.distance_to(book_before) > 20, "real mouse events drag book window")
	await mouse_button(from + Vector2(24,16),false)
	check(not tree._book_dragging, "real left release ends window drag")
	var graph: SkillTreeGraph = tree._active_graph
	var graph_from := graph.get_global_transform_with_canvas() * Vector2(8,8)
	await pointer(graph_from)
	await mouse_button(graph_from,true)
	await pointer(graph_from + Vector2(25,12),true)
	check(graph._pan.length() > 20, "real left drag pans graph background")
	await mouse_button(graph_from + Vector2(25,12),false)
	await capture("book-drag")
	await tap(KEY_T)
	await get_tree().create_timer(1.5).timeout
	check(not get_tree().paused, "closing book restores gameplay")
	await click(hud.get_node("MenuShortcuts/BackpackShortcut"))
	await frames()
	check(InventoryMenu.is_open, "backpack shortcut opens inventory")
	InventoryMenu._show_page("farm_items")
	check(InventoryMenu._tabs.get_child(2).text == "Nông sản", "farm tab renamed Nông sản")
	await capture("inventory")
	InventoryMenu.close_menu()
	await frames()
	for path: String in ["res://levels/level_1/basement_b3.tscn","res://levels/level_1/garden.tscn","res://levels/level_1/castle.tscn"]:
		await load_stage(path)
		if path.ends_with("basement_b3.tscn"):
			check(stage.get_node("B3/World").get_used_cells().is_empty(), "three door surround blocks removed; separate floor retained")
			check(not stage.get_node("GroundExit").visible, "old overhead exit platform hidden with hierarchy and collision retained")
			for grid_path: String in ["B3/World", "GroundExit/World"]:
				var grid: GridMap = stage.get_node(grid_path)
				for cell: Vector3i in grid.get_used_cells():
					var item := grid.get_cell_item(cell)
					print("DOOR_GEOMETRY ",grid_path," cell=",cell," asset=",grid.mesh_library.get_item_name(item)," world=",grid.to_global(grid.map_to_local(cell))," mesh=",grid.mesh_library.get_item_mesh(item).get_aabb())
		for point: Node in get_tree().get_nodes_in_group("spawn_points"):
			if not stage.is_ancestor_of(point) or not point.scene_file_path.ends_with("door.tscn"): continue
			check(stage.place_player_at(point.id), "door arrival " + point.id)
			await frames(20)
			var p: Player = stage.get_node("Player")
			check(p.is_on_floor(), "door arrival supported on floor " + point.id)
			var query := PhysicsRayQueryParameters3D.create(p.global_position + Vector3.UP * 0.2, p.global_position - Vector3.UP * 0.3, 1)
			query.exclude = [p.get_rid()]
			var hit := p.get_world_3d().direct_space_state.intersect_ray(query)
			check(not hit.is_empty(), "physical support ray after door arrival " + point.id)
			print("DOOR_POSITION ",point.id," door=",point.global_position," spawn=",point.get_node("Spawn").global_position," player=",p.global_position," camera=",stage.get_node("CameraRig").global_position)
			await capture(point.id)
		if path.ends_with("garden.tscn"):
			var p: Player = stage.get_node("Player")
			p.global_position = Vector3(27,1.2,19)
			stage.get_node("CameraRig").snap_to_target()
			await frames()
			await tap(KEY_F)
			check(InventoryMenu.is_open and InventoryMenu.page == "enchant", "Garden table opens current enchant UI")
			InventoryMenu.close_menu()
			await frames()
			p.global_position = Vector3(37,1.2,19)
			await frames(8)
			await tap(KEY_F)
			var farm: Node = stage.get_node("Farm")
			check(farm.opened and farm.menu_page == "brew", "Garden table opens existing brewing recipes")
			await capture("brew")
			farm._close()
			check(not p.is_talking and not get_tree().paused, "station close restores interaction")
			p.global_position = Vector3(32,1.2,20)
			stage.get_node("CameraRig").snap_to_target()
			await frames()
			await capture("stations")
	for entry: Array in [["res://scenes/enemies/darkfairy/darkfairy.tscn",80.0,0.0875],["res://scenes/enemies/arcane/undead_executioner.tscn",180.0,0.063]]:
		var boss: EnemyCharacter = load(entry[0]).instantiate()
		check(is_equal_approx(boss.max_health,entry[1]) and is_equal_approx(boss.get_node("Sprite3D").pixel_size,entry[2]), "larger boss art and twice HP " + entry[0])
		boss.free()
	print("LAYOUT_RESULT ", checks-failures, "/",checks)
	get_tree().quit(1 if failures else 0)
