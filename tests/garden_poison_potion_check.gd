extends "res://tests/garden_combat_potions_check.gd"
## Exercises the actual merchant, Castle, physics queries and Castle EnemyZones.

const CASTLE := "res://levels/level_1/castle.tscn"
const VENOM := "venom_potion"
const EFFECTS := "PoisonPotionEffects"
const FLOOR_START := Vector3(34, 1.03, 40)
const WAVE_START := Vector3(20, 9.03, 18)

var venom_uid: String
var effects: Node
var camera: Camera3D
var accepted := 0


func _run() -> void:
	var custom := str(ProjectSettings.get_setting("application/config/custom_user_dir_name", ""))
	if not ProjectSettings.get_setting("application/config/use_custom_user_dir", false) \
		or not custom.begins_with("ArcanaPlacement-") or not "--isolated-copy" in OS.get_cmdline_user_args():
		push_error("Use a disposable project with a dedicated ArcanaPlacement- user directory.")
		quit(2)
		return
	manager = root.get_node("GameManager")
	root.get_node("SaveSystem").delete_save()
	manager.reset()
	manager.skill_allocations["char_health"] = 2
	manager.change_stage(GARDEN)
	await scene_changed
	await _bind_garden_player()
	await _brew_venom()
	venom_uid = _find_item(VENOM)
	await _assign(VENOM, venom_uid)
	if not await _check_transition(stage, stage.get_node("Transitions/Door_to_castle"), CASTLE):
		_finish()
		return
	await _bind_castle()
	var trap_pair := await _throw_and_merge()
	if trap_pair.size() != 2:
		_finish()
		return
	await _check_exposure(trap_pair)
	await _check_geometry()
	await _check_enemy_filter()
	await _death_and_wave_reset()
	_finish()


func _brew_venom() -> void:
	var farm := stage.get_node("Farm")
	farm.data.produce = {"cucumber": 14, "spinach": 14}
	player.global_position = farm.get_node("SeedMerchant").global_position + Vector3(0, 0.2, 1)
	await _tap_f()
	await _dialogue_choices()
	root.get_node("Dialogic").Choices.select_choice(3)
	await _ticks(10)
	var brew := farm.choices.get_node(VENOM) as Button
	_check(_frame_matches(brew, "venom_potion.png") and not brew.disabled, "actual Garden Brew shows the venom recipe and 32×32 frame")
	for attempt in range(15):
		brew.pressed.emit()
	var disk: Dictionary = root.get_node("SaveSystem").load_data()
	var uid := _find_item(VENOM)
	_check(brew.disabled and farm.data.produce == {"cucumber": 0, "spinach": 0} and _count(uid) == 14,
		"each Brew trades one cucumber and spinach and rejects the attempt after depletion")
	_check(int(disk.flags.garden_farm_v1.produce.spinach) == 0 and int(disk.inventory.items[uid].count) == 14,
		"Brew persists produce and venom together")
	await _tap_key(KEY_ESCAPE)


func _bind_castle() -> void:
	await _bind_garden_player()
	for zone in _enemy_zones():
		zone.get_node("Timer").stop()
	camera = Camera3D.new()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 7
	stage.add_child(camera)
	camera.make_current()
	effects = stage.get_node_or_null(EFFECTS)


func _aim(feet: Vector3, forward: Vector3) -> void:
	player.global_position = feet
	camera.global_position = feet - forward * 5.0 + Vector3.UP * 6.0
	camera.look_at(feet + forward, Vector3.UP)
	await _ticks(2)


func _throw_q() -> RefCounted:
	var count := _count(venom_uid)
	await _tap_key(KEY_Q)
	effects = stage.get_node_or_null(EFFECTS)
	var success: bool = effects != null and not effects.flights.is_empty() and _count(venom_uid) == count - 1
	_check(success, "Q accepts the throw and spends exactly one bottle")
	if not success:
		return null
	accepted += 1
	return effects.flights.back()


func _wait_impact() -> void:
	for frame in range(70):
		if effects.flights.is_empty():
			return
		await physics_frame
	_check(false, "all flights should have resolved before the timeout")


func _throw_and_merge() -> Array:
	await _aim(FLOOR_START, Vector3.RIGHT)
	var weapon: String = manager.inventory.equipped.main
	await _tap_key(KEY_2)
	_check(player.selected_active_slot == 2 and _count(venom_uid) == 14
		and manager.inventory.equipped.main == weapon, "2 selects skill slot 2 and keeps the potion count")
	var flight := await _throw_q()
	if flight == null:
		return []
	var head: Vector3 = flight.landing - FLOOR_START
	_check(is_equal_approx(head.x, 4.0) and absf(head.z) < 0.01 and effects.zones.is_empty(),
		"first throw samples the camera, flies 4 m and creates no zone before impact")
	_check(not _badge(VENOM).visible, "throwing and flight do not show infection HUD")
	await _wait_impact()
	_check(effects.zones.size() == 1 and not _badge(VENOM).visible, "first impact starts zone A without infecting remote Foxy")
	if effects.zones.is_empty():
		return []
	var zone_a: RefCounted = effects.zones[0]
	var center: Vector3 = zone_a.center
	var visual: AnimatedSprite3D = zone_a.visual
	var frames := visual.sprite_frames
	_check(frames.get_frame_count("default") == 4 and frames.get_animation_loop("default")
		and is_equal_approx(frames.get_animation_speed("default"), 1000.0 / 65.0)
		and frames.get_frame_texture("default", 3).region == Rect2(194, 98, 44, 14),
		"zone loops the four manifest frames at 65 ms each")
	for frame in range(420):
		if zone_a.expires_at - effects.gameplay_time <= 2.0 + 0.00001:
			break
		await physics_frame
	_check(absf(zone_a.expires_at - effects.gameplay_time - 2.0) < 0.035, "second throw starts when A has about two seconds left")
	await _throw_q()
	var tick_before: float = zone_a.next_hit_at
	var expiry_before: float = zone_a.expires_at
	await _tap_key(KEY_ESCAPE)
	var clock: float = effects.gameplay_time
	var elapsed: float = effects.flights[0].elapsed
	await create_timer(0.4).timeout
	_check(paused and effects.gameplay_time == clock and effects.flights[0].elapsed == elapsed
		and zone_a.expires_at == expiry_before and zone_a.next_hit_at == tick_before, "pause freezes flight, zone timer and damage schedule")
	await _tap_key(KEY_ESCAPE)
	for frame in range(3):
		await process_frame
	await _wait_impact()
	_check(effects.zones.size() == 1 and effects.zones[0] == zone_a and zone_a.center == center and zone_a.visual == visual
		and absf(zone_a.expires_at - effects.gameplay_time - 8.0) < 0.08 and zone_a.next_hit_at == tick_before,
		"second impact refreshes A to eight seconds with the same position, visual and damage phase")
	var a_deadline: float = zone_a.expires_at
	await _aim(FLOOR_START + Vector3.BACK * 1.5, Vector3.RIGHT)
	await _throw_q()
	await _wait_impact()
	_check(effects.zones.size() == 2 and zone_a.expires_at == a_deadline
		and effects.zones.back().expires_at > a_deadline, "third impact creates B with its own timer and leaves A unchanged")
	if effects.zones.size() != 2:
		return []
	var center_b: Vector3 = effects.zones.back().center
	var showcase: Vector3 = (center + center_b + player.global_position) / 3.0
	camera.global_position = showcase + Vector3(0.0, 5.0, 2.5)
	camera.look_at(showcase)
	await _capture_brew("venom-castle-zones")
	return [zone_a, effects.zones.back()]


func _check_exposure(pair: Array) -> void:
	var a: RefCounted = pair[0]
	var b: RefCounted = pair[1]
	effects.set_physics_process(false)
	var now: float = effects.gameplay_time
	a.expires_at = now + 3.0
	b.expires_at = now + 4.5
	var middle: Vector3 = (a.center + b.center) * 0.5
	player.global_position = middle
	effects._physics_process(0.0)
	for frame in range(2):
		await process_frame
	_check(effects.infection_until == b.expires_at and _badge(VENOM).visible, "overlap chooses the longer remaining exposure and shows infection HUD")
	var scheduled: float = effects.next_infection_hit
	await _capture_brew("venom-infection-hud")
	await _tap_key(KEY_ESCAPE)
	effects.set_physics_process(true)
	await create_timer(0.4).timeout
	_check(paused and effects.gameplay_time == now and effects.next_infection_hit == scheduled
		and effects.infection_until == b.expires_at, "pause freezes existing infection and its damage tick")
	effects.set_physics_process(false)
	await _tap_key(KEY_ESCAPE)
	for frame in range(3):
		await process_frame
	var hp: int = player.health
	effects._physics_process(0.75)
	_check(effects.next_infection_hit == scheduled and player.health == hp, "remaining in overlapping zones does not restart poison")
	effects._physics_process(1.25)
	_check(player.health == hp - 1 and is_equal_approx(effects.next_infection_hit, scheduled + 2.0),
		"overlap runs a single damage tick rather than stacking")
	player.global_position = FLOOR_START
	effects._physics_process(2.5)
	_check(player.health == hp - 2 and effects.infection_until == 0.0 and effects.zones.is_empty(),
		"one infection persists after leaving and both expired zones are removed")

	# Use exact gameplay deltas to test either side of the two-second boundary.
	for seconds in [2.0, 1.5]:
		effects._impact(a.center, Vector3.UP)
		var zone: RefCounted = effects.zones.back()
		zone.expires_at = effects.gameplay_time + seconds
		player.global_position = zone.center
		effects._physics_process(0.0)
		for frame in range(2):
			await process_frame
		_check(_badge(VENOM).visible, "entering a zone with %.1f seconds left shows the infection badge" % seconds)
		var before: int = player.health
		player.global_position = FLOOR_START
		effects._physics_process(seconds - 0.01)
		_check(player.health == before, "no premature HP tick during %.1f-second exposure" % seconds)
		effects._physics_process(0.01)
		for frame in range(2):
			await process_frame
		_check(player.health == before - int(seconds == 2.0) and effects.infection_until == 0.0 and not _badge(VENOM).visible,
			"leaving %.1f-second exposure gives the correct final HP tick and clears the icon" % seconds)
	effects.set_physics_process(true)


func _check_geometry() -> void:
	await _aim(Vector3(90, 1.03, 6.5), Vector3.FORWARD)
	var wall_hit: Dictionary = effects._world_ray(Vector3(90, 1.5, 6.5), Vector3(90, 1.5, 2.5))
	var against_wall := await _throw_q()
	if against_wall != null:
		_check(not wall_hit.is_empty() and against_wall.landing.z > wall_hit.position.z
			and against_wall.landing.z < 6.5, "actual Castle wall shortens landing to its near side")
	await _wait_impact()

	await _aim(Vector3(7, 9.03, 28), Vector3.BACK)
	var stairs := await _throw_q()
	if stairs != null:
		_check(stairs.landing.y > 6.9 and stairs.landing.y < 7.1 and stairs.normal.y < 0.95,
			"Castle stair edge finds a continuous ramp landing instead of the floor below")
	await _wait_impact()

	await _aim(Vector3(7, 4.0, 34), Vector3.BACK)
	var before := _count(venom_uid)
	await _tap_key(KEY_Q)
	_check(_count(venom_uid) == before and effects.flights.is_empty() and _notice().text.contains("điểm đáp"),
		"unsupported Foxy position rejects the throw and preserves inventory")

	var start := Vector3(54, 1.03, 40)
	await _aim(start, Vector3.RIGHT)
	var east := await _throw_q()
	camera.global_position = start + Vector3.UP * 6
	camera.look_at(start, Vector3.FORWARD)
	player.change_direction("left")
	var west := await _throw_q()
	if east != null and west != null:
		_check(effects.flights.size() == 2 and is_equal_approx(east.landing.x, start.x + 4.0)
			and is_equal_approx(west.landing.x, start.x - 4.0), "second throw is accepted in flight and near-vertical camera uses Foxy's facing")
	await _wait_impact()
	_check(effects.zones.size() >= 4, "four independent zones remain active simultaneously")


func _check_enemy_filter() -> void:
	var point := Vector3(24, 1.01, 18)
	var enemy: Node3D = load("res://scenes/enemies/skeleton/skeleton_warrior.tscn").instantiate()
	stage.add_child(enemy)
	enemy.set_physics_process(false)
	enemy.max_health = 4
	enemy.health = 4
	enemy.global_position = point
	effects.set_physics_process(false)
	effects._impact(point, Vector3.UP)
	effects._physics_process(0.99)
	_check(enemy.health == 4, "new zone does not deal damage before the one-second tick")
	effects._physics_process(0.01)
	_check(enemy.health == 3, "living enemy on the same floor receives one HP damage at the tick")
	await create_timer(0.9).timeout
	enemy.global_position = point + Vector3.RIGHT * 1.2
	effects._physics_process(1.0)
	_check(enemy.health == 3, "enemy leaving the radius stops taking its ticks")
	enemy.global_position = point + Vector3.UP * 8.0
	effects._physics_process(1.0)
	_check(enemy.health == 3, "enemy directly above on the other floor receives no tick")

	enemy.global_position = point + Vector3.RIGHT * 0.8
	var wall := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.15, 2.0, 1.2)
	shape.shape = box
	wall.add_child(shape)
	stage.add_child(wall)
	wall.global_position = point + Vector3(0.4, 1.0, 0.0)
	await _ticks(3)
	effects._physics_process(1.0)
	_check(enemy.health == 3, "solid wall blocks a tick within nominal radius")
	wall.queue_free()
	enemy.queue_free()
	effects.set_physics_process(true)


func _death_and_wave_reset() -> void:
	var checkpoint := stage.get_node("F2/Transitions/Checkpoint_f2") as Area3D
	player.global_position = checkpoint.global_position
	await _ticks(8)
	_check(manager.checkpoint_id == "castle_f2_start", "actual Castle F2 checkpoint is active")
	await _aim(WAVE_START, Vector3.RIGHT)
	var throw := await _throw_q()
	if throw == null:
		return
	await _wait_impact()
	var old_center: Vector3 = throw.landing
	player.global_position = old_center
	player.health = 1
	var previous_stage := stage
	var paid_count := _count(venom_uid)
	await _ticks(5)
	_check(_badge(VENOM).visible and player.health == 1, "Foxy is infected before lethal poison tick")
	for frame in range(160):
		if player.health == 0:
			break
		await physics_frame
	await process_frame
	_check(player.health == 0 and effects.infection_until == 0 and not _badge(VENOM).visible
		and not effects.zones.is_empty() and current_scene == previous_stage,
		"lethal infection clears Foxy while the old encounter's zones keep running")
	var death_time: float = effects.gameplay_time
	player.set_physics_process(true)
	await _ticks(12)
	_check(current_scene == previous_stage and effects.gameplay_time > death_time and not effects.zones.is_empty(),
		"the old encounter keeps advancing its independent zone clock during death")
	await scene_changed
	await _bind_castle()
	_check(not is_instance_valid(previous_stage) and not is_instance_valid(effects) and player.health == player.max_health
		and _count(venom_uid) == paid_count, "actual Castle checkpoint reload removes zones but keeps spent bottles")
	var zones := _enemy_zones()
	var wave: Array[Node3D] = []
	for zone in zones:
		for index in range(zone.clear_kills):
			zone._on_timer_timeout()
	for enemy in get_nodes_in_group("enemies"):
		if enemy.get_parent() == zones[0].get_parent():
			enemy.set_physics_process(false)
			enemy.health = 1
			enemy.global_position = old_center
			wave.append(enemy)
	_check(wave.size() == 9 and not manager.is_door_unlocked("castle_f2_cleared"), "fresh Castle wave uses its actual three finite zones")
	await create_timer(1.1, false).timeout
	_check(wave.all(func(enemy: Node3D) -> bool: return is_instance_valid(enemy) and enemy.health == 1),
		"fresh wave in the same footprint receives no stale damage")

	await _aim(WAVE_START, Vector3.RIGHT)
	var before_exp: int = manager.experience
	var before_level: int = manager.player_level
	var fresh := await _throw_q()
	if fresh == null:
		return
	await _wait_impact()
	var saw_drop := false
	for frame in range(250):
		saw_drop = saw_drop or stage.find_children("*", "Area3D", true, false).any(
			func(area: Node) -> bool: return area.scene_file_path == "res://levels/objects/experience_point/exp_point.tscn")
		if manager.is_door_unlocked("castle_f2_cleared"):
			break
		await physics_frame
	var exit := stage.get_node("F2/Transitions/Door_to_next")
	_check(zones.all(func(zone: Node) -> bool: return zone.is_cleared()) and not exit.is_locked(),
		"poison kills count through the actual EnemyZones and unlock the Castle exit")
	_check(saw_drop, "poison defeat runs the ordinary EXP drop hook")
	for frame in range(90):
		if manager.player_level > before_level or manager.experience > before_exp:
			break
		await physics_frame
	_check(manager.player_level > before_level or manager.experience > before_exp, "EXP from a poison defeat reaches Foxy")
	var saved: Dictionary = root.get_node("SaveSystem").load_data()
	_check(_count(venom_uid) == 14 - accepted and int(saved.inventory.items[venom_uid].count) == 14 - accepted,
		"live and saved bottle counts equal successful Q throws")


func _enemy_zones() -> Array[Node]:
	return stage.get_node("F2/EnemyZones").get_children().filter(
		func(zone: Node) -> bool: return zone.has_method("is_cleared"))
