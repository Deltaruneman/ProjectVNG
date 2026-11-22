extends SceneTree

## Run against a disposable project with a custom user directory:
## godot --path <copy> --script res://tests/basement_clear_portal_check.gd -- --isolated-copy

const B1 := "res://levels/level_1/basement_b1.tscn"
const B2 := "res://levels/level_1/basement_b2.tscn"
const B3 := "res://levels/level_1/basement_b3.tscn"

var _checks := 0
var _failures := 0


func _initialize() -> void:
	_run.call_deferred()


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
			_check(portal == null and not exit.transition_enabled and exit.target_stage.is_empty()
				and not exit.has_node("InteractiveArea3D"), "B3 original exit is inactive and has no successor")
		_check(_has_floor(world, exit.global_position), floor_label + " exit has floor support")
		stage.player.global_position = exit.global_position + Vector3.UP * 0.2
		await _ticks()
		await _tap_f()
		_check(current_scene == stage, floor_label + " early F cannot advance")
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
			stage.player.global_position = exit.global_position + Vector3.UP * 0.2
			await _ticks()
			await _tap_f()
			_check(current_scene == stage and not floor_node.has_node("ClearPortal"),
				"F at the original B3 exit stays in B3 after clear")
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
