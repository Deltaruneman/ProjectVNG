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
	await _tap_key(KEY_F)


func _tap_key(code: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
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
	if not uses_custom or not (custom.begins_with("ArcanaPlacement-") or custom.begins_with("ArcanaStory-")) or not "--isolated-copy" in OS.get_cmdline_user_args():
		push_error("Use a disposable project with custom user directory ArcanaPlacement-<unique>.")
		quit(1)
		return
	var manager := root.get_node("GameManager")
	if "--brew-only" in OS.get_cmdline_user_args():
		await _brew_check(manager)
		_finish()
		return
	if "--brew-continue" in OS.get_cmdline_user_args():
		await _brew_continue_check(manager)
		_finish()
		return
	manager.reset()
	for story_flag in ["story_possession", "story_b1_clear", "story_dark_fairy_intro", "story_dark_fairy_defeat"]:
		manager.flags[story_flag] = true
	await _partial_revisit(manager)
	manager.reset()
	for story_flag in ["story_possession", "story_b1_clear", "story_dark_fairy_intro", "story_dark_fairy_defeat"]:
		manager.flags[story_flag] = true
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
		if index == 1:
			_check(floor_node.get_node("ClearPortal")._locked_interaction == null, "cleared B2 revisit never creates orphan locked interaction")
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

func _brew_check(manager: Node) -> void:
	var saves := root.get_node("SaveSystem")
	saves.delete_save()
	manager.reset()
	manager.change_stage(GARDEN)
	await scene_changed
	var stage := current_scene as Node3D
	var player: Node = stage.player
	player.set_physics_process(false)
	var farm := stage.get_node("Farm")
	var dialogic := root.get_node("Dialogic")
	var inventory := root.get_node("InventoryMenu")
	player.global_position = stage.get_node("Transitions/Checkpoint_garden").global_position
	await _ticks(10)
	_check(manager.checkpoint_id == "garden_start", "Garden checkpoint activated by overlap")
	manager.skill_points = 5
	player.global_position = farm.get_node("SeedMerchant").global_position + Vector3(0, 0.2, 1)
	await _ticks()
	var mouse_before := Input.mouse_mode
	await _tap_f()
	await _dialogue_choices()
	dialogic.Choices.select_choice(2)
	await _ticks(12)
	_check(farm.opened and farm.menu_page == "shop", "actual merchant Mua bán opens the shared panel")
	for index in [1, 3, 1, 3, 1]:
		farm.choices.get_child(index).pressed.emit()
	_check(manager.skill_points == 0 and int(farm.data.seeds.cucumber) == 3
		and int(farm.data.seeds.pineapple) == 2, "buy cucumber and pineapple seeds for five SP")
	await _tap_key(KEY_ESCAPE)
	await _dialogue_choices()
	_check(dialogic.Choices.get_choice_button(3).text == "Điều chế Thuốc", "Brew choice is next to trade")
	dialogic.Choices.select_choice(3)
	await _ticks(12)
	_check(farm.opened and farm.menu_page == "brew" and player.is_talking
		and not player.movement_enabled and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE
		and dialogic.current_timeline == null, "Dialogic hands control directly to Brew")
	var cook: Button = farm.choices.get_child(1)
	_check(cook.disabled and farm.close_button.has_focus(), "seeds alone cannot pay and close has focus")
	cook.pressed.emit()
	_check(_potion_uid(manager) == "", "confirmation rechecks ingredients even if invoked while disabled")
	await _tap_key(KEY_ESCAPE)
	_check(not farm.opened and player.can_interact() and player.movement_enabled
		and Input.mouse_mode == mouse_before, "Esc closes Brew and restores gameplay input")

	var crops := ["cucumber", "pineapple", "cucumber", "pineapple", "cucumber"]
	for index in crops.size():
		var plot: Node3D = farm.plots[index]
		player.global_position = plot.global_position + Vector3.UP * 0.2
		await _tap_f()
		farm.choices.get_child(1 if crops[index] == "cucumber" else 3).pressed.emit()
		var key: String = farm._plot_key(plot)
		_check(farm.data.plots.get(key, {}).get("crop") == crops[index], "plant " + crops[index] + " at " + key)
		# Move fixture timestamps past the production 90-second wait.
		farm.data.plots[key].planted_at = Time.get_unix_time_from_system() - 91.0
		if index < 4:
			await _tap_f()
	_check(_brew_stock(farm, 2, 2), "harvest two of each crop before Brew")
	await _tap_key(KEY_B)
	_find_button(inventory._tabs, "Vật phẩm").pressed.emit()
	var grid: Node = inventory._list.get_node("FarmProduce")
	_check(inventory.is_open and grid.get_node("Farm_produce_cucumber/Count").text == "2"
		and grid.get_node("Farm_produce_pineapple/Count").text == "2", "B Vật phẩm shows the same harvested counts")
	await _tap_key(KEY_ESCAPE)
	# Closing Inventory releases the pause after two process frames, even when
	# several physics steps run within one rendered frame.
	for frame in range(3):
		await process_frame
	_check(not inventory.is_open and not paused, "closing Inventory restores gameplay before merchant interaction")
	player.global_position = farm.get_node("SeedMerchant").global_position + Vector3(0, 0.2, 1)
	await _tap_f()
	await _dialogue_choices()
	dialogic.Choices.select_choice(3)
	await _ticks(12)
	cook = farm.choices.get_child(1)
	var ingredients: Label = farm.choices.get_child(0)
	_check(not cook.disabled and cook.has_focus() and ingredients.text.contains("Dưa leo · 2 / 1")
		and ingredients.text.contains("Dứa · 2 / 1"), "Brew shows required and owned crops and focuses confirm")
	_check(cook.icon is AtlasTexture and cook.icon.region == Rect2(0, 0, 32, 32)
		and cook.text.contains("Nhận 1 Bình hồi phục"), "Brew shows one potion and the 32×32 frame")
	await _tap_key(KEY_DOWN)
	_check(farm.close_button.has_focus(), "Down navigates from Brew to close")
	await _tap_key(KEY_UP)
	_check(cook.has_focus(), "Up returns focus to Brew confirmation")
	await _capture_brew("brew-panel")
	await _tap_f()
	ingredients = farm.choices.get_child(0)
	_check(_brew_stock(farm, 1, 1) and ingredients.text.contains("Dưa leo · 1 / 1"), "F brews and immediately refreshes counts")
	cook = farm.choices.get_child(1)
	cook.pressed.emit()
	cook.pressed.emit()
	var disk: Dictionary = saves.load_data()
	var potion_uid := _potion_uid(manager)
	_check(_brew_stock(farm, 0, 0) and int(disk.flags.garden_farm_v1.produce.cucumber) == 0
		and int(disk.flags.garden_farm_v1.produce.pineapple) == 0
		and int(disk.inventory.items[potion_uid].count) == 2, "rapid confirms stop at two and disk contains both sides of exchange")
	_check(farm.choices.get_child(1).disabled, "button disables immediately when depleted")
	farm.close_button.pressed.emit()
	_check(player.can_interact(), "Brew close button returns directly to gameplay")
	player.global_position = farm.plots[4].global_position + Vector3.UP * 0.2
	await _tap_f()
	disk = saves.load_data()
	_check(_brew_stock(farm, 1, 0) and int(disk.flags.garden_farm_v1.produce.cucumber) == 1
		and int(disk.flags.garden_farm_v1.produce.pineapple) == 0, "next harvest adds to the post-Brew counts")
	player.global_position = farm.get_node("SeedMerchant").global_position + Vector3(0, 0.2, 1)
	await _tap_f()
	await _dialogue_choices()
	dialogic.Choices.select_choice(3)
	await _ticks(12)
	_check(farm.choices.get_child(1).disabled, "one harvested ingredient without the other keeps Brew disabled")
	await _tap_key(KEY_ESCAPE)

	await _tap_key(KEY_B)
	_find_button(inventory._tabs, "Tiêu hao").pressed.emit()
	inventory._list.get_node("InventoryGrid").get_child(0).pressed.emit()
	var assign := _find_button(inventory._detail, "Gán vào ô Q")
	_check(assign != null, "B Tiêu hao shows the potion and Q quick-slot assignment")
	assign.pressed.emit()
	await _tap_key(KEY_ESCAPE)
	for frame in range(3):
		await process_frame
	_check(manager.inventory.equipped.consumable == potion_uid, "assignment stored in the existing consumable slot")
	var icon := stage.find_child("HealingPotionFeedback", true, false).get_node("Icon") as TextureRect
	player.health = player.max_health - 2
	await _tap_key(KEY_2)
	_check(player.selected_active_slot == 2 and player.health < player.max_health
		and int(manager.inventory.items[potion_uid].count) == 2, "physical 2 selects skill 2 without spending potion")
	await _tap_key(KEY_Q)
	_check(player.health == player.max_health and int(manager.inventory.items[potion_uid].count) == 1,
		"physical Q heals to full and spends exactly one potion")
	_check(icon.is_visible_in_tree() and _inside_view(icon)
		and icon.get_global_rect().position.x > root.get_visible_rect().size.x * 0.8, "HUD shows the potion icon at the top right")
	await _capture_brew("brew-used")
	await create_timer(1.05).timeout
	_check(not icon.visible, "HUD icon hides after about one second")
	await _tap_key(KEY_Q)
	_check(int(manager.inventory.items[potion_uid].count) == 1 and not icon.visible, "Q at full HP spends nothing and shows no feedback")


func _brew_continue_check(manager: Node) -> void:
	# GameManager has already read the direct Garden run's save at startup.
	change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	await scene_changed
	for frame in range(90):
		if current_scene != null and current_scene.scene_file_path == GARDEN:
			break
		await physics_frame
	var continued := current_scene != null and current_scene.scene_file_path == GARDEN
	_check(continued and manager.checkpoint_id == "garden_start", "normal main-scene boot continues at Garden checkpoint")
	if not continued:
		return
	var uid := _potion_uid(manager)
	_check(uid != "" and manager.inventory.equipped.consumable == uid
		and int(manager.inventory.items[uid].count) == 1, "Continue retains assignment and post-use stack")
	_check(_brew_stock(current_scene.get_node("Farm"), 1, 0), "Continue retains post-Brew harvest counts")
	var saves := root.get_node("SaveSystem")
	saves.save_path = "user://legacy-brew-fixture.json"
	var legacy := {"inventory": {"items": {"item_12": {"definition": "healing_potion", "count": 3}}, "equipped": {}}}
	saves.save_data(legacy)
	manager.load_game()
	_check(_potion_uid(manager) == "item_12" and manager.inventory.equipped.consumable == ""
		and int(manager.inventory.items.item_12.count) == 3, "old v1 potion stack without quick assignment loads")
	legacy.inventory.equipped.consumable = "item_12"
	saves.save_data(legacy)
	manager.load_game()
	_check(manager.inventory.equipped.consumable == "item_12" and int(manager.inventory.items.item_12.count) == 3,
		"old v1 quick assignment loads")
	var player: Node = current_scene.player
	player.health = player.max_health - 1
	await _tap_key(KEY_Q)
	_check(player.health == player.max_health and int(manager.inventory.items.item_12.count) == 2,
		"Q uses the potion from a legacy equipped stack")


func _brew_stock(farm: Node, cucumber: int, pineapple: int) -> bool:
	return int(farm.data.produce.get("cucumber", 0)) == cucumber and int(farm.data.produce.get("pineapple", 0)) == pineapple


func _potion_uid(manager: Node) -> String:
	for uid: String in manager.inventory.items:
		if manager.inventory.items[uid].definition == "healing_potion":
			return uid
	return ""


func _find_button(node: Node, text: String) -> Button:
	for child in node.get_children():
		if child is Button and child.text == text:
			return child
	return null


func _capture_brew(file_name: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("user://" + file_name + ".png")



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
	var expected := ["Bắt chuyện", "Mua bán", "Điều chế Thuốc", "Rời đi"]
	for index in expected.size():
		var button: Button = dialogic.Choices.get_choice_button(index + 1)
		_check(button != null and button.text == expected[index], "Dialogic choice " + expected[index])
	for resolution in [Vector2i(480,270), Vector2i(1280,720), Vector2i(800,800), Vector2i(540,960)]:
		root.size = resolution
		await _ticks(8)
		var text_panel := dialogic.Styles.get_layout_node().find_child("Panel", true, false) as Control
		_check(_inside_view(text_panel), "NPC Dialogic textbox fits " + str(resolution))
		for index in expected.size():
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
	_check(farm.opened and farm.menu_page == "shop" and not farm.talking and dialogic.current_timeline == null and stage.player.is_talking, "Dialogic trade opens shop with Player locked")
	for index in range(4):
		farm.choices.get_child(index).pressed.emit()
	_check(manager.skill_points == 0 and int(manager.flags.get("farm_seed_spent",0)) == 4, "four purchases cost4SP")
	farm._choose(0)
	_check(int(farm.data.seeds.broccoli) == 1, "insufficient SP rejected")
	farm._back()
	await _ticks(6)
	await _dialogue_choices()
	_check(farm.talking and not farm.opened, "shop back returns to Dialogic")
	dialogic.Choices.select_choice(4)
	await _ticks(8)
	_check(not stage.player.is_talking and not farm.talking and Input.mouse_mode == mouse_before, "Dialogic leave releases Player and mouse")
	var plot: Node3D = farm.plots[1]
	stage.player.global_position = plot.global_position + Vector3(0,0.2,0)
	await _ticks()
	await _tap_f()
	_check(farm.opened and farm.menu_page == "plant" and farm.target_plot == plot, "F selects nearest small cell")
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
	dialogic.Choices.select_choice(4)
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
