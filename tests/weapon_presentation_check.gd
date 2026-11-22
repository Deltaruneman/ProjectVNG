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
	rig.view_mode = CameraRig.ViewMode.TOP_DOWN
	camera = rig.get_node("Camera3D")
	camera.position = Vector3(4,7,7)
	camera.look_at(Vector3(0,1,0))
	camera.current = true
	for kind: String in ["starter_blade", "sword", "axe", "spear", "dagger"]:
		await fresh(kind)
		player.set_physics_process(false)
		var sprite := player.get_node("Direction/Blade/Sprite3D") as Sprite3D
		var body := player.get_node("Sprite3D") as Sprite3D
		for facing: String in ["up", "down", "left", "right"]:
			player.change_direction(facing)
			player._apply_direction()
			await frames(3)
			check((sprite.global_position - body.global_position).dot(-camera.global_basis.z) > 0.05, kind + " rests behind body " + facing)
		rig.view_mode = CameraRig.ViewMode.TPS
		await frames(2)
		check(sprite.position.is_equal_approx(Vector3.ZERO), kind + " TPS restores sprite position")
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
