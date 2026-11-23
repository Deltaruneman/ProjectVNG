extends SceneTree

const ORB := preload("res://scenes/objects/elemental_orb.tscn")
var checks := 0
var failures := 0
var stage: Node3D
var player


func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
	print("PASS " if ok else "FAIL ", label)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	stage = Node3D.new()
	root.add_child(stage)
	current_scene = stage
	var camera := Camera3D.new()
	stage.add_child(camera)
	camera.position = Vector3(0, 6, 12)
	camera.look_at(Vector3(0, 1, 0))
	camera.make_current()
	player = load("res://scenes/player/player.tscn").instantiate()
	stage.add_child(player)
	player.set_physics_process(false)
	player.position = Vector3(0, 0, 0)
	var manager := root.get_node("GameManager")
	manager.skill_allocations = {"evo_wind_return": 1, "char_element": 2, "char_crit": 1}
	var state = player.fsm.states.skill
	for form in ["", "fire", "ice", "lightning", "wind"]:
		manager.weapon_form = form
		var skill_id: String = "active_%s_1" % form if form != "" else ""
		manager.unlocked_skills.clear()
		if skill_id != "":
			manager.unlocked_skills.append(skill_id)
		player.selected_active_slot = 1
		player._active_skill_cooldowns.clear()
		player._skill_aim_point = Vector3(6, 2, -3)
		player._cast_aim_point_valid = true
		var suppression_before: int = player._blade_suppress_count
		state._enter()
		var projectile: Node3D = state.active
		check(is_instance_valid(projectile), "%s spawned" % form)
		if not is_instance_valid(projectile):
			continue
		projectile.set_physics_process(false)
		var is_orb: bool = projectile.get_script() == load("res://scenes/objects/elemental_orb.gd")
		check(is_orb == (form != "wind"), "%s correct projectile routing" % form)
		var expected_direction := (Vector3(6, 2, -3) - projectile.global_position).normalized()
		check(projectile.direction.is_equal_approx(expected_direction), "%s 3D aim retained" % form)
		check(projectile.get_node("HitArea3D").damage == player.attack_damage + 3, "%s damage upgrades retained" % form)
		check(projectile.get_node("HitArea3D").hitted.is_connected(player._on_skill_hit.bind(form)), "%s elemental callback retained" % form)
		check(player.get_active_skill_cooldown_for_id(skill_id) > 0.0, "%s cooldown started" % form)
		if is_orb:
			check(not projectile.get_node("Sprite3D").visible, "%s dagger hidden" % form)
			check(player._blade_suppress_count == suppression_before, "%s equipped blade stays" % form)
			var visual: AnimatedSprite3D = projectile.get("_visual")
			check(is_instance_valid(visual), "%s effect exists" % form)
			check(visual.sprite_frames.get_frame_count("default") == 24, "%s animated orb" % form)
			check(not visual.no_depth_test, "%s depth tested" % form)
			var origin := projectile.global_position
			projectile._physics_process(0.1)
			check(projectile.global_position.is_equal_approx(origin + expected_direction * 1.4), "%s straight flight" % form)
			player.position += Vector3(-2, 0, 1)
			projectile._physics_process(0.1)
			check(projectile.global_position.is_equal_approx(origin + expected_direction * 2.8), "%s no homing toward thrower" % form)
			projectile._physics_process(1.0)
			check(projectile.is_queued_for_deletion() and not projectile.get("_returning"), "%s expires without returning" % form)
			check(projectile.global_position.distance_to(origin) <= 7.001, "%s existing range respected" % form)
			await process_frame
			await process_frame
			check(not is_instance_valid(visual), "%s visual cleanup" % form)
		else:
			check(projectile.max_distance == 8.75 and is_equal_approx(projectile.return_speed, 21.6), "Wind return upgrades retained")
			check(player._blade_suppress_count == suppression_before + 1, "Wind hides equipped blade")
			projectile._physics_process(1.0)
			check(projectile.get("_returning"), "Wind enters return phase")
			projectile.global_position = player.global_position + Vector3.UP * 0.8
			projectile._physics_process(0.01)
			check(projectile.is_queued_for_deletion(), "Wind caught")
			check(player._blade_suppress_count == suppression_before, "Wind restores blade")
		state._exit()
		player.position = Vector3.ZERO
		await process_frame
	await _wall_check()
	_aim_check(camera)
	var hud = load("res://ui/player_hud.gd").new()
	check(hud._skill_display_name("") == "Quả cầu trắng", "HUD neutral name")
	check(hud._skill_display_name("active_fire_1") == "Hỏa Cầu", "HUD fire name")
	check(hud._load_basic_projectile_icon("") is AtlasTexture, "HUD white orb icon")
	hud.free()
	var layout = load("res://ui/skill_tree_layout.gd")
	check(layout.ACTIVE_SKILLS.fire[0] == "Hỏa Cầu" and layout.ACTIVE_SKILLS.ice[0] == "Băng Cầu" and layout.ACTIVE_SKILLS.lightning[0] == "Lôi Cầu", "Skill Tree orb names")
	await _capture_orbs()
	if DisplayServer.get_name() != "headless":
		await _occlusion_check(camera)
	print("ORB RESULT: %d/%d checks passed" % [checks - failures, checks])
	stage.queue_free()
	await process_frame
	quit(0 if failures == 0 else 1)


func _aim_check(camera: Camera3D) -> void:
	var reticle = load("res://scenes/player/skill_aim_reticle.gd")
	for viewport_size in [Vector2(1280, 720), Vector2(1920, 1080), Vector2(1024, 768)]:
		var at: Vector2 = reticle.aim_screen_point(viewport_size)
		check(at.is_equal_approx(viewport_size * Vector2(0.5, 0.42)), "Raised aim scales with %s" % viewport_size)
	var expected: Vector2 = reticle.aim_screen_point(root.get_visible_rect().size)
	player.clear_skill_cast_aim()
	player._refresh_skill_aim_point()
	check(camera.unproject_position(player._skill_aim_point).is_equal_approx(expected), "Default ray matches raised reticle")
	var quick_target: Vector3 = player._skill_aim_point
	player._skill_aim_active = true
	player._refresh_skill_aim_point()
	check(player._skill_aim_point.is_equal_approx(quick_target), "Quick and held aim share raised target")
	player._skill_aim_active = false
	player._aim_reticle_layer.visible = true
	var player_screen := camera.unproject_position(player.global_position + Vector3.UP)
	check(player_screen.y > expected.y + 10.0, "Raised target lies above Player center")


func _occlusion_check(camera: Camera3D) -> void:
	player._aim_reticle_layer.visible = false
	var point := Vector3(0, 2.5, 0)
	var orb = ORB.instantiate()
	stage.add_child(orb)
	orb.position = point
	orb.setup(player, camera.global_basis.x)
	orb.set_physics_process(false)
	var sprite: AnimatedSprite3D = orb.get("_visual")
	sprite.stop()
	sprite.frame = 0
	await process_frame
	await RenderingServer.frame_post_draw
	var open_image := root.get_texture().get_image()
	# Camera coordinates are logical viewport pixels; screenshots use the window's physical size.
	var image_scale := Vector2(open_image.get_size()) / root.get_visible_rect().size
	var pixel := Vector2i(camera.unproject_position(point) * image_scale)
	open_image.save_png("res://docs/validation/elemental-orbs/depth-open.png")
	check(open_image.get_pixelv(pixel).r > 0.7, "Unobstructed orb core visible")
	var blocker := MeshInstance3D.new()
	var quad := QuadMesh.new()
	quad.size = Vector2(4, 2)
	blocker.mesh = quad
	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = Color(0.12, 0.18, 0.22)
	blocker.material_override = material
	stage.add_child(blocker)
	blocker.global_position = point + (camera.global_position - point).normalized() * 0.5
	blocker.global_basis = camera.global_basis
	await process_frame
	await RenderingServer.frame_post_draw
	var blocked_image := root.get_texture().get_image()
	check(blocked_image.get_pixelv(pixel).r < 0.3, "Foreground geometry hides orb instead of overlaying")
	blocked_image.save_png("res://docs/validation/elemental-orbs/depth-occlusion.png")
	blocker.queue_free()
	orb.queue_free()
	await process_frame


func _wall_check() -> void:
	var wall := StaticBody3D.new()
	wall.collision_layer = 1
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(0.2, 4, 4)
	shape.shape = box
	wall.add_child(shape)
	stage.add_child(wall)
	wall.position = Vector3(2, 1, 0)
	await physics_frame
	await physics_frame
	var orb = ORB.instantiate()
	stage.add_child(orb)
	orb.position = Vector3(0, 1, 0)
	orb.wall_mask = 1
	orb.setup(player, Vector3.RIGHT)
	orb.set_physics_process(false)
	orb._physics_process(0.2)
	check(orb.is_queued_for_deletion() and not orb.get("_returning"), "Wall expires orb without return")
	check(orb.global_position.x < 2, "Orb does not pass through wall")
	wall.queue_free()
	await process_frame


func _capture_orbs() -> void:
	var orbs: Array[Node3D] = []
	for i in 4:
		var orb = ORB.instantiate()
		orb.elemental_form = ["", "fire", "ice", "lightning"][i]
		stage.add_child(orb)
		orb.position = Vector3(-3 + i * 2, 2.5, 0)
		orb.setup(player, Vector3.RIGHT)
		orb.set_physics_process(false)
		orbs.append(orb)
	await create_timer(0.15).timeout
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png("res://docs/validation/elemental-orbs/rendered-orbs.png")
	for orb in orbs:
		orb.queue_free()
	await process_frame
