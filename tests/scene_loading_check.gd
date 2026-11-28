extends Node
var checks := 0
var failures := 0
var registered := 0
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int = 3) -> void:
	for i in n:
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
func capture(label: String) -> void:
	get_viewport().get_texture().get_image().save_png("user://scene-loading-"+label+".png")
func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)
func tap(code: Key) -> void:
	key(code,true)
	await frames(1)
	key(code,false)
	await frames(1)
func wait_transition(label: String) -> void:
	var deadline := Time.get_ticks_msec()+25000
	while GameManager.is_changing() and Time.get_ticks_msec()<deadline:
		await frames(1)
	check(not GameManager.is_changing(),label+" completes without stuck loading")
	if GameManager.is_changing():
		get_tree().quit(1)
		return
	await frames(8)
func saved() -> String:
	return FileAccess.get_file_as_string(SaveSystem.save_path) if SaveSystem.has_save() else ""
func prepare_stage(stage: Stage) -> void:
	registered += 1
	stage.player.invincible = true
	GameManager.flags["story_possession"] = true
	GameManager.flags["story_b1_clear"] = true
	GameManager.flags["story_b2_clear"] = true
	for enemy: Node in stage.get_tree().get_nodes_in_group("enemies"): enemy.process_mode = Node.PROCESS_MODE_DISABLED
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not "ArcanaSceneLoading-20261128" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	run.call_deferred()
func run() -> void:
	SaveSystem.save_path = "user://scene-loading-fixture.json"
	GameManager.reset()
	SaveSystem.delete_save()
	GameManager.stage_changed.connect(prepare_stage)
	var menu: Control = load("res://ui/main_menu.tscn").instantiate()
	get_tree().root.add_child(menu)
	get_tree().current_scene = menu
	await frames(5)
	check(menu.continue_button.disabled,"new title disables Continue with no save")
	menu.new_button.pressed.emit()
	var loader = GameManager._scene_loading
	check(loader.busy and loader._root.visible and get_tree().current_scene==menu,"New Game immediately covers old scene before replacing it")
	await frames(3)
	check(loader._root.theme==InventoryMenu._panel.theme and loader._card.get_theme_stylebox("panel")==InventoryMenu._skin("panel_stone",30),"loading reuses title/inventory theme and stone skin")
	check(loader._destination.text=="Hầm ngục","loading shows friendly destination name")
	await capture("new-game")
	var first_elapsed: float = loader._elapsed
	await frames(3)
	check(loader._elapsed>first_elapsed,"loading animation continues across rendered frames")
	await wait_transition("New Game")
	var stage: Stage = GameManager.current_stage
	check(is_instance_valid(stage) and stage.scene_file_path==GameManager.FIRST_STAGE,"New Game enters retained basement")
	check(not get_tree().paused and not loader._root.visible,"new stage releases pause/input and hides loading")
	if Dialogic.current_timeline != null: Dialogic.end_timeline(true)
	GameManager.checkpoint_stage = GameManager.FIRST_STAGE
	GameManager.checkpoint_id = "b2_start"
	GameManager.save_game()
	var checkpoint := saved()
	GameManager.experience += 23
	stage.player.health = 2.5
	await tap(KEY_ESCAPE)
	check(PauseMenu.is_open and get_tree().paused,"Escape opens actual paused gameplay menu")
	var button: Button
	var old_quit := false
	for node: Node in PauseMenu._content.get_children():
		if node is Button and node.text=="Về menu chính": button = node
		if node is Button and node.text=="Thoát trò chơi": old_quit = true
	check(button!=null and not old_quit,"pause replaces Quit with Về menu chính")
	await capture("pause")
	button.pressed.emit()
	check(PauseMenu._confirmation=="main_menu" and PauseMenu._dialog_accept.text=="Về menu chính","confirmation names returning to main menu")
	await frames(2)
	await capture("confirmation")
	PauseMenu._dialog_cancel.pressed.emit()
	check(get_tree().current_scene==stage and PauseMenu.is_open and saved()==checkpoint,"cancel keeps stage, pause and checkpoint bytes")
	button.pressed.emit()
	PauseMenu._dialog_accept.pressed.emit()
	await frames(3)
	check(loader.busy and loader._destination.text=="Menu chính","accept uses common loading for return to title")
	var before: Vector3 = stage.player.global_position
	Input.action_press("right")
	await tap(KEY_F9)
	await tap(KEY_T)
	await tap(KEY_B)
	Input.action_release("right")
	check(saved()==checkpoint and GameManager.checkpoint_id=="b2_start","F9 and menu shortcuts during loading cannot reset saved progress")
	if is_instance_valid(stage): check(stage.player.global_position.is_equal_approx(before),"outgoing gameplay stays frozen behind loading")
	await capture("return-to-title")
	await wait_transition("Return to title")
	menu = get_tree().current_scene
	check(menu.scene_file_path==GameManager.MAIN_MENU and GameManager.current_stage==null,"return loads actual title and clears stale Stage reference")
	check(not PauseMenu.is_open and not InventoryMenu.is_open and not get_tree().paused,"return releases old menus and pause ownership")
	check(saved()==checkpoint and not menu.continue_button.disabled,"return preserves checkpoint bytes and enables Continue")
	await capture("title-returned")
	menu.settings_button.pressed.emit()
	await frames(4)
	check(PauseMenu.is_open and PauseMenu._page=="settings","returned title still opens settings")
	PauseMenu._cancel_settings()
	await frames(5)
	check(not PauseMenu.is_open and not get_tree().paused,"title settings close cleanly after return")
	menu.continue_button.pressed.emit()
	check(loader.busy,"Continue uses shared loading")
	await wait_transition("Same-process Continue")
	stage = GameManager.current_stage
	var spawn: Vector3 = stage.get_node("B2/Checkpoint_b2/Spawn").global_position
	check(stage.player.global_position.distance_to(spawn)<0.65 and stage.player.is_on_floor(),"Continue after return restores exact B2 checkpoint with support")
	check(GameManager.experience!=23 and saved()==checkpoint,"Continue reloads saved progress and preserves checkpoint file")
	GameManager.respawn()
	check(loader.busy,"checkpoint respawn uses shared loading")
	await wait_transition("Respawn")
	stage = GameManager.current_stage
	check(stage.player.global_position.distance_to(spawn)<0.65 and stage.player.health==stage.player.max_health,"respawn restores saved spawn and full HP")
	GameManager.flags.erase("b2_cleared")
	GameManager.change_stage(GameManager.B3_STAGE,"b3_entry")
	check(not loader.busy and get_tree().current_scene==stage,"locked B3 refuses before any loading or scene replacement")
	var before_failed := saved()
	GameManager.change_stage("res://icon.svg","",false)
	var deadline := Time.get_ticks_msec()+12000
	while not loader._error and Time.get_ticks_msec()<deadline: await frames(1)
	check(loader._error and loader._back.visible and get_tree().current_scene==stage,"non-scene load shows recoverable error over retained stage")
	check(get_tree().paused,"failed load keeps outgoing gameplay paused until user returns")
	DisplayServer.window_set_size(Vector2i(800,450))
	await frames(8)
	var rect := Rect2(loader._design.position,loader._design.size*loader._design.scale)
	check(get_viewport().get_visible_rect().encloses(rect),"loading design fits smaller window")
	await capture("error-small")
	await tap(KEY_ENTER)
	await frames(3)
	check(not loader.busy and not GameManager.is_changing() and not get_tree().paused and saved()==before_failed,"failure return clears loading lock/pause and preserves save")
	DisplayServer.window_set_size(Vector2i(1280,720))
	GameManager.change_stage(GameManager.FIRST_STAGE,"b2_start",false)
	var count := registered
	GameManager.change_stage("res://levels/level_1/garden.tscn","",false)
	await wait_transition("Valid transition after failure")
	stage = GameManager.current_stage
	check(stage.scene_file_path==GameManager.FIRST_STAGE and registered==count+1,"duplicate request is ignored and subsequent valid load succeeds once")
	# Cross-stage checkpoint proves Continue no longer depends on first-ever Stage bootstrap.
	GameManager.checkpoint_stage = "res://levels/level_1/garden.tscn"
	GameManager.checkpoint_id = "garden_checkpoint"
	# Use the authored id; never invent a game spawn.
	var garden: Stage = load(GameManager.checkpoint_stage).instantiate()
	var id := ""
	var spawn_path := ""
	for node: Node in garden.find_children("*","Node",true,false):
		if node.get_script()!=null and "id" in node and node.get_node_or_null("Spawn")!=null and "checkpoint" in str(node.name).to_lower():
			id = node.id
			spawn_path = str(garden.get_path_to(node))+"/Spawn"
	garden.free()
	if id!="":
		GameManager.checkpoint_id = id
		GameManager.save_game()
		GameManager.return_to_main_menu()
		await wait_transition("Second return to title")
		menu = get_tree().current_scene
		menu.continue_button.pressed.emit()
		await wait_transition("Cross-stage Continue")
		check(GameManager.current_stage.scene_file_path=="res://levels/level_1/garden.tscn","same-process Continue restores saved Garden stage directly")
		await frames(20)
		var garden_spawn: Vector3 = GameManager.current_stage.get_node(spawn_path).global_position
		check(GameManager.current_stage.player.global_position.distance_to(garden_spawn)<0.65 and GameManager.current_stage.player.is_on_floor(),"cross-stage Continue restores authored Garden checkpoint with support")
	else:
		check(false,"authored Garden checkpoint found for cross-stage Continue")
	# Failed title start must re-enable its actions rather than leaving _starting latched.
	GameManager.checkpoint_stage = "res://icon.svg"
	GameManager.checkpoint_id = "invalid-test-resource"
	GameManager.save_game()
	GameManager.return_to_main_menu()
	await wait_transition("Title before failing Continue")
	menu = get_tree().current_scene
	menu.continue_button.pressed.emit()
	deadline = Time.get_ticks_msec()+12000
	while not loader._error and Time.get_ticks_msec()<deadline: await frames(1)
	check(loader._error and menu._starting,"failed title Continue keeps old title available under error cover")
	await tap(KEY_ENTER)
	check(not menu._starting and not GameManager.is_changing() and not get_tree().paused,"keyboard error return re-enables title actions and clears transition state")
	GameManager.checkpoint_stage = GameManager.FIRST_STAGE
	GameManager.checkpoint_id = "b2_start"
	GameManager.save_game()
	menu._refresh_continue()
	menu.continue_button.pressed.emit()
	await wait_transition("Title retry after failure")
	check(GameManager.current_stage.scene_file_path==GameManager.FIRST_STAGE,"title can Continue successfully after a failed load")
	print("SCENE_LOADING_RESULT ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
