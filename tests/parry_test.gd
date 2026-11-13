extends SceneTree


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var stage := Node3D.new()
	stage.name = "Stage"
	root.add_child(stage)
	current_scene = stage
	var camera := Camera3D.new()
	stage.add_child(camera)
	camera.position = Vector3(0, 5, 8)
	camera.look_at(Vector3(0, 0.9, 0))
	camera.make_current()
	var player = load("res://scenes/player/player.tscn").instantiate()
	stage.add_child(player)
	player.set_physics_process(false)
	player.fsm.change_state(player.fsm.states.parry)
	player.fsm._update(0.001)
	assert(stage.get_node_or_null("PixelFXOverlay") == null, "Parry entry emitted VFX")
	assert(_audio_count(player) == 0, "Parry entry emitted audio")
	player.fsm.states.parry._update(player.parry_window + 0.01)
	assert(not player.fsm.states.parry.try_parry(), "Expired parry accepted")
	assert(stage.get_node_or_null("PixelFXOverlay") == null, "Miss emitted VFX")
	assert(_audio_count(player) == 0, "Miss emitted audio")
	player.fsm.change_state(player.fsm.states.idle)
	player.fsm._update(0.001)
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
		var prior_overlay := stage.get_node_or_null("PixelFXOverlay")
		var prior_effect_count: int = prior_overlay.get_child_count() if prior_overlay != null else 0
		var prior_audio_count := _audio_count(player)
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
		var overlay := stage.get_node("PixelFXOverlay")
		var effect_count := overlay.get_child_count()
		var audio_count := _audio_count(player)
		assert(effect_count == prior_effect_count + 1, "Expected exactly one burst: %s" % path)
		assert(audio_count == prior_audio_count + 1, "Expected exactly one clang: %s" % path)
		var effect = overlay.get_child(effect_count - 1)
		assert(effect.get_child(0).sprite_frames.get_frame_count("default") == 31, "Wrong effect")
		assert(effect.world_position.is_equal_approx(Vector3(0.65, 0.9, 0)), "Wrong contact point")
		assert(not player.fsm.states.parry.try_parry(), "Duplicate success accepted")
		assert(overlay.get_child_count() == effect_count, "Duplicate burst")
		assert(_audio_count(player) == audio_count, "Duplicate clang")
		camera.position.x += 0.2
		camera.look_at(Vector3(0, 0.9, 0))
		effect._process(0.0)
		assert(effect.position.is_equal_approx(camera.unproject_position(effect.world_position)), "Parry drifted during orbit")
		if enemy.fsm != null:
			enemy.fsm._update(0.3)
			enemy.fsm._update(0.001)
			assert(enemy.fsm.current_state == enemy.fsm.default_state, "Did not recover: %s" % path)
		print("PASS parry: ", path)
		player.fsm.change_state(player.fsm.states.idle)
		player.fsm._update(0.001)
		projectile.free()
		enemy.free()
	await create_timer(2.0).timeout
	assert(stage.get_node("PixelFXOverlay").get_child_count() == 0, "Burst did not clean up")
	assert(_audio_count(player) == 0, "Sound did not clean up")
	print("PASS parry feedback: miss, success, duplicate, orbit and cleanup")
	stage.free()
	quit()


func _audio_count(player: Node) -> int:
	var count := 0
	for child in player.get_children():
		if child is AudioStreamPlayer:
			count += 1
	return count
