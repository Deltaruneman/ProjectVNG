extends Node
const CATALOG := preload("res://scripts/item_catalog.gd")
const INVENTORY := preload("res://scripts/inventory_state.gd")
var checks := 0
var failures := 0
var player: Player
var yard: Node3D

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
	print("PASS " if ok else "FAIL ", label)

func ticks(count: int = 4) -> void:
	for index in count:
		await get_tree().physics_frame
		await get_tree().process_frame

func key(code: Key) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.keycode = code
		event.physical_keycode = code
		event.pressed = pressed
		Input.parse_input_event(event)

func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("user://inventory-" + label + ".png")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not "ArcanaInventory" in OS.get_user_data_dir():
		push_error("Refusing inventory test outside isolated user directory")
		get_tree().quit(2)
		return
	if OS.get_cmdline_user_args().has("--stage-flow"):
		await _stage_flow()
		return
	SaveSystem.save_path = "user://inventory-fixture.json"
	GameManager.reset()
	GameManager._loaded_payload = {"sentinel": {"keep": 42}}
	check(GameManager.inventory.id_for_slot("main") == "starter_blade", "new game starts with original Blade")
	check(GameManager.grant_item("invalid") == "" and not GameManager.equip_item("invalid"), "invalid grants/equips rejected")
	var sword := GameManager.grant_item("sword")
	var fire := GameManager.grant_item("spear")
	var bow := GameManager.grant_item("bow")
	var armor := GameManager.grant_item("armor")
	var charm := GameManager.grant_item("charm")
	var potion := GameManager.grant_item("healing_potion", 2)
	check(GameManager.grant_item("healing_potion", 3) == potion and GameManager.inventory.items[potion].count == 5, "consumables stack by definition")
	check(not GameManager.equip_item(potion), "cannot equip consumable")
	for uid: String in [sword, bow, armor, charm]:
		check(GameManager.equip_item(uid), "equip owned item " + uid)
	check(GameManager.inventory.equipped.size() == 4, "exactly four named equipment slots")
	GameManager.save_game()
	var snapshot := GameManager.inventory.serialize()
	GameManager.reset()
	GameManager.load_game()
	check(GameManager.inventory.serialize().items == snapshot.items and GameManager.inventory.equipped == snapshot.equipped, "inventory persists across save/load")
	check(SaveSystem.load_data().sentinel.keep == 42, "unrelated payload preserved")
	check(not GameManager.inventory.eligible_enchants(bow).has("resonance") and not GameManager.inventory.eligible_enchants(bow).has("affliction"), "neutral offhand excludes elemental enchants")
	check(GameManager.inventory.eligible_enchants(fire).has("resonance") and GameManager.inventory.eligible_enchants(fire).has("affliction"), "resonant weapon allows elemental enchants")
	check(GameManager.prepare_enchants(armor).is_empty() and GameManager.prepare_enchants("invalid").is_empty(), "enchant rejects armor and unowned items")
	var offers := GameManager.prepare_enchants(sword)
	check(offers.size() == 3 and offers[0].id != offers[1].id and offers[1].id != offers[2].id and offers[0].id != offers[2].id, "three distinct eligible enchant choices")
	check(GameManager.prepare_enchants(sword) == offers, "same selected weapon keeps offers")
	var epoch: int = GameManager.inventory.offer_epoch
	GameManager.skill_points = 0
	check(not GameManager.enchant_weapon(sword, 0, epoch), "insufficient SP cannot enchant")
	GameManager.skill_points = 20
	check(not GameManager.enchant_weapon(sword, -1, epoch) and not GameManager.enchant_weapon(sword, 3, epoch) and not GameManager.enchant_weapon(fire, 0, epoch), "invalid choice and wrong weapon rejected")
	check(GameManager.enchant_weapon(sword, 0, epoch) and GameManager.skill_points == 19, "one choice consumes exactly its quoted SP")
	check(not GameManager.enchant_weapon(sword, 0, epoch), "duplicate consumed offer rejected")
	GameManager.prepare_enchants(sword)
	check(not GameManager.enchant_weapon(sword, 0, epoch), "stale UI offer epoch rejected after reroll")
	GameManager.save_game()
	GameManager.load_game()
	check(GameManager.inventory.offers.size() == 3 and GameManager.inventory.enchant_spent == 1, "pending offers and spent enchant SP persist")
	var before := GameManager.skill_points
	GameManager.reset_skill_tree()
	check(GameManager.skill_points == before and GameManager.total_skill_points() == 20, "tree reset does not refund enchant or reduce earned-SP gates")
	var state := INVENTORY.new()
	state.restore({"items": {"item_99": {"definition": "bow_fire", "enchants": {"resonance": 99, "sharpness": 99, "bogus": 2}}}, "equipped": {"main": "item_99"}})
	check(state.id_for_slot("main") == "starter_blade" and state.items.item_99.definition == "bow" and not state.items.item_99.enchants.has("resonance") and state.items.item_99.inactive_enchants.resonance == 3 and state.items.item_99.enchants.sharpness == 3, "load rejects wrong slots, equips fallback Blade, and retains clamped inactive elemental rank")
	var empty_main := INVENTORY.new()
	empty_main.restore({"items": {"item_7": {"definition": "starter_blade"}}, "equipped": {"main": ""}})
	check(empty_main.id_for_slot("main") == "starter_blade", "saved inventory with empty main slot equips the original Blade")
	check(state.grant("bow") == "item_101", "load reconstructs unique instance counter")
	for id: String in CATALOG.ENCHANTS:
		GameManager.inventory.items[sword].enchants[id] = 3
	check(GameManager.prepare_enchants(sword).is_empty(), "maxed weapon does not offer impossible upgrades")
	GameManager.inventory.items[sword].enchants.clear()
	for id: String in CATALOG.definitions():
		check(CATALOG.texture(id) != null, "supplied art loads " + id)
	_catalog_migration_checks()
	_enchant_limit_checks()
	await _player_checks(sword, fire, bow, armor, charm, potion)
	await _starter_visual_checks()
	await _offhand_presentation_checks()
	await _projectile_checks()
	await _boss_drop_check()
	await ticks(3)
	print("INVENTORY_RESULT ", checks - failures, "/", checks, " passed; failures=", failures)
	get_tree().quit(0 if failures == 0 else 1)

func _player_checks(sword: String, fire: String, bow: String, armor: String, charm: String, potion: String) -> void:
	yard = Node3D.new()
	add_child(yard)
	var camera := Camera3D.new()
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-45, -30, 0)
	sun.light_energy = 1.5
	yard.add_child(sun)
	yard.add_child(camera)
	camera.position = Vector3(5, 6, 8)
	camera.look_at(Vector3(0, 0.8, 0))
	player = preload("res://scenes/player/player.tscn").instantiate()
	yard.add_child(player)
	player.movement_enabled = false
	await ticks()
	var art := player.get_node("Direction/Blade/Sprite3D") as Sprite3D
	check(art.texture is AtlasTexture and player.has_weapon, "equipping weapon replaces current Blade sprite")
	check(player.max_health == player._base_max_health + 2, "equipped armor applies HP bonus")
	player.health = 1
	GameManager.unequip_item("armor")
	GameManager.equip_item(armor)
	check(player.health == 1, "re-equipping armor cannot heal for free")
	player.health = 1
	check(GameManager.use_inventory_item(potion) and player.health == player.max_health and GameManager.inventory.items[potion].count == 4, "consume potion heals and decrements one")
	check(not GameManager.use_inventory_item(potion), "full HP cannot waste consumable")
	GameManager.unequip_item("main")
	check(not player.has_weapon, "unequipping main hides blade")
	GameManager.equip_item(fire)
	check(art.texture is AtlasTexture and (art.texture as AtlasTexture).atlas.resource_path.ends_with("fantasy_epicweapons_pack1_nobg.png"), "resonant main uses supplied glow atlas")
	GameManager.weapon_form = "fire"
	check(player.scaled_skill_damage(10) == 14, "matching resonance plus charm buffs elemental skill")
	GameManager.weapon_form = "ice"
	check(player.scaled_skill_damage(10) == 12, "wrong element gets charm only")
	GameManager.weapon_form = ""
	check(player.uses_offhand(1) and not player.uses_offhand(2) and player.get_active_skill_id_for_slot(1) == "offhand_bow", "neutral slot 1 assigned equipped offhand only")
	GameManager.weapon_form = "fire"
	check(not player.uses_offhand(), "elemental offhand locked without upgrade")
	GameManager.skill_points = 20
	check(not GameManager.buy_offhand_resonance("fire"), "upgrade requires unlocked elemental skill 1")
	GameManager.unlocked_skills.assign(["active_fire_1"])
	check(GameManager.buy_offhand_resonance("fire") and player.uses_offhand(), "skill 1 resonance upgrade spends SP and enables offhand")
	player._active_skill_cooldowns.clear()
	player.selected_active_slot = 1
	player._skill_aim_point = player.global_position + Vector3(0, 1, -10)
	player._cast_aim_point_valid = true
	player.fsm.change_state(player.fsm.states.skill)
	player.fsm._update(0.0)
	var cast_projectile: Node3D
	for child in yard.get_children():
		if child.get_script() == preload("res://scenes/objects/offhand_projectile.gd"):
			cast_projectile = child
	check(cast_projectile != null and cast_projectile.elemental_form == "fire" and cast_projectile.definition == "bow", "actual Skill state launches equipped elemental offhand")
	check(player.get_active_skill_cooldown_for_slot(1) > 0.0, "offhand cast starts shared skill cooldown")
	if cast_projectile != null:
		var expected: Vector3 = (player._skill_aim_point - cast_projectile.global_position).normalized()
		expected.y = 0.0
		expected = expected.normalized()
		check(absf(cast_projectile.direction.y) < 0.001 and cast_projectile.direction.dot(expected) > 0.999, "bow keeps a straight level aim toward the target")
		cast_projectile.set_physics_process(false)
		cast_projectile.global_position = player.global_position + Vector3.UP * 1.1 + cast_projectile.direction * 1.4
		await capture("straight-bow-projectile")
		cast_projectile.queue_free()
	player.fsm.change_state(player.fsm.states.idle)
	player.fsm._update(0.0)
	var after := GameManager.skill_points
	check(not GameManager.buy_offhand_resonance("fire") and GameManager.skill_points == after, "duplicate upgrade rejected")
	GameManager.save_game()
	GameManager.load_game()
	check(player.uses_offhand(), "offhand upgrade survives reload")
	GameManager.reset_skill_tree()
	check(player.uses_offhand() and GameManager.inventory.resonance_upgrades.is_empty(), "tree reset clears elemental upgrades; neutral offhand remains")
	var attack: FSMState = player.fsm.states.attack
	var shape := player.get_node("Direction/HitArea3D/CollisionShape3D") as CollisionShape3D
	var baseline := shape.scale
	var tempo := player.anim_player.speed_scale
	var base_beats := {"sword": 0.25, "axe": 0.32, "spear": 0.2, "dagger": 0.2}
	for kind: String in ["sword", "axe", "spear", "dagger"]:
		GameManager.equip_item(GameManager.grant_item(kind))
		player.fsm.change_state(attack)
		player.fsm._update(0.0)
		attack.call("_start_combo")
		check(is_equal_approx(float(attack.get("_combo_beat")), float(base_beats[kind]) / float(CATALOG.item(kind).tempo)), "weapon attack tempo " + kind)
		check(is_equal_approx(shape.scale.z, baseline.z * float(CATALOG.item(kind).reach)), "weapon attack reach " + kind)
		player.fsm.change_state(player.fsm.states.idle)
		player.fsm._update(0.0)
		check(shape.scale == baseline and player.anim_player.speed_scale == tempo, "attack restores shared animation/shape " + kind)
	await capture("weapon")
	key(KEY_B)
	await ticks()
	check(InventoryMenu.is_open and get_tree().paused, "B opens inventory and pauses gameplay")
	var inventory_grid := InventoryMenu._list.find_child("InventoryGrid", true, false) as GridContainer
	var empty_item_tooltips := inventory_grid != null
	if inventory_grid != null:
		for tile: Node in inventory_grid.get_children():
			if tile is Button and (tile as Button).tooltip_text != "":
				empty_item_tooltips = false
	check(empty_item_tooltips, "inventory item cells have no hover information")
	InventoryMenu._select(fire)
	await ticks()
	await capture("equipment")
	var original_size: Vector2i = get_viewport().size
	get_viewport().size = Vector2i(360, 360)
	await ticks()
	check(InventoryMenu._panel.position.x + InventoryMenu._panel.size.x <= InventoryMenu._root.size.x, "inventory panel fits square viewport")
	await capture("square")
	get_viewport().size = original_size
	await ticks()
	key(KEY_T)
	await ticks()
	check(InventoryMenu.is_open, "skill tree cannot steal inventory pause")
	key(KEY_ESCAPE)
	await ticks()
	check(not InventoryMenu.is_open and not get_tree().paused, "Escape closes and releases inventory pause")
	key(KEY_P)
	await ticks()
	check(InventoryMenu.is_open and InventoryMenu.page == "cheat", "P opens cheat menu")
	await capture("cheat")
	InventoryMenu._show_page("enchant")
	InventoryMenu._select(fire)
	await ticks()
	await capture("enchant")
	InventoryMenu.close_menu()
	await ticks()
	check(PauseMenu.open_menu() and not InventoryMenu.open_menu(), "inventory cannot take pause owned by settings")
	PauseMenu.close_menu()
	await ticks()

func _enemy(at: Vector3) -> EnemyCharacter:
	var enemy := preload("res://scenes/enemies/crab/crab.tscn").instantiate() as EnemyCharacter
	yard.add_child(enemy)
	enemy.global_position = at
	enemy.fsm._update(0.0)
	enemy.set_physics_process(false)
	enemy.set_process(false)
	enemy.movement_enabled = false
	enemy.max_health = 100
	enemy.health = 100
	enemy.get_node("Direction/HitArea3D").monitoring = false
	return enemy

func _projectile(form: String, at: Vector3 = Vector3(0, 0.65, 0)) -> Node3D:
	var projectile := preload("res://scenes/objects/offhand_projectile.gd").new()
	projectile.thrower = player
	projectile.elemental_form = form
	projectile.damage = 2
	projectile.direction = Vector3.RIGHT
	yard.add_child(projectile)
	projectile.global_position = at
	return projectile

func _projectile_checks() -> void:
	player.position = Vector3(0, 0, 8)
	for element: String in ["", "fire", "ice", "lightning", "wind"]:
		var first := _enemy(Vector3(2, 0, 0))
		var second := _enemy(Vector3(4, 0, 0))
		await ticks()
		var shot := _projectile(element)
		await ticks(12 if element == "lightning" else 20)
		check(first.health == 98, "offhand hits nearest enemy exactly once " + element)
		check(second.health == (98 if element == "wind" else 100), "wind alone pierces second enemy " + element)
		if element == "fire":
			check(first._skill_burn_running, "fire shot applies existing burn")
		elif element == "ice":
			check(first.is_skill_slowed(), "ice shot applies existing slow")
		elif element == "lightning":
			check(first.is_skill_frozen(), "lightning shot applies existing stun")
		first.queue_free()
		second.queue_free()
		if is_instance_valid(shot):
			shot.queue_free()
		await ticks()
	var pushed := _enemy(Vector3(2, 0, 0))
	GameManager.equip_item(GameManager.grant_item("axe"))
	pushed.velocity = Vector3.ZERO
	player.position = Vector3.ZERO
	player._on_attack_hit(pushed.get_node("Direction/HurtArea3D"))
	check(pushed.velocity.x > 3.9, "axe applies additional horizontal knockback")
	pushed.queue_free()
	player.position = Vector3(0, 0, 8)
	var wall := StaticBody3D.new()
	var wall_shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.2, 3, 3)
	wall_shape.shape = box
	wall.add_child(wall_shape)
	yard.add_child(wall)
	wall.position = Vector3(1, 0.7, 0)
	var blocked := _enemy(Vector3(2, 0, 0))
	await ticks()
	var shot := _projectile("wind")
	await ticks(15)
	check(blocked.health == 100 and not is_instance_valid(shot), "world wall blocks and destroys even wind projectile")
	player.position = Vector3(0.7, 0, 0)
	var camera := get_viewport().get_camera_3d()
	camera.position = Vector3(-5, 5, 0)
	camera.look_at(Vector3(2, 0.8, 0))
	player._skill_aim_point = Vector3(10, 0.8, 0)
	player._cast_aim_point_valid = true
	GameManager.weapon_form = ""
	player.cast_offhand()
	var muzzle_shots := 0
	for child in yard.get_children():
		if child.get_script() == preload("res://scenes/objects/offhand_projectile.gd") and not child.is_queued_for_deletion():
			muzzle_shots += 1
	check(muzzle_shots == 0, "muzzle cannot spawn projectile through a near wall")
	player.clear_skill_cast_aim()
	wall.queue_free()
	blocked.queue_free()
	await ticks()
	var enchanted := GameManager.grant_item("spear")
	GameManager.inventory.items[enchanted].enchants = {"sharpness": 2, "critical": 3, "vampirism": 3, "haste": 1, "reach": 1, "impact": 1, "resonance": 1, "affliction": 1}
	GameManager.equip_item(enchanted)
	GameManager.weapon_form = "fire"
	check(player.attack_damage == player._base_attack_damage + 3, "sharpness enchant increases actual attack damage")
	check(is_equal_approx(player.get_active_skill_cooldown_duration("basic_dagger"), float(player.ACTIVE_SKILL_COOLDOWNS.basic_dagger) * 0.9), "haste enchant reduces actual skill cooldown")
	check(player.scaled_skill_damage(10) == 16 and is_equal_approx(player.elemental_status_multiplier(), 1.25), "resonance and affliction enchants buff matching skill damage and status duration")
	var enchant_target := _enemy(Vector3(2, 0, 0))
	player.health = 1
	seed(12345)
	var critical_hits := 0
	for index in 30:
		player._weapon_hit_effect(enchant_target.get_node("Direction/HurtArea3D"), "main")
		if index == 0:
			check(enchant_target.is_skill_frozen(), "impact enchant staggers existing enemy through public status API")
		if player.roll_weapon_damage(2) == 4:
			critical_hits += 1
	check(player.health == player.max_health, "lifesteal enchant heals live Player on seeded weapon contacts")
	check(critical_hits > 0 and critical_hits < 30, "critical enchant produces seeded double damage alongside normal hits")
	enchant_target.queue_free()
	await ticks()
	shot = _projectile("")
	shot.max_distance = 0.5
	await ticks(6)
	check(not is_instance_valid(shot), "projectile expires at range without return")


var _stage_inventory: Dictionary
var _stage_sp := 0

func _isolate_stage(stage: Stage) -> void:
	stage.player.invincible = true
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if stage.is_ancestor_of(enemy):
			enemy.set_physics_process(false)
	for timer in stage.find_children("*", "Timer", true, false):
		if timer.get_parent() is EnemyZone:
			timer.stop()

func _check_stage_inventory(label: String) -> void:
	check(GameManager.inventory.serialize() == _stage_inventory and GameManager.skill_points == _stage_sp, "inventory/equipment/enchants/offhand upgrade/SP retained " + label)
	var data := SaveSystem.load_data()
	var expected_saved: Variant = JSON.parse_string(JSON.stringify(_stage_inventory))
	check(data.get("inventory", {}) == expected_saved and data.get("sentinel", {}).get("keep", 0) == 42, "saved inventory and unrelated payload retained " + label)
	var active_player: Player = GameManager.current_stage.player
	check(active_player.max_health == active_player._base_max_health + 2 and active_player.get_node("Direction/Blade/Sprite3D").texture is AtlasTexture, "new stage Player reapplies gear art and armor " + label)

func _stage_flow() -> void:
	SaveSystem.save_path = "user://inventory-stage-fixture.json"
	GameManager.reset()
	GameManager._loaded_payload = {"sentinel": {"keep": 42}}
	for definition: String in ["spear", "bow", "armor", "charm"]:
		GameManager.equip_item(GameManager.grant_item(definition))
	GameManager.grant_item("healing_potion", 3)
	GameManager.skill_points = 20
	GameManager.spend_skill_point("form_fire", "fire")
	GameManager.spend_skill_point("active_fire_1")
	GameManager.buy_offhand_resonance("fire")
	var main_uid: String = GameManager.inventory.equipped.main
	GameManager.prepare_enchants(main_uid)
	GameManager.enchant_weapon(main_uid, 0, GameManager.inventory.offer_epoch)
	GameManager.prepare_enchants(main_uid)
	GameManager.flags.b2_cleared = true
	GameManager.checkpoint_stage = GameManager.FIRST_STAGE
	GameManager.checkpoint_id = "b2_start"
	GameManager.save_game()
	_stage_inventory = GameManager.inventory.serialize()
	_stage_sp = GameManager.skill_points
	get_tree().current_scene = null
	GameManager.stage_changed.connect(_isolate_stage)
	GameManager.change_stage(GameManager.FIRST_STAGE, "b2_start", false)
	await get_tree().scene_changed
	await ticks(5)
	check(GameManager.current_stage.scene_file_path == GameManager.FIRST_STAGE, "actual B2 stage launch")
	_check_stage_inventory("B2 launch")
	GameManager.change_stage(GameManager.B3_STAGE, "b3_down", false)
	await get_tree().scene_changed
	await ticks(5)
	check(GameManager.current_stage.scene_file_path == GameManager.B3_STAGE, "actual B2 to B3 transition")
	_check_stage_inventory("B3 arrival")
	check(GameManager.activate_basement_checkpoint(GameManager.B3_STAGE, "b3_start") == "accepted", "actual B3 checkpoint activation")
	_check_stage_inventory("checkpoint")
	GameManager.current_stage.player.die()
	await get_tree().scene_changed
	await ticks(5)
	check(GameManager.current_stage.player.health == GameManager.current_stage.player.max_health, "death recovery starts at full equipped HP")
	_check_stage_inventory("B3 respawn")
	GameManager.change_stage(GameManager.FIRST_STAGE, "b2_up", false)
	await get_tree().scene_changed
	await ticks(5)
	GameManager.save_game()
	GameManager.load_game()
	_check_stage_inventory("B2 return and reload")
	print("INVENTORY_STAGE_RESULT ", checks - failures, "/", checks, " passed; failures=", failures)
	get_tree().quit(1 if failures else 0)


func _offhand_presentation_checks() -> void:
	var saved_inventory := GameManager.inventory.serialize()
	var saved_form := GameManager.weapon_form
	var saved_skills := GameManager.unlocked_skills.duplicate()
	var state: PlayerSkillState = player.fsm.states.skill
	for offhand: String in ["bow", "throwing_knife"]:
		GameManager.equip_item(GameManager.grant_item(offhand))
		for form: String in ["", "wind", "fire", "ice", "lightning"]:
			for upgraded: bool in [false, true]:
				if form == "" and upgraded:
					continue
				GameManager.weapon_form = form
				GameManager.inventory.resonance_upgrades.clear()
				GameManager.unlocked_skills.clear()
				if form != "":
					GameManager.unlocked_skills.append("active_%s_1" % form)
					if upgraded:
						GameManager.inventory.resonance_upgrades[form] = true
				player.selected_active_slot = 1
				player._active_skill_cooldowns.clear()
				player._skill_aim_point = player.global_position + Vector3(0, 1, -10)
				player._cast_aim_point_valid = true
				var suppression := player._blade_suppress_count
				player.fsm.change_state(state)
				player.fsm._update(0.0)
				var label := "%s/%s/%s" % [offhand, form, "upgraded" if upgraded else "base"]
				check(is_instance_valid(player._offhand_cast_sprite) and player._offhand_cast_sprite.visible and player._offhand_cast_sprite.texture == CATALOG.texture(offhand), "actual equipped offhand appears during first-skill cast " + label)
				check(not player.blade.visible and not player._offhand_cast_sprite.no_depth_test, "cast weapon replaces blade and respects depth " + label)
				if form in ["", "fire"]:
					await ticks(2)
					await capture("cast-%s-%s-%s" % [offhand, form if form != "" else "neutral", "upgraded" if upgraded else "base"])
				# Cover forced interruption as well as ordinary exit.
				player.fsm.change_state(player.fsm.states.hurt if upgraded else player.fsm.states.idle)
				player.fsm._update(0.0)
				if is_instance_valid(state.active):
					state.active._finish()
				for child in yard.get_children():
					if child.get_script() == preload("res://scenes/objects/offhand_projectile.gd"):
						child.queue_free()
				await ticks(2)
				check(not player._offhand_cast_sprite.visible and player._blade_suppress_count == suppression, "cast exit/interruption hides offhand and balances blade " + label)
	player.fsm.change_state(player.fsm.states.idle)
	player.fsm._update(0.0)
	player.selected_active_slot = 2
	player.begin_offhand_cast()
	check(not player._offhand_cast_sprite.visible, "other skill slots do not show offhand")
	player.selected_active_slot = 1
	GameManager.unequip_item("offhand")
	player.begin_offhand_cast()
	check(not player._offhand_cast_sprite.visible, "no offhand equipped produces no phantom cast weapon")
	GameManager.inventory.restore(saved_inventory)
	GameManager.weapon_form = saved_form
	GameManager.unlocked_skills.assign(saved_skills)
	GameManager.notify_inventory_changed()


func _catalog_migration_checks() -> void:
	var expected := {"sword": "lightning", "axe": "ice", "spear": "fire", "dagger": "wind"}
	var main_types := 0
	var offhand_types := 0
	for id: String in CATALOG.definitions():
		var data := CATALOG.item(id)
		if data.slot == "main" and id != "starter_blade":
			main_types += 1
			check(expected.has(id) and data.resonance == expected[id], "fixed main element " + id)
		elif data.slot == "offhand":
			offhand_types += 1
			check(str(data.get("resonance", "")) == "", "offhand has no intrinsic element " + id)
	check(main_types == 4 and offhand_types == 2 and CATALOG.definitions().size() == 10, "catalog has original Blade plus four elemental main types and two neutral offhands")
	var old_items: Dictionary = {}
	var index := 1
	for kind: String in ["sword", "axe", "spear", "dagger", "bow", "throwing_knife"]:
		for element: String in CATALOG.ELEMENTS:
			var old_id := kind + "_" + element
			check(not CATALOG.definitions().has(old_id) and CATALOG.canonical_id(old_id) == kind, "exact legacy variant aliases canonical type " + old_id)
			old_items["item_%d" % index] = {"definition": old_id, "count": 1, "enchants": {"sharpness": 1, "resonance": 2, "affliction": 1}}
			index += 1
	var state := INVENTORY.new()
	state.restore({"items": old_items, "equipped": {"main": "item_1", "offhand": "item_17"}, "enchant_spent": 47})
	check(state.items.size() == 25 and state.equipped.main == "item_1" and state.equipped.offhand == "item_17" and state.enchant_spent == 47, "migration preserves all separate owned instances, equipped UIDs and spent SP")
	check(state.id_for_slot("main") == "sword" and state.definition_for_slot("main").resonance == "lightning" and state.id_for_slot("offhand") == "bow", "legacy wrong-element variants receive confirmed canonical identities")
	for uid: String in state.items:
		if state.items[uid].definition == "starter_blade":
			continue
		var entry: Dictionary = state.items[uid]
		var data := CATALOG.item(entry.definition)
		if data.slot == "offhand":
			check(entry.enchants.sharpness == 1 and not entry.enchants.has("resonance") and entry.inactive_enchants.resonance == 2 and entry.inactive_enchants.affliction == 1, "neutral migration retains old elemental ranks inactive " + uid)
		else:
			check(entry.enchants.resonance == 2 and entry.enchants.affliction == 1, "main migration retains active paid elemental ranks " + uid)
	check(state.enchant_rank("offhand", "resonance") == 0 and not state.eligible_enchants("item_17").has("resonance"), "inactive offhand elemental enchant cannot apply or reappear in pool")
	var snapshot := state.serialize()
	state.restore(snapshot)
	check(state.serialize() == snapshot, "canonical migration and inactive ranks remain stable on repeated restore")
	check(state.grant("sword_fire") == "item_26" and state.items.item_26.definition == "sword", "legacy grant cannot recreate a removed variant")
	check(CATALOG.canonical_id("sword_unknown") == "" and CATALOG.canonical_id("bowfire") == "", "unknown/lookalike IDs are not migrated")
	state.restore({})
	check(state.id_for_slot("main") == "starter_blade" and CATALOG.canonical_id("starter_blade") == "starter_blade", "old save without inventory and legacy starter retain original Blade")


func _boss_drop_check() -> void:
	var scene := load("res://scenes/enemies/darkfairy/darkfairy.tscn") as PackedScene
	check(scene != null and scene.can_instantiate(), "reported Dark Fairy scene compiles after reward API repair")
	if scene == null:
		return
	var boss := scene.instantiate()
	boss.process_mode = Node.PROCESS_MODE_DISABLED
	yard.add_child(boss)
	boss.global_position = Vector3(20, 0, 0)
	var events := [0]
	boss.defeated.connect(func() -> void: events[0] += 1)
	boss._finish_defeat()
	boss._finish_defeat()
	var rewards: Array[Node] = []
	for pickup in get_tree().get_nodes_in_group("exp_point_pickups"):
		if pickup.pickup_id == "mini_boss:dark_fairy":
			rewards.append(pickup)
	check(rewards.size() == 1 and rewards[0].points == 5 and events[0] == 1, "boss defeat emits once and drops exactly one five-unit EXP pickup")
	if rewards.size() != 1:
		return
	var pickup := rewards[0]
	pickup.set_physics_process(false)
	var before := GameManager.experience
	for level in range(1, GameManager.player_level):
		before += GameManager.PROGRESSION.exp_to_next_level(level)
	pickup._collect(player)
	var after := GameManager.experience
	for level in range(1, GameManager.player_level):
		after += GameManager.PROGRESSION.exp_to_next_level(level)
	check(after - before == 100, "existing five boss units still award exactly 100 EXP")
	pickup._collect(player)
	var repeated := GameManager.experience
	for level in range(1, GameManager.player_level):
		repeated += GameManager.PROGRESSION.exp_to_next_level(level)
	check(repeated == after, "boss pickup repeated collection cannot duplicate EXP")
	await ticks(3)


func _enchant_limit_checks() -> void:
	var expected_cells := {"sword": Vector2i(0, 3), "axe": Vector2i(1, 1), "spear": Vector2i(5, 0), "dagger": Vector2i(3, 2)}
	for id: String in expected_cells:
		var art := CATALOG.texture(id) as AtlasTexture
		check(art != null and art.region == Rect2(Vector2(expected_cells[id]) * 32.0, Vector2(32, 32)) and art.atlas.resource_path == CATALOG.GLOW_SHEET, "outlined atlas row matches requested element in inventory/world " + id)
	check(CATALOG.texture("starter_blade").resource_path == "res://assets/models/objects/item4.png" and str(CATALOG.item("starter_blade").get("resonance", "")) == "", "starter uses original Blade art and no elemental affinity")
	var state := INVENTORY.new()
	var uid := state.grant("sword")
	state.items[uid].enchants = {"sharpness": 1, "critical": 1, "haste": 1}
	var pool := state.eligible_enchants(uid)
	check(pool.size() == 3 and pool.has("sharpness") and pool.has("critical") and pool.has("haste"), "three-line weapon can upgrade only its existing enchant types")
	var choices := state.roll_enchants(uid)
	var cost := state.apply_enchant(uid, 0, 100, state.offer_epoch)
	check(cost == 2 and state.items[uid].enchants.size() == 3, "existing line upgrade consumes SP without adding a fourth line")
	# A choice generated before a third type was added must be rejected transactionally.
	state.offers.clear()
	state.items[uid].enchants.clear()
	choices = state.roll_enchants(uid)
	var stale_id: String = choices[0].id
	for id: String in CATALOG.ENCHANTS:
		if id != stale_id and state.items[uid].enchants.size() < 3:
			state.items[uid].enchants[id] = 1
	check(state.apply_enchant(uid, 0, 100, state.offer_epoch) == 0 and state.items[uid].enchants.size() == 3, "backend rejects stale fourth-type choice even after a valid roll")
	state.offers.clear()
	state.items[uid].enchants = {"sharpness": 3, "critical": 3, "haste": 1}
	choices = state.roll_enchants(uid)
	check(choices.size() == 1 and choices[0].id == "haste", "one remaining valid upgrade is offered rather than blocked for lacking three")
	var saved := state.serialize()
	state.restore(saved)
	check(state.offers.size() == 1 and state.serialize() == saved, "one-choice pending offer survives save/load")
	state.apply_enchant(uid, 0, 100, state.offer_epoch)
	state.roll_enchants(uid)
	state.apply_enchant(uid, 0, 100, state.offer_epoch)
	check(state.items[uid].enchants.haste == 3 and state.roll_enchants(uid).is_empty(), "normal weapon stops after all three existing lines reach rank III")
	var blade: String = state.equipped.main
	for id: String in state.eligible_enchants(blade):
		state.items[blade].enchants[id] = 3
	check(state.items[blade].enchants.size() == 6 and state.eligible_enchants(blade).size() == 6, "original Blade accepts more than three non-elemental types and offers ranks above III")
	var expected_spent := state.enchant_spent
	for index in 50:
		choices = state.roll_enchants(blade)
		var quote: int = choices[0].cost
		cost = state.apply_enchant(blade, 0, 1000000, state.offer_epoch)
		expected_spent += quote
		if cost != quote:
			check(false, "unlimited Blade quote and transaction differ")
			return
	var highest := 0
	for rank: int in state.items[blade].enchants.values():
		highest = maxi(highest, rank)
	check(highest > 10 and state.enchant_spent == expected_spent and state.items[blade].enchants.size() == 6, "Blade keeps purchasing 50 times beyond rank ten with exact quoted SP spending")
	saved = state.serialize()
	state.restore(saved)
	check(state.serialize() == saved and state.eligible_enchants(blade).size() == 6, "unbounded Blade ranks and spending persist without clamping")
	var old_enchants := {"sharpness": 3, "critical": 2, "vampirism": 1, "haste": 2, "resonance": 3}
	state.restore({"items": {"item_9": {"definition": "sword_fire", "enchants": old_enchants}}, "equipped": {"main": "item_9"}, "enchant_spent": 27})
	check(state.items.item_9.enchants.size() == 3 and state.items.item_9.inactive_enchants.size() == 2 and state.enchant_spent == 27 and state.equipped.main == "item_9", "old excess lines retained inactive with spent SP and saved equipment intact")
	check(state.items.size() == 2 and CATALOG.item(state.items.item_10.definition).get("legacy", false), "old prototype inventory gains missing original Blade without overwriting equipped weapon")
	saved = state.serialize()
	state.restore(saved)
	check(state.serialize() == saved, "overflow migration and starter grant are idempotent")

func _starter_visual_checks() -> void:
	var saved_main: String = GameManager.inventory.equipped.main
	var blade_uid := ""
	for uid: String in GameManager.inventory.items:
		if GameManager.inventory.items[uid].definition == "starter_blade":
			blade_uid = uid
	GameManager.equip_item(blade_uid)
	var art := player.get_node("Direction/Blade/Sprite3D") as Sprite3D
	check(art.texture == player._original_blade_texture and is_equal_approx(art.pixel_size, player._original_blade_pixel_size), "equipped original Blade restores exact legacy world art and pixel size")
	await capture("original-blade")
	GameManager.skill_points = maxi(GameManager.skill_points, 100)
	InventoryMenu.open_menu("enchant")
	InventoryMenu._select(blade_uid)
	await ticks(3)
	await capture("blade-enchant")
	InventoryMenu.close_menu()
	await ticks(3)
	GameManager.equip_item(saved_main)
