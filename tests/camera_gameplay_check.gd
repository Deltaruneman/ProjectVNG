extends Node
## Launch only in a disposable copy configured with a separate custom user directory.
## This loads the actual basement/Player/UI, then uses a remote test floor for input checks.
var failures := 0
var checks := 0
var stage: Node3D
var player: Player
var rig: CameraRig

func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
	print("PASS " if ok else "FAIL ", label)

func ticks(count: int = 3) -> void:
	for i in count:
		await get_tree().physics_frame
		await get_tree().process_frame

func capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("user://camera-%s.png" % label)

func key(code: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = pressed
	Input.parse_input_event(event)

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if not "ArcanaCamera-T079" in OS.get_user_data_dir():
		push_error("Refusing camera playtest without isolated user directory")
		get_tree().quit(2)
		return
	print("ISOLATED_USER_DATA ", OS.get_user_data_dir())
	stage = load("res://levels/level_1/basement_full.tscn").instantiate()
	add_child(stage)
	player = stage.get_node("Player")
	rig = stage.get_node("CameraRig")
	player.invincible = true
	await ticks(30)
	check(rig.target == player and rig.camera.is_current(), "basement binds current rig to actual Player")
	print("BASEMENT_START ", player.global_position, " CAMERA ", rig.camera.global_position)
	await capture("basement-start")
	# Exercise real gameplay input routing with HUD present, not a direct yaw assignment.
	rig._focused = true
	rig._process(0.016)
	var input_yaw: float = rig.yaw
	var motion := InputEventMouseMotion.new()
	motion.screen_relative = Vector2(120, 0)
	Input.parse_input_event(motion)
	await ticks(2)
	check(absf(angle_difference(input_yaw, rig.yaw)) > 0.1, "actual basement HUD passes captured mouse-look")
	var effect_point := player.global_position + Vector3(2, 1, 0)
	var charge_fx := BattleVFX.charge(player, effect_point, "fire")
	var meteor_fx := BattleVFX.play_pvfx(player, "fire/meteor-strike", effect_point, 1.5)
	check(charge_fx != null and meteor_fx != null, "existing PixelFX and PVFX sheets spawn in basement")
	if charge_fx != null and meteor_fx != null:
		var cast_screen_position: Vector2 = charge_fx.position
		rig.yaw += PI / 3.0
		await ticks(2)
		var projected := rig.camera.unproject_position(effect_point)
		check(charge_fx.position.distance_to(projected) < 8.0 and meteor_fx.position.distance_to(projected) < 8.0 and charge_fx.position.distance_to(cast_screen_position) > 15.0, "both old VFX types follow camera orbit")
	for index in 4:
		rig.yaw = index * PI / 2
		await ticks(10)
		check(rig.camera.global_transform.is_finite(), "basement orbit quadrant %d" % index)
		print("ORBIT_DISTANCE ", index, " ", rig.current_distance, " SPRITE_ALPHA ", player.sprite.modulate.a, " BLADE_ALPHA ", player.get_node("Direction/Blade/Sprite3D").modulate.a)
		await capture("basement-orbit-%d" % index)
	# Real Skill Tree input/pause lifecycle, without invoking progression callbacks.
	rig._previous_mouse_mode = Input.MOUSE_MODE_HIDDEN
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	key(KEY_T, true)
	key(KEY_T, false)
	await ticks(2)
	check(Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "Skill Tree opening explicitly shows previously hidden cursor")
	await ticks(90)
	check(get_tree().paused and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE, "actual Skill Tree keeps cursor visible")
	await capture("skill-tree")
	key(KEY_ESCAPE, true)
	key(KEY_ESCAPE, false)
	await ticks(90)
	check(not get_tree().paused, "actual Skill Tree closes and resumes")
	# Dialogue uses the real Player gate; no timeline or save is needed.
	player.start_talk()
	await ticks()
	check(Input.mouse_mode != Input.MOUSE_MODE_CAPTURED, "actual Player dialogue releases cursor")
	player.finish_talk()
	await ticks()
	check(player.can_control_camera(), "Player dialogue restores camera gate")
	var platform := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(80, 1, 80)
	collider.shape = shape
	platform.add_child(collider)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = shape.size
	mesh.mesh = box
	platform.add_child(mesh)
	stage.add_child(platform)
	platform.global_position = Vector3(1000, 9.5, 1000)
	player.global_position = Vector3(1000, 10.1, 1000)
	player.velocity = Vector3.ZERO
	rig.snap_to_target()
	await ticks(30)
	check(rig.global_position.distance_to(player.global_position + rig.focus_offset) < 0.5, "actual Player teleport follows without fly-through")
	rig.yaw = PI / 2
	rig.pitch = deg_to_rad(20)
	var start := player.global_position
	Input.action_press("up")
	await ticks(20)
	Input.action_release("up")
	var displacement := player.global_position - start
	check(displacement.x < -1.0 and absf(displacement.z) < 0.1, "W moves actual Player toward rotated camera forward")
	check(player.forward().dot(Vector3.LEFT) > 0.99, "actual attack forward matches movement")
	check(player._view_direction() == "up", "billboard animation faces forward in view space")
	Input.action_press("right")
	var aim := player.get_skill_aim_direction()
	Input.action_release("right")
	check(aim.dot(Vector3.LEFT) > 0.99, "implicit skill aim follows camera rather than lateral movement")
	check(player.get_node("Direction").basis.z.dot(aim) > 0.99, "hitbox orientation matches continuous aim")
	await ticks(5)
	Input.action_press("up")
	player.fsm.change_state(player.fsm.states.dash)
	await ticks(2)
	check(player.fsm.states.dash._dash_dir.dot(Vector3.LEFT) > 0.99, "actual dash follows orbit yaw")
	await ticks(20)
	Input.action_release("up")
	await capture("player-rotated")
	player.current_animation = "attack"
	player._next_animation = "attack"
	player.anim_player.play(player.get_animation_name())
	player.anim_player.seek(0.08, true)
	player._last_view_direction = player._view_direction()
	rig.yaw += PI / 2
	player._check_changed_animation()
	check(player.anim_player.current_animation_position >= 0.079, "orbit preserves attack animation phase")
	# Real Alt events update Input state, then the rig cursor policy runs next frame.
	rig._focused = true
	key(KEY_ALT, true)
	await ticks()
	check(Input.mouse_mode != Input.MOUSE_MODE_CAPTURED, "held Alt releases cursor")
	key(KEY_ALT, false)
	await ticks()
	check(Input.mouse_mode == Input.MOUSE_MODE_CAPTURED, "releasing Alt resumes mouse look")
	# The actual Player input path distinguishes a quick cast from a held camera-center aim.
	player.fsm.change_state(player.fsm.states.idle)
	player._active_skill_cooldowns.clear()
	player.face_movement(rig.camera.global_basis.z)
	Input.action_press("right")
	key(KEY_U, true)
	await ticks(5)
	check(player._skill_button_held and not player._skill_aim_active and not player._aim_reticle_layer.visible, "quick skill press waits without opening reticle")
	check(rig.aim_blend < 0.001, "quick skill press keeps normal camera framing")
	key(KEY_U, false)
	await ticks(3)
	Input.action_release("right")
	check(player.get_active_skill_cooldown_for_id(player.get_selected_active_skill_id()) > 0.0, "quick skill release casts normally")
	var quick_projectile: Skill = player.fsm.states.skill.active as Skill
	check(quick_projectile != null and quick_projectile.direction.dot((player._skill_aim_point - quick_projectile._start).normalized()) > 0.99, "quick cast uses hidden camera target despite opposing facing and lateral input")
	if is_instance_valid(player.fsm.states.skill.active):
		player.fsm.states.skill.active._finish()
	await ticks(30)
	player.fsm.change_state(player.fsm.states.idle)
	player._active_skill_cooldowns.clear()
	var normal_aim_camera_position: Vector3 = rig.camera.global_position
	key(KEY_U, true)
	await ticks(30)
	check(player._skill_aim_active and player._aim_reticle_layer.visible, "held skill opens center reticle after 0.3 seconds")
	check(rig.aim_blend > 0.85 and (rig.camera.global_position - normal_aim_camera_position).dot(rig.camera.global_basis.x) > 1.5, "held aim uses right-shoulder camera")
	var player_screen := rig.camera.unproject_position(player.global_position + Vector3.UP)
	check(player_screen.x < get_viewport().get_visible_rect().size.x * 0.5 - 45.0, "aimed Player remains left of center reticle")
	var aim_blocker := StaticBody3D.new()
	aim_blocker.collision_layer = 2
	var aim_shape := CollisionShape3D.new()
	var aim_box := BoxShape3D.new()
	aim_box.size = Vector3.ONE
	aim_shape.shape = aim_box
	aim_blocker.add_child(aim_shape)
	stage.add_child(aim_blocker)
	aim_blocker.global_position = rig.camera.global_position - rig.camera.global_basis.z * 10.0
	await ticks(3)
	check(player._skill_aim_point.distance_to(aim_blocker.global_position) < 1.1, "center sightline stops at blocking body")
	await capture("skill-aim-reticle")
	var aimed_point: Vector3 = player._skill_aim_point
	key(KEY_U, false)
	await ticks(2)
	var aimed_projectile: Skill = player.fsm.states.skill.active as Skill
	check(not player._aim_reticle_layer.visible and not player._skill_button_held, "aim reticle clears on release")
	check(aimed_projectile != null and aimed_projectile.direction.dot((aimed_point - aimed_projectile._start).normalized()) > 0.99, "held release throws toward center hit point with height")
	if is_instance_valid(aimed_projectile):
		aimed_projectile._finish()
	aim_blocker.queue_free()
	await ticks(30)
	check(rig.aim_blend < 0.05 and not rig._aim_requested, "skill release restores normal camera framing")
	player.fsm.change_state(player.fsm.states.idle)
	player._active_skill_cooldowns.clear()
	key(KEY_U, true)
	await ticks(24)
	player.start_talk()
	await ticks(2)
	check(not player._skill_button_held and not player._aim_reticle_layer.visible, "dialogue cancels held aim and removes reticle")
	key(KEY_U, false)
	player.finish_talk()
	await ticks(2)
	check(player.get_active_skill_cooldown_for_id(player.get_selected_active_skill_id()) <= 0.0, "cancelled hold does not cast on release")
	key(KEY_U, true)
	await ticks(24)
	get_tree().paused = true
	await get_tree().process_frame
	await get_tree().process_frame
	check(not player._skill_button_held and not player._aim_reticle_layer.visible, "pausing cancels held aim and removes reticle")
	get_tree().paused = false
	key(KEY_U, false)
	await ticks(2)
	check(player.get_active_skill_cooldown_for_id(player.get_selected_active_skill_id()) <= 0.0, "unpausing after cancelled aim does not cast")
	var blade := player.get_node("Direction/Blade")
	player.suppress_blade(false)
	var resting_blade_position: Vector3 = blade.position
	var pose := player.begin_ultimate_cinematic_pose()
	var away: Vector3 = -rig.camera.global_basis.z
	away.y = 0.0
	check((blade.global_position - player.global_position).dot(away.normalized()) > 0.8, "ultimate pose places blade behind Player relative to camera")
	check(blade.get_node("Sprite3D").visible, "ultimate pose keeps blade visible")
	await capture("ultimate-blade-behind")
	player.restore_ultimate_cinematic_pose(pose)
	check(blade.position.distance_to(resting_blade_position) < 0.12, "ultimate pose restores floating blade position")
	player.health = 0
	await ticks()
	check(Input.mouse_mode != Input.MOUSE_MODE_CAPTURED, "dead Player releases cursor")
	player.health = player.max_health
	print("RESULT gameplay_checks=%d failures=%d" % [checks, failures])
	# Leave a short inspection window; automatic checks do not assert manual feel acceptance.
	await get_tree().create_timer(3.0).timeout
	get_tree().quit(1 if failures else 0)
