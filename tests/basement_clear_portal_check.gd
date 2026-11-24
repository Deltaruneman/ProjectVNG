extends SceneTree

## Run against a disposable project with a custom user directory:
## godot --path <copy> --script res://tests/basement_clear_portal_check.gd -- --isolated-copy

const B1 := "res://levels/level_1/basement_b1.tscn"
const B2 := "res://levels/level_1/basement_b2.tscn"
const B3 := "res://levels/level_1/basement_b3.tscn"
const GARDEN := "res://levels/level_1/garden.tscn"

var _checks := 0
var _failures := 0


func _initialize() -> void:
	_run.call_deferred()
	_watchdog.call_deferred()

func _watchdog() -> void:
	await create_timer(180.0).timeout
	push_error("Garden / basement fixture timed out.")
	quit(1)


func _check(ok: bool, label: String) -> void:
	_checks += 1
	print("PASS " if ok else "FAIL ", label)
	if not ok:
		_failures += 1


func _ticks(count: int = 5) -> void:
	for frame in range(count):
		await physics_frame


func _tap_f() -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = KEY_F
		event.physical_keycode = KEY_F
		event.pressed = pressed
		root.push_input(event)
		await _ticks(2)


func _check_transition(stage: Node3D, exit: Node3D, destination: String) -> bool:
	var area := exit.get_node("InteractiveArea3D") as Area3D
	stage.player.global_position = area.global_position - Vector3.UP
	await _ticks()
	_check(area.overlaps_body(stage.player) and stage.player.can_interact(), "exit interaction is available")
	await _tap_f()
	for frame in range(90):
		if not is_instance_valid(stage):
			break
		await physics_frame
	var arrived := current_scene != null and current_scene.scene_file_path == destination
	_check(arrived, "F advances to " + destination)
	return arrived


func _living_roster(floor_node: Node3D) -> Array[Node]:
	return floor_node.get_node("Enemies").get_children().filter(
		func(node: Node) -> bool: return node is CharacterBody3D
	)


func _has_floor(world: World3D, at: Vector3) -> bool:
	var query := PhysicsRayQueryParameters3D.create(at + Vector3.UP * 0.4, at - Vector3.UP, 1)
	return not world.direct_space_state.intersect_ray(query).is_empty()


func _run() -> void:
	var custom := str(ProjectSettings.get_setting("application/config/custom_user_dir_name", ""))
	var uses_custom := bool(ProjectSettings.get_setting("application/config/use_custom_user_dir", false))
	if not uses_custom or not custom.begins_with("ArcanaPlacement-") or not "--isolated-copy" in OS.get_cmdline_user_args():
		push_error("Use a disposable project with custom user directory ArcanaPlacement-<unique>.")
		quit(1)
		return
	var manager := root.get_node("GameManager")
	manager.reset()
	await _partial_revisit(manager)
	manager.reset()
	manager.change_stage(B1)
	await scene_changed

	for index in range(3):
		var stage := current_scene as Node3D
		var floor_node := stage.get_node("B%d" % (index + 1)) as Node3D
		var floor_label := str(floor_node.name)
		var portal := floor_node.get_node_or_null("ClearPortal") as Node3D
		var enemies := _living_roster(floor_node)
		var arrival: Vector3 = stage.player.global_position
		stage.player.set_physics_process(false)
		for enemy in enemies:
			enemy.set_physics_process(false)
		_check(enemies.size() == [8, 5, 1][index], floor_label + " authored enemy count")
		await _ticks()
		var world := stage.get_world_3d()
		_check(_has_floor(world, arrival), floor_label + " arrival has floor support")
		for enemy in enemies:
			_check(_has_floor(world, enemy.global_position), floor_label + " floor under " + str(enemy.name))
		var area: Area3D
		var exit := portal
		if index < 2:
			area = portal.get_node("InteractiveArea3D") as Area3D
			_check(not portal.visible and not area.monitoring, floor_label + " portal hidden and inactive")
		else:
			exit = floor_node.get_node("Door_b3_exit") as Node3D
			_check(portal == null and exit.transition_enabled and exit.target_stage == GARDEN
				and exit.is_locked(), "B3 garden exit is boss-gated")
		_check(_has_floor(world, exit.global_position), floor_label + " exit has floor support")
		stage.player.global_position = exit.global_position + Vector3.UP * 0.2
		await _ticks()
		await _tap_f()
		_check(current_scene == stage, floor_label + " early F cannot advance")
		manager._end_dialogue()
		await _ticks()
		stage.player.global_position = arrival

		for enemy_index in range(enemies.size()):
			var enemy := enemies[enemy_index]
			var hurt := enemy.get_node("Direction/HurtArea3D")
			hurt.emit_signal("hurt", Vector3.FORWARD, 999.0)
			if index == 2:
				for frame in range(180):
					if enemy.phase == 2:
						break
					await physics_frame
				_check(enemy.phase == 2 and not manager.is_door_unlocked("b3_split_cleared"),
					"Dark Fairy phase change does not clear B3")
				hurt.emit_signal("hurt", Vector3.FORWARD, 999.0)
			for frame in range(300):
				if not is_instance_valid(enemy):
					break
				await physics_frame
			_check(not is_instance_valid(enemy), floor_label + " death cleanup %d" % (enemy_index + 1))
			if enemy_index < enemies.size() - 1:
				_check(not portal.visible and not area.monitoring, floor_label + " partial clear stays closed")
		await _ticks()
		if index == 2:
			_check(manager.is_door_unlocked("b3_split_cleared") and _living_roster(floor_node).is_empty(),
				"Dark Fairy defeat records B3 clear")
			_check(not exit.is_locked(), "B3 exit unlocks after final defeat")
			if await _check_transition(stage, exit, GARDEN):
				await _garden_check(manager)
				stage = current_scene as Node3D
				stage.player.set_physics_process(false)
				await _check_transition(stage, stage.get_node("Transitions/Door_from_basement"), B3)
				await _ticks()
				_check(_living_roster(current_scene.get_node("B3")).is_empty(), "garden return never revives Dark Fairy")
			break
		_check(portal.visible and area.monitoring and _living_roster(floor_node).is_empty(),
			floor_label + " last defeat opens portal")
		if index == 1:
			_check(manager.is_door_unlocked("b2_cleared"), "B2 satisfies the existing B3 gate")
		if not await _check_transition(stage, portal, [B2, B3][index]):
			_finish()
			return

	manager.flags.clear()
	manager.load_game()
	for flag in ["b1_split_cleared", "b2_split_cleared", "b2_cleared", "b3_split_cleared"]:
		_check(manager.is_door_unlocked(flag), "saved clear flag " + flag)
	for index in range(3):
		manager.change_stage([B1, B2, B3][index])
		await scene_changed
		await _ticks()
		var floor_node := current_scene.get_node("B%d" % (index + 1)) as Node3D
		_check(_living_roster(floor_node).is_empty(), str(floor_node.name) + " stays cleared when revisited")
		if index < 2:
			_check(floor_node.get_node("ClearPortal").visible, str(floor_node.name) + " portal stays open")
	var stage := current_scene as Node3D
	stage.player.set_physics_process(false)
	if await _check_transition(stage, stage.get_node("B3/Door_b3_down"), B2):
		stage = current_scene as Node3D
		stage.player.set_physics_process(false)
		await _check_transition(stage, stage.get_node("B2/Door_b2_down"), B1)
	_finish()


func _finish() -> void:
	print("TOTAL ", _checks - _failures, "/", _checks)
	quit(int(_failures > 0))

func _partial_revisit(manager: Node) -> void:
	manager.change_stage(B2)
	await scene_changed
	await _ticks()
	var stage := current_scene as Node3D
	stage.player.set_physics_process(false)
	var enemies := _living_roster(stage.get_node("B2"))
	var boss: Node
	for enemy in enemies:
		enemy.set_physics_process(false)
		if enemy.get("kind") == "executioner":
			boss = enemy
	_check(boss != null, "partial revisit fixture finds executioner")
	if boss == null:
		return
	var boss_name := str(boss.name)
	boss.get_node("Direction/HurtArea3D").emit_signal("hurt", Vector3.FORWARD, 999.0)
	_check(manager.flags.get("encounter_defeated:b2_split_cleared:" + boss_name, false),
		"boss defeat saved before death animation finishes")
	_check(not manager.is_door_unlocked("b2_split_cleared"), "boss alone does not clear remaining enemies")
	manager.change_stage(B1)
	await scene_changed
	await _ticks()
	manager.flags.clear()
	manager.load_game()
	manager.change_stage(B2)
	await scene_changed
	await _ticks()
	stage = current_scene as Node3D
	stage.player.set_physics_process(false)
	enemies = _living_roster(stage.get_node("B2"))
	_check(enemies.size() == 4 and not stage.has_node("B2/Enemies/" + boss_name), "partial clear survives reverse trip and save reload")
	_check(not stage.get_node("B2/ClearPortal").visible, "partial revisit keeps forward portal closed")
	var ordinary := enemies[0]
	var ordinary_name := str(ordinary.name)
	ordinary.get_node("Direction/HurtArea3D").emit_signal("hurt", Vector3.FORWARD, 999.0)
	for frame in range(300):
		if not is_instance_valid(ordinary):
			break
		await physics_frame
	manager.change_stage(B1)
	await scene_changed
	manager.change_stage(B2)
	await scene_changed
	await _ticks()
	_check(_living_roster(current_scene.get_node("B2")).size() == 3
		and not current_scene.has_node("B2/Enemies/" + ordinary_name), "ordinary defeat persists; living enemies aren't falsely cleared")

func _inside_view(control: Control) -> bool:
	return root.get_visible_rect().grow(1).encloses(control.get_global_rect())

func _dialogue_choices() -> void:
	var dialogic := root.get_node("Dialogic")
	for frame in range(120):
		if dialogic.current_state == 3:
			await _ticks(35)
			return
		if dialogic.current_state == 1:
			dialogic.Text.skip_text_reveal()
		elif dialogic.current_state == 0:
			dialogic.handle_next_event()
		await _ticks(2)
	_check(false, "Dialogic reaches choices before timeout")

func _garden_check(manager: Node) -> void:
	var stage := current_scene as Node3D
	stage.player.set_physics_process(false)
	await _ticks()
	var farm := stage.get_node("Farm")
	var dialogic := root.get_node("Dialogic")
	_check(farm.plots.size() == 32, "eight expanded beds contain32 independent cells")
	for plot in farm.plots:
		_check(_has_floor(stage.get_world_3d(), plot.global_position) and not plot.has_node("Label"), "supported cell without number " + str(plot.name))
	# Existing crop stays at first cell; extra cells have separate IDs.
	farm.data.plots["garden/Plot_01"] = {"crop": "pineapple", "planted_at": 123.0}
	farm._save()
	manager.skill_points = 4
	stage.player.global_position = farm.get_node("SeedMerchant").global_position + Vector3(0, 0.2, 1)
	await _ticks()
	var mouse_before := Input.mouse_mode
	await _tap_f()
	await _dialogue_choices()
	_check(farm.talking and not farm.opened and stage.player.is_talking and dialogic.current_timeline != null, "F opens real Dialogic, no greeting panel")
	var expected := ["Bắt chuyện", "Mua bán", "Rời đi"]
	for index in range(3):
		var button: Button = dialogic.Choices.get_choice_button(index + 1)
		_check(button != null and button.text == expected[index], "Dialogic choice " + expected[index])
	for resolution in [Vector2i(480,270), Vector2i(1280,720), Vector2i(800,800), Vector2i(540,960)]:
		root.size = resolution
		await _ticks(8)
		var text_panel := dialogic.Styles.get_layout_node().find_child("Panel", true, false) as Control
		_check(_inside_view(text_panel), "NPC Dialogic textbox fits " + str(resolution))
		for index in range(3):
			_check(_inside_view(dialogic.Choices.get_choice_button(index+1)), "NPC choice fits " + str(resolution))
		if resolution == Vector2i(1280,720):
			await process_frame
			root.get_texture().get_image().save_png("user://garden-dialogic-npc.png")
	root.size = Vector2i(1280,720)
	await _check_speaker_portrait(dialogic, "mushroom", "npc-portrait")
	dialogic.Choices.select_choice(1)
	await _ticks(35)
	dialogic.Text.skip_text_reveal()
	await _check_speaker_portrait(dialogic, "foxy", "player-portrait")
	await _ticks(6)
	await _dialogue_choices()
	_check(farm.talking and not farm.opened, "chat returns to Dialogic greeting")
	dialogic.Choices.select_choice(2)
	await _ticks(12)
	_check(farm.opened and farm.shop_mode and not farm.talking and dialogic.current_timeline == null and stage.player.is_talking, "Dialogic trade opens shop with Player locked")
	for index in range(4):
		farm.choices.get_child(index).pressed.emit()
	_check(manager.skill_points == 0 and int(manager.flags.get("farm_seed_spent",0)) == 4, "four purchases cost4SP")
	farm._choose(0)
	_check(int(farm.data.seeds.broccoli) == 1, "insufficient SP rejected")
	farm._back()
	await _ticks(6)
	await _dialogue_choices()
	_check(farm.talking and not farm.opened, "shop back returns to Dialogic")
	dialogic.Choices.select_choice(3)
	await _ticks(8)
	_check(not stage.player.is_talking and not farm.talking and Input.mouse_mode == mouse_before, "Dialogic leave releases Player and mouse")
	var plot: Node3D = farm.plots[1]
	stage.player.global_position = plot.global_position + Vector3(0,0.2,0)
	await _ticks()
	await _tap_f()
	_check(farm.opened and not farm.shop_mode and farm.target_plot == plot, "F selects nearest small cell")
	farm.choices.get_child(0).pressed.emit()
	var key: String = farm._plot_key(plot)
	_check(farm.data.plots.has(key) and farm.data.plots["garden/Plot_01"].planted_at == 123.0, "new cell plants independently without replacing old crop")
	farm._harvest(plot)
	_check(int(farm.data.produce.get("broccoli",0)) == 0, "early harvest rejected")
	farm.data.plots[key].planted_at = Time.get_unix_time_from_system() - 91
	farm._save()
	manager.change_stage(B3,"b3_exit")
	await scene_changed
	manager.flags.clear()
	manager.load_game()
	manager.change_stage(GARDEN,"garden_from_basement")
	await scene_changed
	await _ticks()
	stage = current_scene as Node3D
	stage.player.set_physics_process(false)
	farm = stage.get_node("Farm")
	_check(farm.data.plots.has(key) and farm.data.plots["garden/Plot_01"].planted_at == 123.0, "old and subdivided crops survive actual save reload")
	plot = farm.plots[1]
	farm._harvest(plot)
	farm._harvest(plot)
	_check(int(farm.data.produce.get("broccoli",0)) == 1 and farm.data.plots.has("garden/Plot_01"), "small cell harvest exactly once preserves neighbor")
	# Overhead rendered evidence of actual soil layout and markers.
	var camera := Camera3D.new()
	stage.add_child(camera)
	camera.global_position = Vector3(32,48,38)
	camera.look_at(Vector3(32,1,27))
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 36
	camera.make_current()
	await _ticks(6)
	root.get_texture().get_image().save_png("user://garden-cells.png")
	camera.queue_free()
	stage.camera_rig.get_node("Camera3D").make_current()
	stage.camera_rig.snap_to_target()
	# Cancellation and teardown must release state, not open a stale shop.
	farm._open(null)
	await _ticks(6)
	var cancel := InputEventAction.new()
	cancel.action = "ui_cancel"
	cancel.pressed = true
	root.push_input(cancel)
	await _ticks(8)
	_check(not farm.talking and not stage.player.is_talking, "Escape cancels NPC dialogue")
	farm._open(null)
	await _dialogue_choices()
	dialogic.Choices.select_choice(3)
	await _ticks(6)


func _check_speaker_portrait(dialogic: Node, character_name: String, capture: String) -> void:
	await _ticks(90)
	var character := load("res://dialog/characters/" + character_name + ".dch")
	var portrait: Node = null
	for container in get_nodes_in_group("dialogic_portrait_con_speaker"):
		for holder in container.get_children():
			if holder.get_meta("character", null) == character:
				portrait = holder.get_child(-1) if holder.get_child_count() > 0 else null
	_check(portrait != null, character_name + " has a Dialogic speaker portrait")
	if portrait != null:
		var sprite := portrait.get_node("Portrait") as Sprite2D
		_check(sprite != null and sprite.texture != null and sprite.is_visible_in_tree()
			and sprite.texture is AtlasTexture and sprite.texture.resource_path == "res://dialog/portraits/" + character_name + ".tres",
			character_name + " renders its correct nonempty atlas image")
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("user://" + capture + ".png")
