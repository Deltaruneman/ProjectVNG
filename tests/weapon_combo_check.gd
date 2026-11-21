extends Node3D

var player: Player
var state: Node
var camera: Camera3D
var checks := 0
var failures := 0
var contacts := 0

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
	print("PASS " if ok else "FAIL ", label)

func frames(count: int = 1) -> void:
	for i in count:
		await get_tree().physics_frame
		await get_tree().process_frame

func phase(value: int, max_frames: int = 180) -> bool:
	for i in max_frames:
		if state.get("_phase") == value and player.fsm.current_state == state:
			return true
		await frames()
	return false

func click() -> void:
	Input.action_press("attack")
	await frames(2)
	Input.action_release("attack")
	await frames(2)

func capture(label: String) -> void:
	if DisplayServer.get_name() == "headless":
		return
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("user://combo-" + label + ".png")

func fresh(kind: String) -> void:
	Input.action_release("attack")
	if is_instance_valid(player):
		player.queue_free()
		await frames(3)
	var uid := ""
	if kind == "starter_blade":
		for candidate: String in GameManager.inventory.items:
			if GameManager.inventory.items[candidate].definition == kind:
				uid = candidate
				break
	if uid == "":
		uid = GameManager.grant_item(kind)
	GameManager.equip_item(uid)
	player = preload("res://scenes/player/player.tscn").instantiate()
	add_child(player)
	player.invincible = true
	await frames(5)
	state = player.get_node("States/Attack")

func _ready() -> void:
	if not "ArcanaInventory" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	SaveSystem.save_path = "user://weapon-combo-fixture.json"
	GameManager.reset()
	for effect: String in ["melee/sword-slash", "melee/thrust", "melee/spear-sweep", "melee/dagger-flurry", "impacts/ground-slam"]:
		check(BattleVFX._load_pixelfx_frames(effect) != null, "attack VFX frames load " + effect)
	var env := WorldEnvironment.new()
	env.environment = Environment.new()
	env.environment.background_mode = Environment.BG_COLOR
	env.environment.background_color = Color("242b3d")
	env.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.environment.ambient_light_color = Color.WHITE
	env.environment.ambient_light_energy = 0.8
	add_child(env)
	var sun := DirectionalLight3D.new()
	add_child(sun)
	sun.rotation_degrees = Vector3(-45, -25, 0)
	var floor_body := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(30, 0.2, 30)
	collider.shape = box
	floor_body.add_child(collider)
	floor_body.position.y = -0.12
	add_child(floor_body)
	camera = Camera3D.new()
	add_child(camera)
	camera.position = Vector3(4, 5, 7)
	camera.look_at(Vector3(0, 0.9, 0))
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 5.0
	camera.current = true
	if OS.get_cmdline_user_args().has("--pose-only"):
		await fresh("starter_blade")
		player.fsm.change_state(state)
		await frames(1)
		state.call("_play_attack_pose", 0.5)
		print("POSE legacy id=", GameManager.inventory.id_for_slot("main"), " legacy=", state.get("_legacy_blade"), " body=", player.current_animation)
		await fresh("sword")
		player.fsm.change_state(state)
		await frames(1)
		state.call("_play_attack_pose", 0.5)
		print("POSE sword id=", GameManager.inventory.id_for_slot("main"), " legacy=", state.get("_legacy_blade"), " body=", player.current_animation)
		get_tree().quit()
		return
	if OS.get_cmdline_user_args().has("--aerial-only"):
		await _aerial_and_depth_checks()
		print("AERIAL_RESULT ", checks-failures, "/", checks)
		get_tree().quit(0 if failures == 0 else 1)
		return
	if OS.get_cmdline_user_args().has("--stamina-only"):
		await _stamina_checks()
		print("STAMINA_RESULT ", checks-failures, "/", checks)
		get_tree().quit(0 if failures == 0 else 1)
		return
	for kind: String in ["sword", "axe", "spear", "dagger"]:
		await fresh(kind)
		var count: int = {"sword":3,"axe":3,"spear":4,"dagger":1}[kind]
		await click()
		var first_phase := 7 if count > 1 else 6
		check(await phase(first_phase), kind + " first click completes one strike")
		check(state.get("_strike_index") == 0, kind + " one click stays at strike 1")
		if count > 1:
			await frames(4)
			check(state.get("_strike_index") == 0, kind + " never auto advances")
			for index in range(1, count):
				await click()
				var final_strike := index == count - 1
				check(await phase(6 if final_strike else 7), kind + " click finishes next strike")
				check(state.get("_strike_index") == index, kind + " click sequence " + str(index + 1))
		else:
			check(state.get("_phase") == 6, kind + " single-strike chain enters recovery")
		await frames(32)
		check(player.fsm.current_state != state, kind + " combo recovery ends")
		check(player.anim_player.speed_scale == 1.0, kind + " animation speed restored")
		await click()
		check(await phase(7 if count > 1 else 6), kind + " new combo after recovery")
		check(state.get("_strike_index") == 0, kind + " timeout resets index")
	await fresh("sword")
	await click()
	await frames(4)
	await click()
	check(await phase(7), "one early buffered click is consumed")
	check(state.get("_strike_index") == 1, "buffer advances exactly once")
	await frames(90)
	check(player.fsm.current_state != state, "buffer does not auto chain third strike")
	await fresh("sword")
	var target := HurtArea3D.new()
	target.collision_layer = 16
	target.collision_mask = 0
	var target_shape := CollisionShape3D.new()
	var target_box := BoxShape3D.new()
	target_box.size = Vector3(8, 4, 8)
	target_shape.shape = target_box
	target.add_child(target_shape)
	target.hurt.connect(func(_direction: Vector3, _damage: float) -> void: contacts += 1)
	add_child(target)
	await frames(3)
	await click()
	check(await phase(7), "actual hit window completes")
	check(contacts == 1, "one click damages overlapping target exactly once")
	await click()
	check(await phase(7), "second actual hit completes")
	check(contacts == 2, "second click rearms target once")
	await frames(45)
	check(contacts == 2, "no automatic third hit")
	target.queue_free()
	await fresh("sword")
	state.call("_play_attack_pose", 0.5)
	check(player.current_animation == "run", "non-Blade uses compact attack-like weapon pose instead of raised-arm attack clip")
	await fresh("starter_blade")
	var legacy_weapon := player.get_node("Direction/Blade") as Node3D
	player.fsm.change_state(state)
	await frames(1)
	var legacy_home := legacy_weapon.position
	state.call("_play_attack_pose", 0.5)
	check(player.current_animation == "attack", "legacy Blade keeps the original attack animation")
	state.call("_apply_combo_pose", 0.5, 0)
	check(not legacy_weapon.visible, "legacy Blade stays hidden during the Player attack animation")
	check(legacy_weapon.position.distance_to(legacy_home) < 0.001, "legacy Blade does not fly into the attack pose")
	player.fsm.change_state(player.fsm.states.idle)
	await frames(2)
	check(legacy_weapon.visible, "legacy Blade returns after its Player attack animation")
	await fresh("sword")
	Input.action_press("attack")
	await frames(32)
	Input.action_release("attack")
	await frames(2)
	check(state.get("_phase") == 2, "hold-release chooses charge rather than normal combo")
	player.fsm.change_state(player.fsm.states.idle)
	await frames(3)
	check(not player.get_node("Direction/Blade/Sprite3D").offset.length() > 0.01, "interrupt restores sprite grip offset")
	check(player.get_node("Direction/Blade").is_processing(), "interrupt restores floating process")
	check(player.get_node("Direction/HitArea3D/CollisionShape3D").disabled, "interrupt disables hitbox")
	# Source blade axis must project in the requested attack direction for every facing/yaw.
	for kind: String in ["sword", "spear", "starter_blade"]:
		await fresh(kind)
		await click()
		for yaw in [0.0, PI * 0.5, PI]:
			camera.position = Vector3(0, 5, 7).rotated(Vector3.UP, yaw)
			camera.look_at(Vector3(0, 0.9, 0))
			for facing: String in ["up", "down", "left", "right"]:
				player.change_direction(facing)
				player._apply_direction()
				state.call("_set_weapon_pose", Vector3(0.2, 1, 0.4), Vector3(0, 0, 1))
				var weapon := player.get_node("Direction/Blade") as Node3D
				var source_angle: float = state.get("_source_tip_angle")
				var tip := weapon.global_basis * Vector3(cos(source_angle), sin(source_angle), 0)
				var wanted: Vector3 = player.get_node("Direction").global_basis.z
				var a := Vector2(tip.dot(camera.global_basis.x), tip.dot(camera.global_basis.y)).normalized()
				var b := Vector2(wanted.dot(camera.global_basis.x), wanted.dot(camera.global_basis.y)).normalized()
				check(a.dot(b) > 0.999, kind + " correct tip " + facing + " camera " + str(yaw))
	await _aerial_and_depth_checks()
	await _normal_combo_recovery_check()
	await _spear_fx_direction_check()
	# Render actual first/second/third sword strike and thrust at their contact phase.
	camera.position = Vector3(4, 5, 7)
	camera.look_at(Vector3(0, 0.9, 0))
	for kind: String in ["sword", "axe", "spear", "dagger"]:
		await fresh(kind)
		await click()
		player.set_physics_process(false)
		for index in int(state.get("_combo_count")):
			for t in [0.2, 0.5, 0.85]:
				state.call("_apply_combo_pose", t, index)
				state.call("_play_attack_pose", t)
				await frames(2)
				await capture(kind + "-" + str(index) + "-" + str(t))
		state.call("_exit")
	print("WEAPON_COMBO_RESULT ", checks - failures, "/", checks, " failures=", failures)
	get_tree().quit(0 if failures == 0 else 1)


func _normal_combo_recovery_check() -> void:
	await fresh("sword")
	for index in 2:
		await click()
		check(await phase(7), "combo link setup strike " + str(index + 1))
	await click()
	await frames(1)
	await click() # Deliberate fourth click while the third strike is still running.
	check(await phase(6), "completed combo enters recovery after final strike")
	check(state.get("_phase") == 6, "completed combo enters recovery")
	check(is_equal_approx(float(state.get("_recovery_lock_duration")), 0.5), "completed three-click combo recovery is half a second")
	check(not bool(state.get("_buffered")), "fourth spam click is discarded at combo end")
	for index in 3:
		await click()
		check(player.fsm.current_state == state and state.get("_phase") == 6, "spam click cannot bypass combo recovery " + str(index + 1))
	await frames(32)
	check(player.fsm.current_state != state, "player returns to control after combo recovery")
	await click()
	check(player.fsm.current_state == state, "fresh click after recovery starts a new combo")


func _spear_fx_direction_check() -> void:
	await fresh("spear")
	# Earlier combo fixtures can leave short-lived VFX on the shared stage;
	# remove those before this isolated placement capture.
	for existing: Node in get_tree().current_scene.get_children():
		if existing.name.begins_with("WeaponAttackFX_"):
			existing.queue_free()
	await frames(1)
	player.fsm.change_state(state)
	await frames(1)
	state.set("_strike_index", 2)
	state.call("_apply_combo_pose", 0.35, 2)
	var expected_direction: Vector3 = state.call("_world_weapon_tip_direction")
	var expected_position: Vector3 = state.call("_weapon_fx_position", expected_direction)
	state.call("_spawn_strike_fx", false)
	var effect: AnimatedSprite3D
	for child: Node in get_children():
		if child is AnimatedSprite3D and child.name.begins_with("WeaponAttackFX_melee_spear-sweep"):
			effect = child as AnimatedSprite3D
			break
	check(effect != null, "spear sweep effect is created")
	if effect != null:
		check(effect.billboard == BaseMaterial3D.BILLBOARD_DISABLED, "weapon FX keeps its explicitly rotated camera-facing plane")
		var body := player.get_node("Sprite3D") as Sprite3D
		var body_depth := (body.global_position - camera.global_position).dot(-camera.global_basis.z)
		var effect_depth := (effect.global_position - camera.global_position).dot(-camera.global_basis.z)
		check(effect_depth > body_depth + 0.04, "weapon attack FX remains behind Player at every facing")
		var effect_direction: Vector3 = effect.get_meta("world_direction")
		check(effect_direction.dot(expected_direction) > 0.99, "spear sweep follows the equipped spear tip direction")
		var weapon_axis := (state.get("_weapon") as Node3D).global_basis * Vector3(cos(float(state.get("_source_tip_angle"))), sin(float(state.get("_source_tip_angle"))), 0.0)
		var weapon_screen_axis := Vector2(weapon_axis.dot(camera.global_basis.x), weapon_axis.dot(camera.global_basis.y)).normalized()
		var effect_screen_axis := Vector2(effect.global_basis.x.dot(camera.global_basis.x), effect.global_basis.x.dot(camera.global_basis.y)).normalized()
		check(effect_screen_axis.dot(weapon_screen_axis) > 0.99, "rendered spear FX axis matches rendered weapon axis")
		check(camera.unproject_position(effect.global_position).distance_to(camera.unproject_position(expected_position)) < 1.0, "spear sweep spawns along the actual weapon pose")
		await capture("spear-sweep-heading")


func _stamina_checks() -> void:
	await fresh("sword")
	for existing_hud: Node in get_tree().get_nodes_in_group("hud"):
		existing_hud.hide()
	var hud := preload("res://ui/hud.tscn").instantiate() as PlayerHUD
	add_child(hud)
	await frames(2)
	var bar := hud.get_node("StaminaBar") as ProgressBar
	check(bar.max_value == Player.MAX_STAMINA and bar.value == Player.MAX_STAMINA and not bar.visible, "full stamina bar hides beside health")
	var skill_bar := hud.get_node("SkillBar") as Control
	check(bar.offset_bottom < skill_bar.offset_top and is_equal_approx(bar.offset_left, skill_bar.offset_left), "stamina bar sits directly above centered skill bar")
	Input.action_press("dash")
	await frames(3)
	Input.action_release("dash")
	check(is_equal_approx(player.stamina, 80.0), "dash spends 20 stamina")
	check(player.fsm.current_state == player.fsm.states.dash, "dash state starts")
	check(bar.visible and bar.value <= 80.0, "spent stamina appears below health")
	await capture("stamina-dash-hud")
	hud.queue_free()
	await frames(2)
	await fresh("sword")
	player.parry_cooldown_timer = 0.0
	Input.action_press("parry")
	await frames(3)
	Input.action_release("parry")
	check(is_equal_approx(player.stamina, 85.0) and player.fsm.current_state == player.fsm.states.parry, "parry spends 15 stamina")
	await fresh("sword")
	await _charge()
	check(state.get("_phase") == 2 and is_equal_approx(player.stamina, 75.0), "charged attack spends 25 stamina")
	await fresh("sword")
	player.stamina = 10.0
	player._stamina_regen_delay = 5.0
	player.dash_cooldown_timer = 0.0
	Input.action_press("dash")
	await frames(2)
	Input.action_release("dash")
	check(player.fsm.current_state != player.fsm.states.dash and is_equal_approx(player.stamina, 10.0), "insufficient stamina blocks dash")
	player.parry_cooldown_timer = 0.0
	Input.action_press("parry")
	await frames(2)
	Input.action_release("parry")
	check(player.fsm.current_state != player.fsm.states.parry and is_equal_approx(player.stamina, 10.0), "insufficient stamina blocks parry")
	await _charge()
	check(state.get("_phase") == 1 and is_equal_approx(player.stamina, 10.0), "insufficient stamina turns charge hold into normal strike")
	player.stamina = 50.0
	player._stamina_regen_delay = Player.STAMINA_REGEN_DELAY
	player._update_stamina(0.69)
	check(is_equal_approx(player.stamina, 50.0), "stamina waits through regen delay")
	player._stamina_regen_delay = 0.0
	player._update_stamina(0.4)
	check(is_equal_approx(player.stamina, 60.0), "stamina regenerates at 25 per second")
	await frames(2)
	await fresh("sword")
	player.stamina = Player.STAMINA_DASH_COST
	var paid_last_stamina := player.try_spend_stamina(Player.STAMINA_DASH_COST)
	player._stamina_regen_delay = 2.0
	check(not paid_last_stamina and player.stamina == 0.0 and player.stamina_exhausted, "spending to zero triggers exhaustion and refuses final action")
	await frames(2)
	var exhausted_state: Node = player.fsm.states.staminaexhausted
	check(player.fsm.current_state == exhausted_state and not player._can_start_skill_cast() and not player.can_interact(), "exhaustion enters locked state and blocks skill/interact")
	var start_position := player.global_position
	Input.action_press("right")
	Input.action_press("attack")
	Input.action_press("dash")
	Input.action_press("parry")
	await frames(30)
	Input.action_release("right")
	Input.action_release("attack")
	Input.action_release("dash")
	Input.action_release("parry")
	check(player.fsm.current_state == exhausted_state and Vector2(player.global_position.x - start_position.x, player.global_position.z - start_position.z).length() < 0.05, "one-second exhaustion blocks movement and combat actions")
	await frames(40)
	check(player.fsm.current_state != exhausted_state and not player.stamina_exhausted, "exhaustion ends after one second")



func _charge() -> void:
	Input.action_press("attack")
	await frames(30)
	Input.action_release("attack")
	await frames(2)


func _obstacle(at: Vector3, size: Vector3) -> StaticBody3D:
	var body := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	collider.shape = box
	body.add_child(collider)
	add_child(body)
	body.position = at
	return body


func _aerial_and_depth_checks() -> void:
	camera.position = Vector3(4, 5, 7)
	camera.look_at(Vector3(0, 0.9, 0))
	for kind: String in ["dagger", "axe"]:
		await fresh(kind)
		var enemy := preload("res://scenes/enemies/crab/crab.tscn").instantiate() as EnemyCharacter
		enemy.max_health = 100
		enemy.exp_point_drop = 0
		enemy.position = Vector3(0, 0, 2.7 if kind == "dagger" else 1.8)
		add_child(enemy)
		enemy.fsm._update(0.0)
		enemy.set_physics_process(false)
		await frames(2)
		enemy.set_physics_process(false)
		var start := player.position
		await _charge()
		var peak := 0.0
		var return_peak := 0.0
		var outbound := 0.0
		var landing_hit := true
		var saw_return := false
		var saw_hit := false
		var used_attack := false
		var down_streak := false
		var upright_ring := false
		var fx_behind_player := false
		var captured_air := false
		var captured_hit := false
		for i in 140:
			if player.fsm.current_state != state:
				break
			peak = maxf(peak, player.position.y - start.y)
			outbound = maxf(outbound, Vector2(player.position.x - start.x, player.position.z - start.z).length())
			if state.get("_phase") == 5:
				saw_return = true
				return_peak = maxf(return_peak, player.position.y - start.y)
			if state.get("_hit_active"):
				saw_hit = true
				used_attack = player.current_animation == ("attack" if bool(state.get("_legacy_blade")) else "run")
				if kind == "axe":
					for candidate in get_children():
						if not candidate is AnimatedSprite3D or not candidate.name.begins_with("WeaponAttackFX_"):
							continue
						var effect := candidate as AnimatedSprite3D
						var effect_direction: Vector3 = effect.get_meta("world_direction", Vector3.ZERO)
						if effect.name.ends_with("melee_thrust") and effect_direction == Vector3.DOWN:
							down_streak = true
						if effect.name.ends_with("impacts_ground-slam") and effect_direction == Vector3.ZERO:
							upright_ring = true
						var body_position: Vector3 = (player.get_node("Sprite3D") as Sprite3D).global_position
						var body_depth: float = (body_position - camera.global_position).dot(-camera.global_basis.z)
						var effect_depth: float = (effect.global_position - camera.global_position).dot(-camera.global_basis.z)
						if not effect.no_depth_test and effect_depth > body_depth + 0.05:
							fx_behind_player = true
				if kind == "axe" and not player.is_on_floor():
					landing_hit = false
			if peak > 0.6 and not captured_air:
				await capture("air-" + kind)
				captured_air = true
			if saw_hit and not captured_hit:
				await capture("impact-" + kind)
				captured_hit = true
			await frames()
		check(peak > 0.5, kind + " physically airborne")
		check(saw_hit, kind + " has impact window")
		check(used_attack, kind + " impact uses its assigned Player body motion")
		check(player.fsm.current_state != state, kind + " charge terminates")
		check(enemy.health < 100, kind + " charge damages actual crab")
		if kind == "dagger":
			print("DAGGER_AIR peak=", peak, " outward=", outbound, " return=", return_peak, " saw=", saw_return, " end=", player.position)
			check(outbound > 0.8 and saw_return and return_peak > 0.5, "dagger has separate outward and return airborne arcs")
			check(Vector2(player.position.x - start.x, player.position.z - start.z).length() < 0.2, "dagger returns near starting point")
		else:
			check(landing_hit, "axe damage opens only on ground after jump")
			check(down_streak, "axe streak points down at impact")
			check(upright_ring, "axe ground shock stays upright at impact")
			check(fx_behind_player, "weapon attack effects depth-test behind Player")
		enemy.queue_free()
		await frames(4)
	# Dagger wall obstruction and axe low ceiling must recover without teleporting.
	for kind: String in ["dagger", "axe"]:
		await fresh(kind)
		var block := _obstacle(Vector3(0, 2, 1.7), Vector3(5, 4, 0.2)) if kind == "dagger" else _obstacle(Vector3(0, 2.6, 0), Vector3(5, 0.2, 5))
		await frames(2)
		await _charge()
		var max_z := player.position.z
		for i in 160:
			max_z = maxf(max_z, player.position.z)
			if player.fsm.current_state != state:
				break
			await frames()
		check(player.fsm.current_state != state, kind + " obstruction recovers")
		check(max_z < 1.0 if kind == "dagger" else player.position.y < 0.2, kind + " respects physical blocker")
		block.queue_free()
		await frames(3)
	await fresh("dagger")
	await _charge()
	await frames(3)
	player.fsm.change_state(player.fsm.states.idle)
	await frames(45)
	check(player.is_on_floor() and player.position.y < 0.2, "interrupted flight falls to ground")
	check(player.get_node("Direction/Blade").is_processing(), "flight interruption restores floating weapon")
	# Active weapon sprites follow the camera-relative up/back Player layer rule.
	await fresh("sword")
	await click()
	for projection in [Camera3D.PROJECTION_ORTHOGONAL, Camera3D.PROJECTION_PERSPECTIVE]:
		camera.projection = projection
		for facing in ["up", "down", "left", "right"]:
			player.change_direction(facing)
			player._apply_direction()
			await frames(1)
			state.call("_set_weapon_pose", Vector3(0.2, 1, 0.4), Vector3(0,0,1))
			var sprite := player.get_node("Direction/Blade/Sprite3D") as Sprite3D
			var body := player.get_node("Sprite3D") as Sprite3D
			var depth_delta: float = (sprite.global_position-body.global_position).dot(-camera.global_basis.z)
			check(depth_delta > 0.04 if facing == "up" else depth_delta < -0.04, "active main depth follows " + facing + " facing " + str(projection))
		GameManager.inventory.equipped.offhand = GameManager.grant_item("bow")
		player.begin_offhand_cast()
		check(not is_instance_valid(player._offhand_cast_sprite), "retired offhand remains invisible " + str(projection))
		player.end_offhand_cast()
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	if DisplayServer.get_name() != "headless":
		player.set_physics_process(false)
		player.get_node("Direction/Blade").hide()
		await RenderingServer.frame_post_draw
		var before := get_viewport().get_texture().get_image()
		var quad := Sprite3D.new()
		var pixels := Image.create(8,8,false,Image.FORMAT_RGBA8)
		pixels.fill(Color.RED)
		quad.texture = ImageTexture.create_from_image(pixels)
		quad.pixel_size = 0.5
		add_child(quad)
		quad.global_basis = camera.global_basis
		quad.global_position = player.global_position + Vector3.UP * 0.9
		player.change_direction("up")
		player._apply_direction()
		player.place_weapon_below_body(quad)
		await frames(3)
		await RenderingServer.frame_post_draw
		var after := get_viewport().get_texture().get_image()
		var center := camera.unproject_position(player.global_position + Vector3.UP * 0.95)
		var changed := 0
		var samples := 0
		var bg := before.get_pixel(500,150)
		for x in range(int(center.x)-70,int(center.x)+70,3):
			for y in range(int(center.y)-70,int(center.y)+70,3):
				var old := before.get_pixel(x,y)
				if old != bg:
					samples += 1
					if old != after.get_pixel(x,y):
						changed += 1
		check(samples > 40 and changed == 0, "rendered Player silhouette occludes overlapping active weapon pixels")
		await capture("body-over-weapon")
		quad.queue_free()
		state.call("_exit")
