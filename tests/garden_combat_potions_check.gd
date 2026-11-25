extends "res://tests/basement_clear_portal_check.gd"
## Runs the real Garden with a disposable user directory. --continue checks restart.

const PROTECTION := "protection_potion"
const STRENGTH := "strength_potion"

var manager: Node
var stage: Node3D
var player: Node
var guard_uid: String
var strength_uid: String


func _run() -> void:
	var custom := str(ProjectSettings.get_setting("application/config/custom_user_dir_name", ""))
	if not ProjectSettings.get_setting("application/config/use_custom_user_dir", false) \
		or not custom.begins_with("ArcanaPlacement-") or not "--isolated-copy" in OS.get_cmdline_user_args():
		push_error("Use a disposable project and a dedicated ArcanaPlacement- user directory.")
		quit(2)
		return
	manager = root.get_node("GameManager")
	if "--continue" in OS.get_cmdline_user_args():
		await _check_continue()
	else:
		await _garden_and_combat()
	_finish()


func _garden_and_combat() -> void:
	root.get_node("SaveSystem").delete_save()
	manager.reset()
	manager.skill_allocations["char_health"] = 2
	manager.change_stage(GARDEN)
	await scene_changed
	await _bind_garden_player()
	var checkpoint := stage.get_node("Transitions/Checkpoint_garden") as Area3D
	player.global_position = checkpoint.global_position
	await _ticks(8)
	_check(manager.checkpoint_id == "garden_start", "the real Garden checkpoint is saved")
	await _brew_potions()
	guard_uid = _find_item(PROTECTION)
	strength_uid = _find_item(STRENGTH)

	var baseline := await _normal_hit()
	_check(baseline > 0, "ordinary combo lands exactly one hit before any potion (%d damage)" % baseline)
	await _assign(PROTECTION, guard_uid)
	player.health = player.max_health
	_check(player.health == 5, "full HP is five so shield rounding is exercised")
	await _tap_key(KEY_Q)
	_check(_count(guard_uid) == 3 and player.potion_shield_health == 3
		and player.potion_shield_capacity == 3 and player.health == 5, "Q spends one Hộ mệnh at full HP and grants ceil(5/2) shield")
	await _tap_key(KEY_Q)
	_check(_count(guard_uid) == 3 and _notice().text.contains("còn hiệu lực") and _notice().visible,
		"Q rejects duplicate Hộ mệnh and displays the reason")
	var main_uid: String = manager.inventory.equipped.main
	await _tap_key(KEY_2)
	_check(player.selected_active_slot == 2 and manager.inventory.equipped.main == main_uid and _count(guard_uid) == 3,
		"2 keeps active skill slot 2, leaves weapon and potions unchanged")

	await _assign(STRENGTH, strength_uid)
	await _tap_key(KEY_Q)
	_check(_count(strength_uid) == 3 and player.potion_strength_remaining > 0.0, "Q spends exactly one Cường lực")
	_check(_badge(PROTECTION).is_visible_in_tree() and _badge(STRENGTH).is_visible_in_tree()
		and _shield_bar().value == 3.0, "both potion icons and the separate shield gauge are visible")
	await _capture_brew("potions-both-active")
	await create_timer(0.25, false).timeout
	var time_before: float = player.potion_strength_remaining
	await _tap_key(KEY_Q)
	_check(_count(strength_uid) == 3 and player.potion_strength_remaining <= time_before
		and _notice().visible and _notice().text.contains("Cường lực"),
		"duplicate Cường lực reports why and neither spends nor resets time")
	await _check_paused_inventory()
	var doubled := await _normal_hit()
	_check(doubled == baseline * 2, "the same ordinary contact deals double damage while active (%d damage)" % doubled)
	_check(_unmodified_hit() == 7, "a separate hitbox used by projectiles retains its damage")
	await _check_shield_damage()

	await _assign(PROTECTION, guard_uid)
	player.health = 3
	await _tap_key(KEY_Q)
	_check(_count(guard_uid) == 2 and player.potion_shield_health == 2, "shield can be reused after break and uses current HP")
	_incoming(1)
	_check(player.potion_shield_health == 1 and player.health == 3 and _shield_bar().value == 1.0,
		"a hit covered by the potion shield spends only shield points")
	await create_timer(7.3, false).timeout
	_check(player.potion_shield_health == 1 and _badge(PROTECTION).visible, "shield still exists late in its eight-second window")
	await create_timer(0.85, false).timeout
	_check(player.potion_shield_health == 0 and not _badge(PROTECTION).visible and not _badge(STRENGTH).visible,
		"real gameplay time expires both effects and clears shield gauge")
	var expired := await _normal_hit()
	_check(expired == baseline, "the same ordinary contact returns to baseline after expiry (%d damage)" % expired)

	await _assign(STRENGTH, strength_uid)
	await _tap_key(KEY_Q)
	await _assign(PROTECTION, guard_uid)
	await _tap_key(KEY_Q)
	_check(_count(guard_uid) == 1 and _count(strength_uid) == 2 and player.potion_shield_health > 0
		and player.potion_strength_remaining > 0.0, "both combat effects are active before lethal damage")
	_incoming(player.health + player.potion_shield_health)
	_check(player.health == 0 and player.potion_strength_remaining == 0.0 and player.potion_shield_health == 0
		and not _badge(PROTECTION).visible and not _badge(STRENGTH).visible, "lethal combat hit clears buffs and HUD immediately")
	player.set_physics_process(true)
	await scene_changed
	await _bind_garden_player()
	_check(player.health == 5 and _no_effects() and _count(guard_uid) == 1 and _count(strength_uid) == 2,
		"actual death respawns at Garden with no buffs or returned bottles")

	await _tap_key(KEY_Q)
	await _assign(STRENGTH, strength_uid)
	await _tap_key(KEY_Q)
	_check(player.potion_shield_health > 0 and player.potion_strength_remaining > 0.0, "both effects active before explicit scene change")
	manager.change_stage(manager.FIRST_STAGE)
	await scene_changed
	stage = current_scene
	player = stage.player
	_check(stage.scene_file_path == manager.FIRST_STAGE and _no_effects()
		and _count(guard_uid) == 0 and _count(strength_uid) == 1, "scene transition clears transient effects and keeps paid counts")
	var disk: Dictionary = root.get_node("SaveSystem").load_data()
	_check(not disk.inventory.items.has(guard_uid) and int(disk.inventory.items[strength_uid].count) == 1
		and disk.inventory.equipped.consumable == strength_uid, "save retains final counts and assignment for Continue")


func _bind_garden_player() -> void:
	stage = current_scene
	player = stage.player
	await _ticks(4)
	player.set_physics_process(false)


func _brew_potions() -> void:
	var farm := stage.get_node("Farm")
	# Mốc 1 regression exercises planting and harvest. Start with harvested produce here.
	farm.data.produce = {"broccoli": 8, "spinach": 4, "pineapple": 4}
	player.global_position = farm.get_node("SeedMerchant").global_position + Vector3(0, 0.2, 1)
	await _tap_f()
	await _dialogue_choices()
	root.get_node("Dialogic").Choices.select_choice(3)
	await _ticks(12)
	var protection := farm.choices.get_node(PROTECTION) as Button
	var strength := farm.choices.get_node(STRENGTH) as Button
	_check(not protection.disabled and not strength.disabled and farm.choices.get_node("healing_potion").disabled,
		"Garden presents three independent recipes with the proper availability")
	_check(_frame_matches(protection, "oasis_elixir.png") and _frame_matches(strength, "dragonfire_potion.png"),
		"the two potion frames use the requested 32×32 atlases")
	_check(protection.has_focus(), "focus starts at the first craftable recipe")
	await _tap_key(KEY_DOWN)
	_check(strength.has_focus(), "Down moves between valid recipes")
	await _tap_key(KEY_DOWN)
	_check(farm.close_button.has_focus(), "Down reaches close after the last valid recipe")
	await _capture_brew("potions-brew")
	protection.pressed.emit()
	_check(farm.data.produce == {"broccoli": 7, "spinach": 3, "pineapple": 4}
		and farm.choices.get_node(STRENGTH + "_ingredients").text.contains("Bông cải · 7 / 1"),
		"Hộ mệnh charges broccoli and spinach and refreshes shared counts")
	strength.pressed.emit()
	_check(farm.data.produce == {"broccoli": 6, "spinach": 3, "pineapple": 3},
		"Cường lực charges broccoli and pineapple")
	for index in range(4):
		protection.pressed.emit()
		strength.pressed.emit()
	var disk: Dictionary = root.get_node("SaveSystem").load_data()
	_check(protection.disabled and strength.disabled and _count(_find_item(PROTECTION)) == 4
		and _count(_find_item(STRENGTH)) == 4 and int(disk.flags.garden_farm_v1.produce.broccoli) == 0
		and int(disk.inventory.items[_find_item(PROTECTION)].count) == 4
		and int(disk.inventory.items[_find_item(STRENGTH)].count) == 4,
		"rapid confirmations recheck stock and save each successful exchange together")
	await _tap_key(KEY_ESCAPE)


func _assign(definition: String, uid: String) -> void:
	var inventory := root.get_node("InventoryMenu")
	await _tap_key(KEY_B)
	_find_button(inventory._tabs, "Tiêu hao").pressed.emit()
	var grid: Node = inventory._list.get_node("InventoryGrid")
	var index := 0
	for item: String in manager.inventory.items:
		if manager.inventory.CATALOG.item(manager.inventory.items[item].definition).slot != "consumable":
			continue
		if manager.inventory.items[item].definition == definition:
			break
		index += 1
	grid.get_child(index).pressed.emit()
	var assign := _find_button(inventory._detail, "Gán vào ô Q")
	if assign != null:
		assign.pressed.emit()
	_check(inventory.selected == uid and manager.inventory.equipped.consumable == uid,
		"B → Tiêu hao assigns " + definition + " to Q")
	await _tap_key(KEY_ESCAPE)
	for frame in range(3):
		await process_frame


func _check_paused_inventory() -> void:
	var inventory := root.get_node("InventoryMenu")
	await _tap_key(KEY_B)
	_find_button(inventory._tabs, "Tiêu hao").pressed.emit()
	inventory._select(strength_uid)
	_find_button(inventory._detail, "Sử dụng").pressed.emit()
	_check(inventory._status.text.contains("Cường lực vẫn còn hiệu lực") and _count(strength_uid) == 3,
		"Inventory B displays the same duplicate-use reason")
	var protection_time: float = player.potion_shield_remaining
	var strength_time: float = player.potion_strength_remaining
	await create_timer(0.4).timeout
	_check(paused and player.potion_shield_remaining == protection_time and player.potion_strength_remaining == strength_time,
		"both timers freeze while gameplay is paused")
	await _tap_key(KEY_ESCAPE)
	for frame in range(3):
		await process_frame
	await _tap_key(KEY_ESCAPE)
	protection_time = player.potion_shield_remaining
	strength_time = player.potion_strength_remaining
	await create_timer(0.4).timeout
	_check(root.get_node("PauseMenu").is_open and paused and player.potion_shield_remaining == protection_time
		and player.potion_strength_remaining == strength_time, "Escape pause menu freezes both potion timers")
	await _tap_key(KEY_ESCAPE)
	for frame in range(3):
		await process_frame


func _check_shield_damage() -> void:
	player.fsm.change_state(player.fsm.states.parry)
	player.fsm._update(0.0)
	_incoming(2)
	_check(player.invincible and player.potion_shield_health == 3 and player.health == 5, "successful parry preserves potion shield")
	player.fsm.change_state(player.fsm.states.idle)
	player.fsm._update(0.0)
	player.invincible = true
	_incoming(2)
	player.invincible = false
	player.is_invulnerable = true
	_incoming(2)
	player.is_invulnerable = false
	_check(player.potion_shield_health == 3 and player.health == 5, "both existing immunity gates preserve potion shield")
	player.ice_shield = 1
	_incoming(5)
	_check(player.ice_shield == 0 and player.potion_shield_health == 3 and player.health == 5, "existing Ice Shield resolves first")
	_incoming(5)
	_check(player.health == 3 and player.potion_shield_health == 0 and not _badge(PROTECTION).visible
		and not _shield_bar().is_visible_in_tree() and _badge(STRENGTH).visible,
		"five damage overflows three shield for two HP and clears only the broken badge")


func _normal_hit() -> int:
	var hitbox := player.get_node("Direction/HitArea3D") as Area3D
	var hit_shape := hitbox.get_node("CollisionShape3D") as CollisionShape3D
	var damage_seen: Array[int] = []
	var target: Area3D = load("res://scripts/hurt_area_3d.gd").new()
	target.collision_layer = hitbox.collision_mask
	target.collision_mask = 0
	var shape := CollisionShape3D.new()
	shape.shape = SphereShape3D.new()
	shape.shape.radius = 0.25
	target.add_child(shape)
	stage.add_child(target)
	target.hurt.connect(func(_direction: Vector3, amount: float) -> void: damage_seen.append(int(amount)))
	player.fsm.change_state(player.fsm.states.attack)
	player.fsm._update(0.0)
	var attack: Node = player.fsm.states.attack
	if attack._phase != attack.PHASE_COMBO:
		attack._start_combo()
	target.global_position = hit_shape.global_position
	attack._update_combo(float(attack._combo_beat) * 0.5)
	await _ticks(6)
	player.fsm.change_state(player.fsm.states.idle)
	player.fsm._update(0.0)
	target.queue_free()
	await _ticks(4)
	return damage_seen[0] if damage_seen.size() == 1 else -1


func _unmodified_hit() -> int:
	var projectile_hit: Area3D = load("res://scripts/hit_area_3d.gd").new()
	var target: Area3D = load("res://scripts/hurt_area_3d.gd").new()
	stage.add_child(projectile_hit)
	stage.add_child(target)
	var damage_seen: Array[int] = []
	target.hurt.connect(func(_direction: Vector3, amount: float) -> void: damage_seen.append(int(amount)))
	projectile_hit.attacker = player
	projectile_hit.damage = 7
	projectile_hit.hit(target)
	projectile_hit.queue_free()
	target.queue_free()
	return damage_seen[0] if damage_seen.size() == 1 else -1


func _incoming(damage: int) -> void:
	player.get_node("Direction/HurtArea3D").take_damage(Vector3.FORWARD, damage)


func _check_continue() -> void:
	change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))
	await scene_changed
	for frame in range(120):
		if current_scene != null and current_scene.scene_file_path == GARDEN:
			break
		await physics_frame
	_check(current_scene != null and current_scene.scene_file_path == GARDEN, "new process continues at saved Garden checkpoint")
	if current_scene == null or current_scene.scene_file_path != GARDEN:
		return
	await _bind_garden_player()
	strength_uid = _find_item(STRENGTH)
	_check(_no_effects() and _find_item(PROTECTION).is_empty() and _count(strength_uid) == 1
		and manager.inventory.equipped.consumable == strength_uid, "Continue restores paid counts and Q assignment without either active effect")


func _no_effects() -> bool:
	return player.potion_shield_health == 0 and player.potion_strength_remaining == 0.0 \
		and not _badge(PROTECTION).visible and not _badge(STRENGTH).visible


func _find_item(definition: String) -> String:
	for uid: String in manager.inventory.items:
		if manager.inventory.items[uid].definition == definition:
			return uid
	return ""


func _count(uid: String) -> int:
	return int(manager.inventory.items.get(uid, {}).get("count", 0))


func _frame_matches(button: Button, sheet: String) -> bool:
	return button.icon is AtlasTexture and button.icon.region == Rect2(0, 0, 32, 32) \
		and button.icon.atlas.resource_path.ends_with("/" + sheet)


func _badge(definition: String) -> Control:
	return stage.find_child("PotionHUD", true, false).find_child(definition, true, false) as Control


func _shield_bar() -> ProgressBar:
	return _badge(PROTECTION).find_child("PotionShieldBar", true, false) as ProgressBar


func _notice() -> Label:
	return stage.find_child("PotionNotice", true, false) as Label
