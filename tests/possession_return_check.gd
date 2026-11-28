extends Node
var checks := 0
var failures := 0
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int = 3) -> void:
	for i in n:
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
func wait_for(test: Callable,label: String) -> void:
	var deadline := Time.get_ticks_msec()+20000
	while not test.call() and Time.get_ticks_msec()<deadline: await frames(1)
	check(test.call(),label)
	if not test.call(): get_tree().quit(1)
func choices() -> void:
	var deadline := Time.get_ticks_msec()+12000
	while Time.get_ticks_msec()<deadline:
		if Dialogic.current_state==Dialogic.States.AWAITING_CHOICE:
			while not Dialogic.Choices._choice_blocker.is_stopped(): await frames(1)
			await frames(3)
			return
		if Dialogic.current_state==Dialogic.States.REVEALING_TEXT: Dialogic.Text.skip_text_reveal()
		elif Dialogic.current_state==Dialogic.States.IDLE and Dialogic.current_timeline!=null: Dialogic.handle_next_event()
		await frames(2)
	check(false,"opening choice reached before timeout")
func finish_dialogue() -> void:
	for i in 160:
		if Dialogic.current_timeline==null: return
		if Dialogic.current_state==Dialogic.States.REVEALING_TEXT: Dialogic.Text.skip_text_reveal()
		elif Dialogic.current_state==Dialogic.States.IDLE: Dialogic.handle_next_event()
		await frames(2)
	check(false,"accepted dialogue ends before timeout")
func capture(label: String) -> void:
	await frames(2)
	get_viewport().get_texture().get_image().save_png("user://possession-return-"+label+".png")
func saved() -> String:
	return FileAccess.get_file_as_string(SaveSystem.save_path) if SaveSystem.has_save() else ""
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not "ArcanaPossession-20261128" in OS.get_user_data_dir(): get_tree().quit(2); return
	run.call_deferred()
func run() -> void:
	SaveSystem.save_path = "user://possession-return-fixture.json"
	GameManager.reset()
	SaveSystem.delete_save()
	GameManager.stage_changed.connect(func(stage: Stage):
		stage.player.invincible = true
		for enemy: Node in get_tree().get_nodes_in_group("enemies"): enemy.process_mode = Node.PROCESS_MODE_DISABLED)
	var menu: Control = load(GameManager.MAIN_MENU).instantiate()
	get_tree().root.add_child(menu)
	get_tree().current_scene = menu
	await frames(4)
	menu._new_game()
	await wait_for(func(): return not GameManager.is_changing() and is_instance_valid(GameManager.current_stage),"New Game completes loading")
	await choices()
	var stage: Stage = GameManager.current_stage
	var story: Node = stage.get_node("BasementStory")
	check(story.busy and story._active=="possession" and stage.player.is_talking,"real opening timeline owns Player/world")
	check(Dialogic.Choices.get_choice_button(1).text=="Có" and Dialogic.Choices.get_choice_button(2).text=="Không","actual opening has Yes and No choices")
	await capture("choice")
	var before := saved()
	var had_save := SaveSystem.has_save()
	Dialogic.Choices.select_choice(2)
	await wait_for(func(): return get_tree().current_scene.scene_file_path==GameManager.MAIN_MENU and not GameManager.is_changing(),"No completes common loading into actual main menu")
	check(Dialogic.current_timeline==null,"No ends dialogue and leaves no root dialogue running")
	check(not GameManager.flags.get("story_possession",false),"No does not mark opening accepted")
	check(SaveSystem.has_save()==had_save and saved()==before,"No does not create/change checkpoint save")
	check(not get_tree().paused and GameManager.current_stage==null and not PauseMenu.is_open,"No returns usable title with no stale stage/pause")
	check(not is_instance_valid(stage),"declined stage is released")
	await capture("menu")
	menu = get_tree().current_scene
	menu._new_game()
	await wait_for(func(): return not GameManager.is_changing() and is_instance_valid(GameManager.current_stage),"New Game after refusal can load again")
	await choices()
	stage = GameManager.current_stage
	story = stage.get_node("BasementStory")
	check(story.busy and not story._accepted and not story._declined,"fresh opening offers choices again without stale decision")
	Dialogic.Choices.select_choice(1)
	await finish_dialogue()
	await frames(10)
	check(GameManager.flags.get("story_possession",false) and SaveSystem.has_save(),"Yes keeps normal acceptance and save")
	check(not story.busy and not stage.player.is_talking and stage.player.can_interact(),"Yes restores Player interaction")
	check(stage.process_mode!=Node.PROCESS_MODE_DISABLED and stage.camera_rig.process_mode!=Node.PROCESS_MODE_DISABLED,"Yes restores stage and camera processing")
	check(not GameManager.is_changing() and get_tree().current_scene==stage and Dialogic.current_timeline==null,"Yes remains in gameplay with finished dialogue")
	await capture("accepted")
	story._on_story_signal("story_decline")
	await frames(3)
	check(get_tree().current_scene==stage and not GameManager.is_changing(),"stray decline outside opening cannot return to title")
	GameManager.return_to_main_menu()
	await wait_for(func(): return get_tree().current_scene.scene_file_path==GameManager.MAIN_MENU and not GameManager.is_changing(),"accepted game can return to title")
	menu = get_tree().current_scene
	menu._continue_game()
	await wait_for(func(): return not GameManager.is_changing() and is_instance_valid(GameManager.current_stage),"accepted save can Continue")
	await frames(20)
	check(GameManager.flags.get("story_possession",false) and Dialogic.current_timeline==null and not GameManager.current_stage.get_node("BasementStory").busy,"Continue after Yes does not replay opening")
	print("POSSESSION_RETURN_RESULT ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
