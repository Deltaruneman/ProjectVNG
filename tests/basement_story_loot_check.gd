extends SceneTree
## Rendered actual-scene regression; run only with isolated custom save directory.
const FULL := "res://levels/level_1/basement_full.tscn"
const B1 := "res://levels/level_1/basement_b1.tscn"
const B2 := "res://levels/level_1/basement_b2.tscn"
const B3 := "res://levels/level_1/basement_b3.tscn"
const GARDEN := "res://levels/level_1/garden.tscn"
const CHEST_PATH := "res://levels/objects/experience_point/floor_clear_chest.tscn"
var checks := 0
var failures := 0
var manager: Node
var dialogue: Node

func _initialize() -> void:
	_run.call_deferred()
	_watchdog.call_deferred()

func _watchdog() -> void:
	await create_timer(150).timeout
	push_error("Story fixture timed out")
	quit(1)

func check(ok: bool, label: String) -> void:
	checks += 1
	print("PASS " if ok else "FAIL ", label)
	if not ok:
		failures += 1

func ticks(count: int = 5) -> void:
	for index in count:
		await physics_frame

func tap_f() -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = KEY_F
		event.physical_keycode = KEY_F
		event.pressed = pressed
		root.push_input(event)
		await ticks(2)

func finish_dialogue(choices: bool = false) -> void:
	for frame in 200:
		if dialogue.current_timeline == null:
			return
		if dialogue.current_state == 3:
			await ticks(35)
			if choices:
				return
			check(false, "unexpected choice")
			return
		if dialogue.current_state == 1:
			dialogue.Text.skip_text_reveal()
		elif dialogue.current_state == 0:
			dialogue.handle_next_event()
		await ticks(2)
	check(false, "dialogue completed within bound")

func capture(name: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png("user://" + name + ".png")

func load_stage(path: String) -> void:
	manager.change_stage(path)
	await scene_changed
	await ticks(3)

func freeze_enemies() -> void:
	for enemy in get_nodes_in_group("enemies"):
		enemy.set_physics_process(false)
	for node in current_scene.find_children("*", "EnemyCharacter", true, false):
		node.set_physics_process(false)

func wall_ray(stage: Node3D) -> bool:
	var query := PhysicsRayQueryParameters3D.create(Vector3(36,2,13), Vector3(42,2,13), 1)
	return not stage.get_world_3d().direct_space_state.intersect_ray(query).is_empty()

func _run() -> void:
	var custom := str(ProjectSettings.get_setting("application/config/custom_user_dir_name", ""))
	if not bool(ProjectSettings.get_setting("application/config/use_custom_user_dir", false)) or not custom.begins_with("ArcanaStory-") or not "--isolated-copy" in OS.get_cmdline_user_args():
		push_error("Run only in an isolated copy with ArcanaStory- custom save directory")
		quit(1)
		return
	manager = root.get_node("GameManager")
	dialogue = root.get_node("Dialogic")
	manager.reset()
	var notebook_timeline = load("res://dialog/timelines/prison_notebook.dtl")
	notebook_timeline.process()
	var notebook_text: Array[String] = []
	for event in notebook_timeline.events:
		if event.get("event_name") == "Text":
			check(event.get("character") == null, "notebook field remains narrator text, no temporary speaker")
			notebook_text.append(str(event.get("text")))
	check(notebook_text.has("Tên: ----") and notebook_text.has("Quê quán: ----"), "notebook labels render literal colons")
	var door_timeline = load("res://dialog/timelines/b2_locked.dtl")
	door_timeline.process()
	check(door_timeline.events[0].character.resource_path == "res://dialog/characters/prison_door.dch", "door uses registered character instead of temporary speaker")
	var catalog = load("res://scripts/item_catalog.gd")
	for id: String in catalog.definitions():
		check(catalog.texture(id) != null, "random loot icon loads: " + id)
	await load_stage(FULL)
	var stage = current_scene
	var story = stage.get_node("BasementStory")
	await ticks(15)
	check(story.busy and stage.player.is_talking and stage.process_mode == Node.PROCESS_MODE_DISABLED, "opening locks world and Player")
	await finish_dialogue(true)
	check(dialogue.Choices.get_choice_button(1).text == "Có" and dialogue.Choices.get_choice_button(2).text == "Không", "real Có / Không choices")
	await capture("possession-choice")
	dialogue.Choices.select_choice(2)
	await ticks(3)
	await finish_dialogue(true)
	check(not manager.flags.get("story_possession",false) and story.busy, "Không cannot start gameplay")
	dialogue.Choices.select_choice(1)
	await ticks(3)
	await finish_dialogue()
	await ticks(3)
	check(manager.flags.get("story_possession",false) and not story.busy and not stage.player.is_talking and stage.process_mode != Node.PROCESS_MODE_DISABLED, "Có accepts and restores gameplay")
	stage.player.set_physics_process(false)
	for zone in stage.get_node("B1/EnemyZones").get_children():
		zone.get_node("Timer").stop()
		zone._defeated = zone.clear_kills
		zone.cleared.emit()
	await ticks(5)
	check(story.busy and story._active == "b1_clear", "actual zone-clear signals trigger B1 monologue")
	var camera: Camera3D = stage.camera_rig.camera
	var old_pose: Transform3D = story._camera_transform
	for step in 40:
		if story._camera_tween != null:
			break
		if dialogue.current_state == 1:
			dialogue.Text.skip_text_reveal()
		elif dialogue.current_state == 0:
			dialogue.handle_next_event()
		await ticks(2)
	await ticks(45)
	check(camera.fov < 50 and camera.global_position.distance_to(stage.get_node("B1/LadderSpot_B1_B2").global_position) < 12, "rendered ladder focus zoom")
	await capture("ladder-focus")
	await finish_dialogue()
	await ticks(2)
	check(manager.flags.get("story_b1_clear",false) and camera.global_transform.is_equal_approx(old_pose) and is_equal_approx(camera.fov, story._camera_fov), "camera restored and B1 story saved")
	await _camera_views(stage)
	await _chest(stage)
	stage = current_scene
	story = stage.get_node("BasementStory")
	# Main scene B2 locked-door hook, then split B2 portal interaction.
	var door = stage.get_node("B2/Door_b2_up")
	door._tell_locked()
	await ticks()
	check(story.busy and story._active == "b2_locked" and current_scene == stage, "main B2 locked door dialogue")
	await finish_dialogue()
	await load_stage(B1)
	stage = current_scene
	stage.player.set_physics_process(false)
	freeze_enemies()
	await _wall(stage)
	await load_stage(B2)
	stage = current_scene
	stage.player.set_physics_process(false)
	freeze_enemies()
	stage.player.global_position = stage.get_node("B2/ClearPortal").global_position + Vector3.UP * 0.2
	await ticks(10)
	await tap_f()
	story = stage.get_node("BasementStory")
	check(story.busy and story._active == "b2_locked" and current_scene == stage, "real F at locked split B2 exit talks without travel")
	await finish_dialogue()
	manager.flags["b2_cleared"] = true
	await load_stage(B3)
	await _boss()
	await _teardown()
	# Fresh legacy opened B1 chest stays empty; no migration duplicate.
	manager.collected_exp_points.append("floor_clear:basement_b1")
	var legacy = load(CHEST_PATH).instantiate()
	current_scene.add_child(legacy)
	await ticks(2)
	check(legacy._is_open() and not legacy.has_node("InteractiveArea3D"), "legacy opened B1 chest remains opened")
	manager.save_game()
	manager.flags.clear()
	manager.load_game()
	check(manager.flags.get("story_possession",false) and manager.flags.get("b1_secret_wall_broken",false), "real save reload preserves story and secret state")
	await load_stage(B1)
	await ticks(4)
	check(not current_scene.get_node("BasementStory").busy and not wall_ray(current_scene), "revisit skips seen story and keeps wall collision removed")
	print("STORY_LOOT_RESULT ", checks-failures, "/", checks, " failures=", failures)
	quit(0 if failures == 0 else 1)

func _chest(stage: Node3D) -> void:
	var chest = stage.get_node("B1/ChestSpot").get_child(0)
	stage.player.global_position = chest.global_position + Vector3(1.2,0.1,0.4)
	await ticks(8)
	var before: int = manager.inventory.items.size()
	await tap_f()
	await tap_f()
	var state: Dictionary = manager.flags.get("chest_loot:basement_b1_clear",{})
	var items: Array = state.get("items",[])
	check(items.size() in [1,2] and items[0] in ["sword","axe","spear","dagger"], "first chest rolls1–2 items with guaranteed weapon")
	check(manager.inventory.items.size() == before, "loot not granted before physical collection")
	await ticks(25)
	check(chest.get_node("Sprite3D").texture == chest.OPEN_TEXTURE and get_nodes_in_group("chest_drops").size() == items.size()+10, "five-frame opening emits item drops plus10EXP orbs")
	stage.camera_rig.snap_to_target()
	await ticks(12)
	await capture("chest-opening")
	# Interrupt before collection, carry pending rewards to Garden through actual scene transition.
	await load_stage(GARDEN)
	current_scene.player.set_physics_process(false)
	await ticks(180)
	state = manager.flags["chest_loot:basement_b1_clear"]
	check(state.claimed.size() == items.size()+10 and manager.inventory.items.size() == before+items.size(), "pending rewards restored and collected exactly once in Garden")
	check(manager.player_level == 2 and manager.experience == 100 and manager.skill_points == 3, "exact200EXP; level-up alone grants3SP")
	manager.save_game()
	manager.load_game()
	await load_stage(FULL)
	current_scene.player.set_physics_process(false)
	for zone in current_scene.find_children("*", "EnemyZone", true, false):
		zone.get_node("Timer").stop()
	await ticks(90)
	check(manager.inventory.items.size() == before+items.size() and manager.player_level == 2 and manager.experience == 100 and get_nodes_in_group("chest_drops").is_empty(), "save/scene reload does not duplicate claimed chest loot")

func _wall(stage: Node3D) -> void:
	var wall = stage.get_node("B1/HiddenGate_B1_5")
	check(wall_ray(stage), "secret wall blocks passage before hits")
	var hurt: HurtArea3D = wall.get_node("HurtArea3D")
	hurt.take_damage(Vector3.RIGHT,1,null)
	check(wall.hits == 0, "non-player damage cannot break secret wall")
	var hit: HitArea3D = stage.player.get_node("Direction/HitArea3D")
	stage.player.global_position = Vector3(37.9,1,13)
	for index in wall.hits_required:
		hit.hit(hurt)
		await ticks(12)
	check(wall._broken and wall.get_node("B1_5Side").get_used_cells().is_empty() and not wall_ray(stage), "five actual Player HitArea hits remove wall cells and collision")
	stage.player.global_position = Vector3(37,1,13)
	for step in 50:
		stage.player.move_and_collide(Vector3(0.16,0,0))
		await physics_frame
	check(stage.player.global_position.x > 42, "Player physically crosses opened secret wall")
	var notebook = stage.get_node("B1_5/PrisonNotebook")
	stage.player.global_position = notebook.global_position + Vector3(0,0.1,0.8)
	stage.camera_rig.snap_to_target()
	await ticks(10)
	await tap_f()
	check(stage.get_node("BasementStory")._active == "prison_notebook", "real F reads prisoner67 notebook")
	dialogue.Text.skip_text_reveal()
	await ticks(35)
	await capture("secret-notebook")
	await finish_dialogue()
	await ticks(8)
	await tap_f()
	check(stage.get_node("BasementStory").busy, "notebook can be read again")
	await finish_dialogue()
	var secret = stage.get_node("B1_5/SecretChest")
	check(secret.chest_id == "basement_b1_secret" and not secret.guaranteed_weapon, "secret chest has independent loot identity")
	stage.player.global_position = secret.global_position + Vector3(0,0.1,0.6)
	await ticks(10)
	await tap_f()
	await ticks(160)
	var state: Dictionary = manager.flags.get("chest_loot:basement_b1_secret", {})
	check(state.get("items",[]).size() in [1,2] and state.get("claimed",[]).size() == state.get("items",[]).size()+10, "F secret chest awards its own1–2 items and10EXP pickups")
	check(manager.player_level == 3 and manager.experience == 150 and manager.skill_points == 6, "both chests award400EXP total with SP only from levels")

func _boss() -> void:
	var stage = current_scene
	stage.player.set_physics_process(false)
	var boss = stage.get_node("B3/Enemies/DarkFairy")
	stage.player.global_position = boss.global_position + Vector3(0,0,5)
	await ticks(5)
	var story = stage.get_node("BasementStory")
	check(story.busy and story._active == "dark_fairy_intro" and boss.state == &"boss_intro", "first encounter starts requested Dark Fairy dialogue before fight")
	dialogue.Text.skip_text_reveal()
	await ticks(90)
	await capture("dark-fairy-intro")
	await finish_dialogue()
	await ticks(120)
	check(manager.flags.get("story_dark_fairy_intro",false) and not paused and boss.state != &"boss_intro", "intro cinematic finishes and releases fight")
	boss.set_physics_process(false)
	boss.phase = 2
	boss.invincible = false
	boss.state = &"idle"
	boss.shield_hits = 0
	boss._on_hurt_area_3d_hurt(Vector3.RIGHT, 999)
	await ticks(5)
	check(story.busy and story._active == "dark_fairy_defeat" and not manager.flags.get("b3_split_cleared",false), "terminal defeat dialogue precedes disappearance/clear")
	await finish_dialogue()
	await ticks(150)
	check(manager.flags.get("story_dark_fairy_defeat",false) and manager.flags.get("b3_split_cleared",false) and not is_instance_valid(boss) and not paused, "defeat cinematic despawns boss, persists clear and releases world")

func _camera_views(stage: Node3D) -> void:
	for mode in [0,1,2]:
		stage.camera_rig.set_view_mode(mode)
		stage.camera_rig.snap_to_target()
		await ticks(3)
		var story = stage.get_node("BasementStory")
		story.play_event("b1_clear")
		await ticks(3)
		for step in 40:
			if story._camera_tween != null and story._camera_tween.is_running():
				break
			if dialogue.current_state == 1:
				dialogue.Text.skip_text_reveal()
			elif dialogue.current_state == 0:
				dialogue.handle_next_event()
			await ticks(2)
		await ticks(45)
		check(stage.camera_rig.camera.fov < 50, "ladder focus works from view" + str(mode))
		await finish_dialogue()
		check(stage.camera_rig.view_mode == mode and not stage.player.is_talking and stage.camera_rig.process_mode == Node.PROCESS_MODE_ALWAYS, "view/control restored for view" + str(mode))
	stage.camera_rig.set_view_mode(0)
	stage.camera_rig.snap_to_target()

func _teardown() -> void:
	var story = current_scene.get_node("BasementStory")
	story.play_event("prison_notebook")
	await ticks(3)
	manager.change_stage(B1)
	await scene_changed
	await ticks(8)
	check(dialogue.current_timeline == null and not current_scene.player.is_talking and current_scene.process_mode != Node.PROCESS_MODE_DISABLED and current_scene.camera_rig.process_mode == Node.PROCESS_MODE_ALWAYS, "scene transition during story releases dialogue, world and camera")
