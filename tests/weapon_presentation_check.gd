extends "res://tests/weapon_combo_check.gd"

func _ready() -> void:
	if not "ArcanaInventory" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	SaveSystem.save_path = "user://weapon-presentation-fixture.json"
	GameManager.reset()
	var floor_body := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(30,0.2,30)
	collider.shape = box
	floor_body.add_child(collider)
	floor_body.position.y = -0.12
	add_child(floor_body)
	var aim_target := Node3D.new()
	add_child(aim_target)
	var rig := preload("res://scenes/camera/camera_rig.tscn").instantiate() as CameraRig
	rig.target = aim_target
	add_child(rig)
	rig.set_process(false)
	rig.set_physics_process(false)
	rig.set_process_input(false)
	rig.set_view_mode(CameraRig.ViewMode.TOP_DOWN)
	camera = rig.get_node("Camera3D")
	camera.position = Vector3(4,7,7)
	camera.look_at(Vector3(0,1,0))
	camera.current = true
	if OS.get_cmdline_user_args().has("--attack-mirror-only"):
		await _attack_mirror_check(rig)
		return
	for kind: String in ["starter_blade", "sword", "axe", "spear", "dagger"]:
		await fresh(kind)
		player.set_physics_process(false)
		var sprite := player.get_node("Direction/Blade/Sprite3D") as Sprite3D
		var body := player.get_node("Sprite3D") as Sprite3D
		for facing: String in ["up", "down", "left", "right"]:
			player.change_direction(facing)
			player._apply_direction()
			await frames(3)
			var grip: Vector3 = player.get_node("Direction/Blade").global_position
			check(grip.distance_to(player.global_position) < 1.0, kind + " rests at hand " + facing)
		rig.set_view_mode(CameraRig.ViewMode.TPS)
		await frames(2)
		check(rig.view_mode == CameraRig.ViewMode.TOP_DOWN, kind + " removed TPS request keeps fixed view")
		rig.view_mode = CameraRig.ViewMode.TOP_DOWN
		await frames(2)
		var expected_scale := sprite.global_basis.get_scale()
		var expected_pixel := sprite.pixel_size
		var expected_texture := sprite.texture
		GameManager.weapon_form = ""
		player.selected_active_slot = 1
		player.set_physics_process(true)
		player.fsm.change_state(player.fsm.states.skill)
		await frames(2)
		var drops := get_tree().get_nodes_in_group("thrown_weapons")
		check(drops.size() == 1, kind + " launches")
		if not drops.is_empty():
			var drop = drops[0]
			check(drop.visual.texture == expected_texture and is_equal_approx(drop.visual.pixel_size, expected_pixel), kind + " preserves equipped texture and pixel size")
			check(drop.visual.global_basis.get_scale().is_equal_approx(expected_scale), kind + " spinning flight preserves equipped world scale")
			drop.queue_free()
		GameManager.flags.thrown_main_weapon = {}
		await frames(2)
	print("PRESENTATION_RESULT ", checks-failures, "/", checks)
	get_tree().quit(0 if failures == 0 else 1)


func _attack_mirror_check(rig: CameraRig) -> void:
	for kind: String in ["starter_blade", "sword", "axe", "spear", "dagger"]:
		await fresh(kind)
		for side in [Vector2.LEFT, Vector2.RIGHT]:
			var label := kind + ("-left" if side.x < 0 else "-right")
			player.attack_input_cooldown = 0.0
			player.face_movement(rig.movement_vector(side))
			player.call("_check_changed_direction")
			await frames(3)
			var blade := player.get_node("Direction/Blade") as Node3D
			var sprite := blade.get_node("Sprite3D") as Sprite3D
			var held_flip := sprite.flip_h
			Input.action_press("attack")
			await frames(2)
			Input.action_release("attack")
			check(await phase(state.PHASE_COMBO), label + " real input enters attack")
			var worst_dot := 1.0
			var grip_error := 0.0
			var samples := 0
			for i in 8:
				await frames(1)
				if player.fsm.current_state != state or state._phase != state.PHASE_COMBO: break
				var source_angle := PI / 2.0 if kind == "starter_blade" else 3.0 * PI / 4.0
				if sprite.flip_h: source_angle = PI - source_angle
				var actual := (sprite.global_basis * Vector3(cos(source_angle), sin(source_angle), 0)).normalized()
				var intended: Vector3 = player.get_node("Direction").global_basis * state._last_tip
				var view := camera.global_basis
				var projected := view.x * intended.dot(view.x) + view.y * intended.dot(view.y)
				if projected.length_squared() > 0.001:
					if actual.dot(projected.normalized())<0.999:
						print("TIP_DIAGNOSTIC ",label," actual=",actual," intended=",projected.normalized()," last=",state._last_tip," sprite_flip=",sprite.flip_h," source_angle=",state._source_tip_angle)
					worst_dot = minf(worst_dot,actual.dot(projected.normalized()))
				var size := sprite.texture.get_size()
				var expected := Vector2(0,size.y*0.3) if kind == "starter_blade" else Vector2(-size.x*0.25,size.y*0.25)
				if sprite.flip_h: expected.x = -expected.x
				grip_error = maxf(grip_error,sprite.offset.distance_to(expected))
				samples += 1
			check(samples>0 and worst_dot>0.999,label+" visible tip follows intended swing")
			check(grip_error<0.01,label+" mirrored handle stays at attack grip")
			await capture("mirror-"+label)
			for i in 180:
				if player.fsm.current_state != state: break
				await frames(1)
			await frames(3)
			check(player.fsm.current_state!=state and sprite.flip_h==held_flip and blade.global_position.distance_to(player.global_position)<1.0,label+" exit restores held pose")
	print("ATTACK_MIRROR_RESULT ",checks-failures,"/",checks)
	get_tree().quit(0 if failures==0 else 1)
