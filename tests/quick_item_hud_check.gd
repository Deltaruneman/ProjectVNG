extends Node3D
const INVENTORY := preload("res://scripts/inventory_state.gd")
var checks := 0
var failures := 0
var player: Player
var hud: PlayerHUD

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
	print("PASS " if ok else "FAIL ", label)

func frames(count: int = 3) -> void:
	for i in count:
		await get_tree().process_frame

func q(echo: bool = false) -> void:
	for pressed in [true, false]:
		var event := InputEventKey.new()
		event.physical_keycode = KEY_Q
		event.keycode = KEY_Q
		event.pressed = pressed
		event.echo = echo and pressed
		Input.parse_input_event(event)
		await frames(2)

func capture(name: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("user://q-hud-" + name + ".png")

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not "ArcanaInventory" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	SaveSystem.save_path = "user://quick-item-hud-fixture.json"
	GameManager.reset()
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("242b36")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color.WHITE
	env.environment.ambient_light_energy = 0.9
	add_child(env)
	var floor_body := StaticBody3D.new()
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(30, 0.2, 30)
	collision.shape = box
	floor_body.add_child(collision)
	floor_body.position.y = -0.12
	add_child(floor_body)
	player = preload("res://scenes/player/player.tscn").instantiate()
	add_child(player)
	player.invincible = true
	var camera := Camera3D.new()
	add_child(camera)
	camera.position = Vector3(3, 3, 5)
	camera.look_at(Vector3(0, 0.7, 0))
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 7
	camera.current = true
	hud = preload("res://ui/hud.tscn").instantiate()
	add_child(hud)
	await frames(8)
	var potion := GameManager.grant_item("healing_potion", 3)
	check(GameManager.equip_item(potion), "assign owned potion into quick slot")
	check(GameManager.inventory.equipped.consumable == potion, "quick selection stored")
	check(InputMap.event_is_action(_key_event(KEY_Q), "quick_item"), "default physical Q bound")
	check(GameSettings.ACTIONS.has("quick_item"), "quick item supports settings rebinding")
	var bow := GameManager.grant_item("bow")
	check(not GameManager.equip_item(bow), "retired offhand cannot be equipped")
	# Build an actual legacy payload with paid ranks and equipped bow.
	GameManager.inventory.equipped.offhand = bow
	GameManager.inventory.items[bow].enchants.haste = 3
	GameManager.inventory.resonance_upgrades.fire = true
	GameManager.inventory.enchant_spent = 6
	GameManager.skill_allocations["offhand_fire"] = 1
	GameManager.skill_spending["offhand_fire"] = 2
	GameManager.save_game()
	var disk := SaveSystem.load_data()
	check(disk.inventory.equipped.consumable == potion and disk.inventory.items[potion].count == 3, "actual save file retains quick selection and stack")
	check(disk.skill_allocations.offhand_fire == 1 and disk.skill_spending.offhand_fire == 2, "actual save retains paid retired skill ranks and spending")
	var snapshot := GameManager.inventory.serialize()
	var restored := INVENTORY.new()
	restored.restore(JSON.parse_string(JSON.stringify(snapshot)))
	check(restored.equipped.consumable == potion, "quick slot survives JSON save roundtrip")
	check(restored.equipped.offhand == bow and restored.items[bow].enchants.haste == 3 and restored.enchant_spent == 6, "legacy offhand and spending retained")
	check(restored.enchant_rank("offhand", "haste") == 0, "legacy offhand stats inactive")
	check(restored.eligible_enchants(bow).is_empty(), "retired offhand cannot buy enchants")
	var old_snapshot := snapshot.duplicate(true)
	old_snapshot.equipped.erase("consumable")
	restored.restore(old_snapshot)
	check(restored.equipped.consumable == "" and restored.equipped.offhand == bow, "old save without quick slot remains valid")
	var stale_snapshot := snapshot.duplicate(true)
	stale_snapshot.equipped.consumable = bow
	restored.restore(stale_snapshot)
	check(restored.equipped.consumable == "", "restore rejects non-consumable quick reference")
	GameManager.inventory = INVENTORY.new()
	GameManager.inventory.restore(snapshot)
	check(not player.uses_offhand(), "old equipped bow never overrides skill 1")
	player.begin_offhand_cast()
	check(not is_instance_valid(player._offhand_cast_sprite), "legacy offhand cast sprite stays absent")
	check(not GameManager.buy_offhand_resonance("fire") and not GameManager.can_purchase_skill("offhand_fire"), "retired resonance purchases unavailable")
	for form: String in ["wind", "fire", "ice", "lightning"]:
		GameManager.weapon_form = form
		GameManager.unlocked_skills.append("active_%s_1" % form)
		check(player.get_active_skill_id_for_slot(1) == "active_%s_1" % form, "original skill-1 route " + form)
	GameManager.weapon_form = ""
	check(player.get_active_skill_id_for_slot(1) == "", "neutral uses original basic-dagger fallback")
	player.health = player.max_health - 1
	await q()
	check(player.health == player.max_health and GameManager.inventory.items[potion].count == 2, "real Q input heals and spends exactly one")
	await q()
	check(GameManager.inventory.items[potion].count == 2, "full health does not spend")
	player.health = player.max_health - 1
	await q(true)
	check(GameManager.inventory.items[potion].count == 2 and player.health < player.max_health, "repeat key event does not spend")
	player.is_talking = true
	await q()
	check(GameManager.inventory.items[potion].count == 2, "talking blocks Q")
	player.is_talking = false
	player.stamina_exhausted = true
	check(not GameManager.use_quick_item(), "exhaustion blocks quick item")
	player.stamina_exhausted = false
	get_tree().paused = true
	await q()
	check(GameManager.inventory.items[potion].count == 2 and not GameManager.use_quick_item(), "pause blocks Q and direct quick API")
	get_tree().paused = false
	player.health = 0
	check(not GameManager.use_quick_item(), "dead player cannot use potion")
	player.health = player.max_health - 1
	await q()
	player.health = player.max_health - 1
	await q()
	check(not GameManager.inventory.items.has(potion) and GameManager.inventory.equipped.consumable == "", "last potion removes stack and clears quick reference")
	check(not GameManager.use_quick_item(), "empty slot safely rejected")
	potion = GameManager.grant_item("healing_potion", 5)
	GameManager.equip_item(potion)
	player.stamina = 65
	player.stamina_changed.emit(65, Player.MAX_STAMINA)
	GameManager.weapon_form = "fire"
	GameManager.notify_inventory_changed()
	await frames(5)
	check(hud._quick_count.text == "5" and hud._quick_icon.texture != null, "HUD displays assigned art and count")
	var bar := hud.get_node("SkillBar") as Control
	check(hud._quick_panel.get_global_rect().end.x < bar.get_global_rect().position.x, "quick item visually separated left of skills")
	check(hud._stamina_bar.offset_bottom < bar.offset_top, "stamina remains above skill bar")
	await capture("wide")
	check(InventoryMenu.open_menu("consumables"), "consumables menu opens")
	InventoryMenu._select(potion)
	await frames(5)
	check(_has_button(InventoryMenu._root, "Bỏ khỏi ô Q"), "assigned potion offers remove-Q action")
	await capture("inventory")
	InventoryMenu._show_page("equipment")
	await frames(4)
	await capture("equipment")
	InventoryMenu._select(potion)
	check(InventoryMenu.page == "consumables", "equipment quick tile opens consumable detail")
	InventoryMenu.close_menu()
	await frames(5)
	GameManager.unequip_item("consumable")
	check(InventoryMenu.open_menu("consumables"), "consumables menu reopens")
	InventoryMenu._select(potion)
	await frames(4)
	check(_has_button(InventoryMenu._root, "Gán vào ô Q"), "unassigned potion offers assign-Q action")
	InventoryMenu.close_menu()
	await frames(5)
	GameManager.equip_item(potion)
	if DisplayServer.get_name() != "headless":
		get_window().size = Vector2i(900, 900)
		await frames(12)
		check(hud._quick_panel.get_global_rect().position.x >= 0, "square viewport keeps quick slot onscreen")
		await capture("square")
	print("QUICK_HUD_RESULT ", checks-failures, "/", checks)
	print("EVIDENCE_DIR ", OS.get_user_data_dir())
	get_tree().quit(0 if failures == 0 else 1)

func _key_event(code: Key) -> InputEventKey:
	var event := InputEventKey.new()
	event.physical_keycode = code
	return event

func _has_button(node: Node, text: String) -> bool:
	if node is Button and node.text == text:
		return true
	for child in node.get_children():
		if _has_button(child, text):
			return true
	return false
