extends SceneTree
class LockCandidate extends Node3D:
	var health := 10
const Inventory := preload("res://scripts/items/item_inventory.gd")
const Catalog := preload("res://scripts/items/item_catalog.gd")
var checks := 0
var failures := 0
var stage: Node3D
var player
var manager
var menu

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
	print("PASS " if ok else "FAIL ", label)

func _initialize() -> void:
	call_deferred("_run")

func frames(count: int = 3) -> void:
	for i in count:
		await process_frame

func capture(label: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/validation/inventory-combat/%s.png" % label)

func press(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await frames(2)
	event = event.duplicate()
	event.pressed = false
	Input.parse_input_event(event)
	await frames(4)

func _run() -> void:
	manager = root.get_node("GameManager")
	menu = root.get_node("PauseMenu")
	var settings = root.get_node("GameSettings")
	# All disk writes go to this fixture's workspace files, never to user://save/settings.
	root.get_node("SaveSystem").save_path = "res://docs/validation/inventory-combat/fixture-save.json"
	if OS.get_cmdline_user_args().has("--restore-only"):
		manager.load_game()
		check(manager.inventory.counts.ember_tonic == 0, "Fresh process preserves depleted consumable")
		check(manager.inventory.equipped.weapon == "parry_dagger", "Fresh process restores equipped weapon")
		check(manager.inventory.quick_item == "swift_tonic", "Fresh process restores quick item")
		check(manager._loaded_payload.foreign_field.keep, "Fresh process preserves unknown fields")
		print("INVENTORY_RESTART_RESULT %d/%d" % [checks - failures, checks])
		quit(1 if failures else 0)
		return
	settings.settings_path = "res://docs/validation/inventory-combat/fixture-settings.cfg"
	var legacy_settings := ConfigFile.new()
	legacy_settings.set_value("meta", "version", 1)
	legacy_settings.set_value("bindings", "attack", [{"key": KEY_B}, {}])
	legacy_settings.save(settings.settings_path)
	settings.load_settings()
	check(settings.bindings.attack[0] == {"key": KEY_B} and settings.bindings.inventory[0].is_empty(), "Legacy custom key wins over newly added inventory default")
	settings.reset_defaults()
	if OS.get_cmdline_user_args().has("--small-ui"):
		settings.values.resolution = 0
		settings.apply_display()
	manager.skill_allocations.clear()
	manager.inventory.reset_with_samples()
	manager.checkpoint_stage = ""
	manager.checkpoint_id = ""
	manager._loaded_payload = {"foreign_field": {"keep": true}}
	stage = Node3D.new()
	root.add_child(stage)
	current_scene = stage
	var camera := Camera3D.new()
	stage.add_child(camera)
	camera.position = Vector3(0, 6, 12)
	camera.look_at(Vector3(0, 1, 0))
	camera.make_current()
	var light := DirectionalLight3D.new()
	stage.add_child(light)
	light.rotation_degrees = Vector3(-35, -20, 0)
	player = load("res://scenes/player/player.tscn").instantiate()
	stage.add_child(player)
	player.set_physics_process(false)
	player.fsm.change_state(player.fsm.states.idle)
	player.fsm._update(0.001)
	await frames()
	check(root.size == (Vector2i(960, 540) if OS.get_cmdline_user_args().has("--small-ui") else Vector2i(1280, 720)), "Requested window resolution active")
	var inventory = manager.inventory
	check(inventory.counts.size() == 12 and inventory.equipped.is_empty(), "New samples granted without auto-equipping")
	check(not inventory.grant("missing") and not inventory.grant("minor_health_potion", -1), "Invalid grant rejected")
	check(inventory.equip("iron_sword"), "Equip weapon")
	check(player.attack_damage == player._base_attack_damage + 1, "Equipment affects actual Player attack")
	check(not inventory.equip("iron_sword"), "Repeated equip rejected")
	inventory.equip("parry_dagger")
	check(player.attack_damage == player._base_attack_damage and is_equal_approx(player.parry_window, player._base_parry_window + 0.03), "Weapon replacement removes old bonus")
	player.health = 1
	inventory.equip("leather_tunic")
	check(player.max_health == player._base_max_health + 2 and player.health == 1, "Armor raises capacity without free heal")
	inventory.unequip("armor")
	inventory.equip("leather_tunic")
	check(player.health == 1, "Equip cycle cannot heal")
	inventory.equip("traveler_boots")
	check(is_equal_approx(player.movement_speed, player._base_movement_speed + 0.5), "Talisman speed applied")
	check(inventory.use_quick(player) and player.health == 3 and inventory.counts.minor_health_potion == 3, "Healing applies and spends one item")
	check(not inventory.use_quick(player) and inventory.counts.minor_health_potion == 3, "Cooldown blocks double spend")
	player._consumable_cooldown = 0.0
	player.health = player.max_health
	check(not inventory.use_quick(player) and inventory.counts.minor_health_potion == 3, "Full health does not consume item")
	inventory.select_quick("ember_tonic")
	check(inventory.use_quick(player), "Attack consumable used")
	var buffed_attack: int = player.attack_damage
	player._consumable_cooldown = 0.0
	check(inventory.use_quick(player) and player.attack_damage == buffed_attack, "Buff refresh does not stack")
	player._process(21.0)
	check(player.attack_damage == player._base_attack_damage, "Buff expires and restores equipment-derived stats")
	check(not inventory.use_quick(player), "Empty stack cannot be consumed")
	inventory.select_quick("swift_tonic")
	player.health = 0
	check(not inventory.use_quick(player), "Dead Player cannot use consumables")
	player.health = player.max_health
	player._consumable_cooldown = 0.0
	player.is_talking = true
	check(not inventory.use_quick(player), "Dialogue blocks consumption")
	player.is_talking = false
	inventory.grant("minor_health_potion", 10000)
	check(inventory.counts.minor_health_potion == 99, "Stack bounded to 99")
	var snapshot: Dictionary = inventory.serialize()
	manager.save_game()
	manager.inventory.restore({})
	manager.load_game()
	check(inventory.serialize() == snapshot, "Actual save/load preserves stacks, gear and selected empty stack")
	check(manager._loaded_payload.foreign_field.keep, "Unknown save fields preserved")
	check(inventory.counts.ember_tonic == 0, "Loading does not replenish used samples")
	var malformed := Inventory.new()
	malformed.restore({"version": 1, "counts": {"missing": 99, "training_blade": 50, "healing_draught": -10}, "equipped": {"armor": "training_blade"}, "quick_item": "training_blade"})
	check(malformed.counts.iron_sword == 1 and malformed.counts.minor_health_potion == 0 and not malformed.counts.has("missing"), "Old IDs migrate and malformed counts sanitize")
	check(malformed.equipped.is_empty() and malformed.quick_item == "", "Invalid slots/quick selection rejected")
	var migrated := Inventory.new()
	migrated.restore({"version": 1, "counts": {"duelist_blade": 1, "healing_draught": 0}, "equipped": {"weapon": "duelist_blade"}, "quick_item": "healing_draught"})
	check(migrated.equipped.weapon == "parry_dagger" and migrated.quick_item == "minor_health_potion" and migrated.counts.minor_health_potion == 0, "Legacy save gear and depleted quick stack migrate")
	await _lightning(camera)
	await _lock_on()
	await _menu_and_dot()
	print("INVENTORY_COMBAT_RESULT %d/%d" % [checks - failures, checks])
	stage.queue_free()
	await frames()
	quit(1 if failures else 0)

func _lightning(camera: Camera3D) -> void:
	var target = load("res://scenes/enemies/skeleton/skeleton_warrior.tscn").instantiate()
	stage.add_child(target)
	target.set_physics_process(false)
	target.position = Vector3(4, 0, 0)
	target.max_health = 50
	target.health = 50
	var before: Vector3 = player.global_position
	player._cast_lightning_beam(Vector3.RIGHT, 2, 7.0, 0)
	check(player.global_position.is_equal_approx(before), "Lightning 2 never teleports")
	check(target.health == 46 and target.is_skill_frozen(), "Lightning 2 retains damage and stun")
	var beam = stage.get_node_or_null("HorizontalLightning")
	check(beam != null and is_equal_approx(beam.start.y, beam.finish.y) and beam.finish.x > beam.start.x, "Beam spans horizontal world endpoints")
	await frames(2)
	await capture("horizontal-lightning")
	target.queue_free()
	await create_timer(0.5).timeout
	check(not is_instance_valid(beam), "Horizontal beam cleans up")

func _menu_and_dot() -> void:
	player._ultimate_visual_remaining = 0.0
	player._ultimate_cinematic_running = false
	await frames()
	var dot = player.get_node("IdleAimDot").get_child(0)
	check(dot.visible and not player._skill_aim_active, "Tiny idle dot visible without aiming")
	await capture("idle-dot")
	player._skill_aim_active = true
	await frames()
	check(not dot.visible, "Idle dot hidden during held aim")
	player._skill_aim_active = false
	await press(KEY_ESCAPE)
	check(menu.is_open and paused and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "ESC opens single pause owner with visible cursor")
	check(not dot.visible, "Dot hidden under pause menu")
	check(not manager.inventory.use_quick(player), "Pause blocks consuming quick item")
	await capture("esc-home")
	check(root.get_visible_rect().encloses(Rect2(menu._panel.position, menu._panel.size * menu._panel.scale)), "Compact ESC fits viewport")
	var scroll: ScrollContainer = menu._body.get_node("ContentScroll")
	check(scroll.get_global_rect().encloses(menu._content.get_child(menu._content.get_child_count() - 1).get_global_rect()), "All home actions visible without scrolling")
	menu.open_settings()
	var baseline: float = root.get_node("GameSettings").values.sfx
	menu._edit("sfx", 0.12)
	await press(KEY_ESCAPE)
	check(menu._page == "home" and is_equal_approx(root.get_node("GameSettings").values.sfx, baseline), "ESC cancels settings preview")
	menu._show_inventory()
	await frames()
	await capture("inventory")
	var inventory_view = menu._content.get_child(0).get_child(0)
	check(scroll.get_global_rect().encloses(inventory_view.get_global_rect()), "Stardew-style inventory panel fits content area")
	check(inventory_view._grid.columns == 8 and inventory_view._grid.get_child_count() == 32, "Inventory renders eight-column icon grid")
	check(inventory_view._item_icon("iron_sword") != null and inventory_view._item_icon("minor_health_potion") != null, "Hearthmark equipment and consumable icons load")
	inventory_view._set_filter(1)
	check((inventory_view._grid.get_child(0) as Button).tooltip_text.begins_with("Kiếm sắt"), "Weapon tab filters the new item grid")
	inventory_view._set_filter(4)
	check((inventory_view._grid.get_child(0) as Button).tooltip_text.begins_with("Bình hồi phục nhỏ"), "Consumable tab filters the new item grid")
	inventory_view._set_filter(0)
	inventory_view._show_selected("iron_sword")
	inventory_view._equip_selected()
	check(manager.inventory.equipped.weapon == "iron_sword" and player.attack_damage == player._base_attack_damage + 1, "Inventory UI equips icon item and updates Player")
	check(inventory_view._equip_action.disabled, "Equipped item action disabled after refresh")
	check(menu._page == "inventory" and paused, "Inventory shares pause owner")
	check(root.get_visible_rect().encloses(Rect2(menu._panel.position, menu._panel.size * menu._panel.scale)), "Inventory fits viewport")
	await press(KEY_ESCAPE)
	check(menu._page == "home" and paused, "ESC returns inventory to home")
	await press(KEY_ESCAPE)
	check(not menu.is_open and not paused, "ESC resumes without stuck pause")
	await press(KEY_B)
	check(menu._page == "inventory" and paused, "Inventory hotkey opens bag")
	await press(KEY_B)
	check(not menu.is_open and not paused, "Inventory hotkey closes and resumes")
	await frames()
	check(dot.visible, "Idle dot restored after menu")

func _lock_on() -> void:
	var rig = load("res://scenes/camera/camera_rig.tscn").instantiate()
	rig.target = player
	stage.add_child(rig)
	rig.snap_to_target()
	rig.camera.make_current()
	var near_enemy := LockCandidate.new()
	near_enemy.add_to_group("enemies")
	near_enemy.position = Vector3(0, 0, 2)
	stage.add_child(near_enemy)
	var far_boss := LockCandidate.new()
	far_boss.name = "TestBoss"
	far_boss.add_to_group("enemies")
	far_boss.add_child(CanvasLayer.new())
	far_boss.get_child(0).name = "BossHUD"
	far_boss.position = Vector3(0, 0, -8)
	stage.add_child(far_boss)
	var near_boss := LockCandidate.new()
	near_boss.name = "NearBoss"
	near_boss.add_to_group("boss")
	near_boss.position = Vector3(0, 0, -4)
	stage.add_child(near_boss)
	check(rig._find_lock_target() == near_boss, "Lock selection prefers nearest boss over closer ordinary enemy")
	check(rig.toggle_lock_on() and rig.lock_target == near_boss, "First toggle locks onto selected boss")
	for frame in 24:
		await physics_frame
	var camera_to_boss: Vector3 = (near_boss.global_position + Vector3.UP - rig.camera.global_position).normalized()
	check(rig.camera.global_basis.z.normalized().dot(camera_to_boss) < -0.98, "Locked camera points its center at boss")
	check(not rig.toggle_lock_on() and rig.lock_target == null, "Second toggle releases camera lock")
	check(root.get_node("GameSettings").bindings.lock_on[0] == {"key": KEY_G}, "G is the default lock-on binding")
	near_boss.health = 0
	check(rig._find_lock_target() == far_boss, "Dead boss is skipped for next living boss")
	rig.toggle_lock_on()
	far_boss.queue_free()
	await frames()
	check(rig.lock_target == null, "Removed lock target clears active lock")
	check(rig._find_lock_target() == near_enemy, "Removed boss is skipped in favor of living enemy")
	var event := InputEventKey.new()
	event.physical_keycode = KEY_G
	event.pressed = true
	player._unhandled_input(event)
	check(rig.lock_target == near_enemy, "Player G input toggles camera lock")
	player._unhandled_input(event)
	check(rig.lock_target == null, "Player G input toggles camera unlock")
	rig.queue_free()
	near_enemy.queue_free()
	near_boss.queue_free()
	await frames()
