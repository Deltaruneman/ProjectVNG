extends Node3D
## Only run in a disposable ArcanaViews project; no real saves/source imports.
var player: Player
var rig: CameraRig
var checks := 0
var failures := 0

func check(ok: bool, label: String) -> void:
	checks += 1
	failures += 0 if ok else 1
	print("PASS " if ok else "FAIL ", label)

func frames(count: int = 1) -> void:
	for i in count:
		await get_tree().physics_frame
		await get_tree().process_frame
		if DisplayServer.get_name() != "headless":
			await RenderingServer.frame_post_draw

func capture(label: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("user://depth-" + label + ".png")

func _ready() -> void:
	if not "ArcanaViews-20261119" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	SaveSystem.save_path = "user://topdown-depth-fixture.json"
	GameManager.reset()
	var environment := WorldEnvironment.new()
	environment.environment = Environment.new()
	environment.environment.background_mode = Environment.BG_COLOR
	environment.environment.background_color = Color("263344")
	environment.environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.environment.ambient_light_color = Color.WHITE
	environment.environment.ambient_light_energy = 0.9
	add_child(environment)
	var floor_body := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3(40, 0.2, 40)
	collider.shape = shape
	floor_body.add_child(collider)
	var mesh := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = shape.size
	mesh.mesh = box
	var material := StandardMaterial3D.new()
	material.albedo_color = Color("586471")
	mesh.material_override = material
	floor_body.add_child(mesh)
	floor_body.position.y = -0.1
	add_child(floor_body)
	player = preload("res://scenes/player/player.tscn").instantiate()
	add_child(player)
	player.invincible = true
	rig = preload("res://scenes/camera/camera_rig.tscn").instantiate()
	rig.target = player
	add_child(rig)
	await frames(10)
	player.set_physics_process(false)
	var attack: Node = player.get_node("States/Attack")
	var sprite := player.get_node("Direction/Blade/Sprite3D") as Sprite3D
	var body := player.get_node("Sprite3D") as Sprite3D
	for kind: String in ["sword", "axe", "spear", "dagger"]:
		GameManager.equip_item(GameManager.grant_item(kind))
		player._refresh_equipment_art()
		player.fsm.change_state(player.fsm.states.idle)
		player.fsm._update(0.0)
		player.fsm.change_state(attack)
		player.fsm._update(0.0)
		for facing: String in ["down", "left", "right", "up"]:
			player.face_movement(rig.movement_vector({"down": Vector2.DOWN, "up": Vector2.UP, "left": Vector2.LEFT, "right": Vector2.RIGHT}[facing]))
			player._apply_direction()
			player._check_changed_animation()
			for progress: float in [0.3, 0.45, 0.6, 0.85]:
				attack.call("_apply_combo_pose", progress, 0)
				var native: Vector3 = player.get_node("Direction/Blade").global_position
				var before_depth := (native - rig.camera.global_position).dot(-rig.camera.global_basis.z)
				var after_depth := (sprite.global_position - rig.camera.global_position).dot(-rig.camera.global_basis.z)
				var body_depth := (body.global_position - rig.camera.global_position).dot(-rig.camera.global_basis.z)
				var label := kind + " " + facing + " " + str(progress)
				if facing != "up":
					check(after_depth <= before_depth + 0.001 and sprite.global_position.y >= native.y - 0.001, "front weapon never pushed toward ground " + label)
					check(after_depth < body_depth - 0.04, "front weapon stays ahead of body " + label)
				else:
					check(after_depth > body_depth + 0.04, "back-facing body still covers weapon " + label)
				check(rig.camera.unproject_position(native).distance_to(rig.camera.unproject_position(sprite.global_position)) < 0.01 and not sprite.no_depth_test, "grip projection and terrain depth retained " + label)
				if facing == "down" and is_equal_approx(progress, 0.45):
					print("DEPTH_SAMPLE ", kind, " native_y=", native.y, " sprite_y=", sprite.global_position.y)
					await frames(2)
					await capture(kind + "-down")
		player.fsm.change_state(player.fsm.states.idle)
		player.fsm._update(0.0)
	# A legacy TPS request cannot change the fixed view or restore the old depth bug.
	rig.set_view_mode(CameraRig.ViewMode.TPS)
	await frames(3)
	player.change_direction("down")
	player._apply_direction()
	player.fsm.change_state(attack)
	player.fsm._update(0.0)
	attack.call("_set_weapon_pose", Vector3(0.2,1.0,0.4), Vector3(0,0,1))
	var delta_depth := (sprite.global_position - body.global_position).dot(-rig.camera.global_basis.z)
	check(rig.view_mode == CameraRig.ViewMode.TOP_DOWN and delta_depth < -0.04, "legacy TPS request preserves fixed view and safe front depth")
	player.fsm.change_state(player.fsm.states.idle)
	player.fsm._update(0.0)
	print("RESULT checks=%d failures=%d" % [checks, failures])
	get_tree().quit(1 if failures else 0)
