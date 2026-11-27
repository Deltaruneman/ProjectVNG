extends "res://tests/weapon_combo_check.gd"

func _ready() -> void:
	if not "ArcanaInventory" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	SaveSystem.save_path = "user://low-throw-fixture.json"
	GameManager.reset()
	_test_obstacle(Vector3(0,-0.12,0), Vector3(30,0.2,30))
	camera = Camera3D.new()
	add_child(camera)
	camera.position = Vector3(4,5,7)
	camera.look_at(Vector3(0,0.9,0))
	camera.current = true
	await fresh("starter_blade")
	player.set_physics_process(false)
	var roof := _test_obstacle(Vector3(2,1.1,0), Vector3(8,0.2,4))
	await frames(3)
	var drop = _test_drop(Vector3(0,0.8,0), Vector3(100,0.8,0))
	await frames(3)
	check(is_equal_approx(drop.global_position.y, 0.8), "default throw flies straight without an arc")
	var highest := 0.0
	for i in range(120):
		await frames()
		highest = maxf(highest, drop.global_position.y)
		if drop.landed:
			break
	check(highest < 1.01 and drop.global_position.x <= 7.01, "straight throw stays below ceiling and within7m")
	check(drop.landed and drop.global_position.y < 0.1, "ceiling contact falls to floor")
	player.global_position = drop.global_position
	check(drop.pickup(), "ceiling-blocked weapon can be picked up")
	roof.queue_free()
	await frames(3)
	player.global_position = Vector3.ZERO
	var enemy := preload("res://scenes/enemies/crab/crab.tscn").instantiate() as EnemyCharacter
	enemy.max_health = 20
	enemy.exp_point_drop = 0
	enemy.position = Vector3(2,0,0)
	add_child(enemy)
	enemy.set_physics_process(false)
	await frames(3)
	var before := enemy.health
	drop = _test_drop(Vector3(0,0.8,0), Vector3(4,-0.02,0))
	await frames(90)
	check(enemy.health == before - 2, "throw deals exactly weapon damage once to real enemy")
	check(drop.landed and drop.global_position.x <= enemy.global_position.x + 0.2, "first enemy stops the throw and weapon plants on floor")
	player.global_position = drop.global_position
	check(drop.pickup(), "damaging weapon remains recoverable")
	await frames(3)
	enemy.health = before
	var wall := _test_obstacle(Vector3(1,1,0), Vector3(0.2,2,4))
	player.global_position = Vector3.ZERO
	await frames(3)
	drop = _test_drop(Vector3(0,0.8,0), Vector3(4,-0.02,0))
	await frames(90)
	check(enemy.health == before, "wall blocks damage to enemy behind it")
	check(drop.landed and drop.global_position.x < 1.0 and drop.global_position.y < 0.1, "wall-blocked weapon lands on near floor")
	player.global_position = drop.global_position
	check(drop.pickup(), "wall-blocked weapon can be picked up")
	wall.queue_free()
	enemy.queue_free()
	await frames(2)
	print("LOW_THROW_RESULT ", checks-failures, "/", checks)
	get_tree().quit(0 if failures == 0 else 1)

func _test_obstacle(at: Vector3, size: Vector3) -> StaticBody3D:
	var node := StaticBody3D.new()
	var collider := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collider.shape = shape
	node.add_child(collider)
	node.position = at
	add_child(node)
	return node

func _test_drop(from: Vector3, to: Vector3):
	var drop = load("res://scenes/player/thrown_weapon.gd").new()
	drop.thrower = player
	drop.definition = "starter_blade"
	drop.item_uid = str(GameManager.inventory.equipped.main)
	drop.origin = from
	drop.target = to
	drop.damage = 2
	drop.duration = 0.6
	GameManager.flags.thrown_main_weapon = {"flight_version": 2, "uid": drop.item_uid, "position": [to.x,to.y,to.z]}
	GameManager.inventory.equipped.main = ""
	add_child(drop)
	drop.global_position = from
	return drop
