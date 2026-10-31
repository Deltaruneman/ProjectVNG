extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var stage := Node3D.new()
	stage.name = "Stage"
	root.add_child(stage)
	current_scene = stage
	var player = load("res://scenes/player/player.tscn").instantiate()
	stage.add_child(player)
	player.set_physics_process(false)
	for path in ["crab/crab", "crab/barrel", "mushroom/mushroom", "starfish/starfish", "skeleton/skeleton_warrior", "skeleton/skeleton_mage", "pelican/pelican"]:
		var enemy = load("res://scenes/enemies/%s.tscn" % path).instantiate()
		stage.add_child(enemy)
		enemy.set_physics_process(false)
		enemy.position = Vector3(10, 0, 0)
		if enemy.fsm != null:
			enemy.fsm._update(0.001)
		player.fsm.change_state(player.fsm.states.parry)
		player.fsm._update(0.001)
		var enemy_health: int = enemy.health
		var player_health: int = player.health
		var previous_velocity: Vector3 = enemy.velocity
		var previous_animation: StringName = enemy.anim_player.current_animation
		var projectile := Node3D.new()
		var hit := HitArea3D.new()
		projectile.add_child(hit)
		stage.add_child(projectile)
		enemy.register_projectile(projectile)
		assert(hit.attacker == enemy, "Missing projectile source: %s" % path)
		if path in ["crab/crab", "mushroom/mushroom", "starfish/starfish", "skeleton/skeleton_warrior"]:
			hit.reparent(enemy.get_node("Direction"))
			hit.attacker = null
		hit.hit(player.get_node("Direction/HurtArea3D"))
		if enemy.fsm != null:
			enemy.fsm._update(0.001)
			if enemy.fsm.states.has("hurt"):
				assert(enemy.fsm.current_state == enemy.fsm.states.hurt, path)
			else:
				assert(enemy.fsm.current_state == enemy.fsm.default_state, path)
				assert(enemy.velocity == previous_velocity, path)
		elif path.begins_with("skeleton"):
			assert(enemy.state == &"hurt", path)
		else:
			assert(enemy.flight_state == enemy.FlightState.PATROL, path)
			assert(enemy.velocity == previous_velocity, path)
			assert(enemy.anim_player.current_animation == previous_animation, path)
		assert(enemy.health == enemy_health, "Enemy lost health: %s" % path)
		assert(player.health == player_health, "Player lost health: %s" % path)
		if enemy.fsm != null:
			enemy.fsm._update(0.3)
			enemy.fsm._update(0.001)
			assert(enemy.fsm.current_state == enemy.fsm.default_state, "Did not recover: %s" % path)
		print("PASS parry: ", path)
		player.fsm.change_state(player.fsm.states.idle)
		player.fsm._update(0.001)
		projectile.free()
		enemy.free()
	stage.free()
	quit()
