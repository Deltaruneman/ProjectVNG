extends Node3D
var checks := 0
var failures := 0
func check(ok: bool, label: String):
	checks+=1
	if not ok: failures+=1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int):
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
func _ready():
	if not "ArcanaMainMenu-20261127" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	run.call_deferred()
func run():
	SaveSystem.save_path="user://menu-fixture.json"
	GameManager.reset()
	SaveSystem.delete_save()
	var menu=load("res://ui/main_menu.tscn").instantiate()
	add_child(menu)
	await frames(5)
	check(menu.continue_button.disabled,"no-save Continue disabled")
	check(menu.new_button.has_focus(),"New Game gets initial keyboard focus")
	get_viewport().get_texture().get_image().save_png("user://main-menu.png")
	menu._settings()
	await frames(4)
	check(PauseMenu.is_open and get_tree().paused and PauseMenu._page=="settings","title opens existing settings")
	for tab in 3:
		PauseMenu._show_tab(tab)
		await frames(2)
		check(PauseMenu._content.get_child_count()>0,"title settings builds tab "+str(tab))
	PauseMenu._cancel_settings()
	await frames(5)
	check(not PauseMenu.is_open and not get_tree().paused and menu.is_visible_in_tree(),"cancel settings returns to title without starting game")
	GameManager.flags["story_possession"]=true
	GameManager.checkpoint_stage=GameManager.FIRST_STAGE
	GameManager.checkpoint_id="b2_start"
	GameManager.save_game()
	var saved=FileAccess.get_file_as_string(SaveSystem.save_path)
	menu._refresh_continue()
	check(not menu.continue_button.disabled,"compatible save enables Continue")
	menu._ask_new_game()
	await frames(3)
	check(menu.confirmation.visible and FileAccess.get_file_as_string(SaveSystem.save_path)==saved,"New Game confirms before replacing saved progress")
	menu.confirmation.hide()
	menu.queue_free()
	await frames(3)
	# Real main scene has to be root-owned for GameManager scene changes.
	menu=load("res://ui/main_menu.tscn").instantiate()
	get_tree().root.add_child(menu)
	get_tree().current_scene=menu
	await frames(3)
	menu._continue_game()
	await frames(90)
	var stage=GameManager.current_stage
	check(is_instance_valid(stage) and stage.scene_file_path==GameManager.FIRST_STAGE,"Continue enters actual retained stage")
	if is_instance_valid(stage):
		var spawn:Vector3=stage.get_node("B2/Checkpoint_b2/Spawn").global_position
		check(stage.player.global_position.distance_to(spawn)<0.6 and stage.player.is_on_floor(),"Continue restores B2 checkpoint spawn")
	check(FileAccess.get_file_as_string(SaveSystem.save_path)==saved,"Continue preserves checkpoint save file")
	if is_instance_valid(stage):
		stage.queue_free()
		await frames(3)
	menu=load("res://ui/main_menu.tscn").instantiate()
	get_tree().root.add_child(menu)
	get_tree().current_scene=menu
	await frames(3)
	menu._new_game()
	await frames(90)
	stage=GameManager.current_stage
	check(is_instance_valid(stage) and stage.scene_file_path==GameManager.FIRST_STAGE and GameManager.checkpoint_id=="","confirmed New Game starts a fresh retained stage")
	print("MAIN_MENU_RESULT ",checks-failures,"/",checks)
	get_tree().quit(0 if failures==0 else 1)
