extends Node3D
var checks:=0
var failures:=0
var player:Player
var rig:CameraRig
func check(ok:bool,label:String):
	checks+=1
	if not ok: failures+=1
	print("PASS " if ok else "FAIL ",label)
func frames(n:int):
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
func reset_player():
	player.set_physics_process(false)
	player.fsm.change_state(player.fsm.states.idle)
	player.fsm._update(0.001)
	player.is_invulnerable=false
	player.invincible=false
	player.health=player.max_health
	player.global_position=Vector3.ZERO
	player.velocity=Vector3.ZERO
	player.hurt_push_direction=Vector3.ZERO
func impact(direction:Vector3,source:Node3D=null):
	player.get_node("Direction/HurtArea3D").take_damage(direction,1,source)
	player.fsm._update(0.001)
func _ready():
	if not "ArcanaSpeedKnockback-20261127" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	run.call_deferred()
func run():
	SaveSystem.save_path="user://fixture.json"
	GameManager.reset()
	var floor_body=StaticBody3D.new()
	var shape=CollisionShape3D.new()
	var box=BoxShape3D.new()
	box.size=Vector3(120,0.2,120)
	shape.shape=box
	floor_body.add_child(shape)
	floor_body.position.y=-0.1
	add_child(floor_body)
	player=load("res://scenes/player/player.tscn").instantiate()
	add_child(player)
	rig=load("res://scenes/camera/camera_rig.tscn").instantiate()
	rig.target=player
	add_child(rig)
	await frames(15)
	check(is_equal_approx(player.movement_speed,15.0),"actual Player base speed is15m/s")
	var enemy=load("res://scenes/enemies/skeleton/skeleton_warrior.tscn").instantiate()
	var enemy_speed:float=enemy.movement_speed
	add_child(enemy)
	enemy.position=Vector3(40,0,40)
	enemy.set_physics_process(false)
	check(is_equal_approx(enemy.movement_speed,enemy_speed),"enemy scene movement speed unchanged")
	enemy.queue_free()
	var from:=player.global_position
	Input.action_press("right")
	await frames(30)
	Input.action_release("right")
	await frames(1)
	var travelled:=Vector2(player.global_position.x-from.x,player.global_position.z-from.z).length()
	print("WALK_DISTANCE ",travelled)
	check(travelled>7.0 and travelled<8.0,"real movement covers about7.5m in half second")
	for facing in [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]:
		for hit in [Vector3.LEFT,Vector3.RIGHT,Vector3.FORWARD,Vector3.BACK]:
			reset_player()
			player.face_movement(rig.movement_vector(facing))
			player.call("_check_changed_direction")
			var body_facing:=player.forward()
			impact(hit)
			var flat:=Vector3(player.velocity.x,0,player.velocity.z)
			check(flat.normalized().dot(hit)>0.999 and is_equal_approx(flat.length(),8.0) and player.velocity.y>0,"impact direction drives knockback facing="+str(facing)+" hit="+str(hit))
			check(player.forward().is_equal_approx(body_facing),"impact does not rotate movement facing")
	for hit in [Vector3.LEFT,Vector3.RIGHT,Vector3.FORWARD,Vector3.BACK]:
		reset_player()
		impact(hit)
		player.set_physics_process(true)
		await frames(6)
		player.set_physics_process(false)
		var displacement:=Vector3(player.global_position.x,0,player.global_position.z)
		check(displacement.dot(hit)>0.5 and player.global_position.y>0,"actual hurt motion travels along impact "+str(hit))
	reset_player()
	var source:=Node3D.new()
	add_child(source)
	source.position=Vector3(3,0,0)
	impact(Vector3.ZERO,source)
	check(player.velocity.x < -7.9,"zero-vector hit falls back away from attacker position")
	reset_player()
	impact(Vector3.ZERO)
	check(Vector2(player.velocity.x,player.velocity.z).length()<0.001,"unknown impact never invents facing-based horizontal push")
	reset_player()
	player.invincible=true
	impact(Vector3.LEFT)
	check(player.health==player.max_health and player.fsm.current_state!=player.fsm.states.hurt,"invincible hit causes no hurt or knockback")
	reset_player()
	player.ice_shield=1
	impact(Vector3.LEFT)
	check(player.health==player.max_health and player.fsm.current_state!=player.fsm.states.hurt,"shield hit causes no hurt or knockback")
	reset_player()
	impact(Vector3.LEFT)
	var velocity:=player.velocity
	var hp:=player.health
	impact(Vector3.RIGHT)
	check(player.health==hp and player.velocity.is_equal_approx(velocity),"hurt invulnerability ignores repeat impact")
	reset_player()
	var wall:=StaticBody3D.new()
	var collision:=CollisionShape3D.new()
	var wall_shape:=BoxShape3D.new()
	wall_shape.size=Vector3(0.5,6,8)
	collision.shape=wall_shape
	wall.add_child(collision)
	add_child(wall)
	wall.position=Vector3(2,2,0)
	await frames(2)
	impact(Vector3.RIGHT)
	player.set_physics_process(true)
	await frames(40)
	check(player.global_position.x<1.1 and player.global_position.x>0.5,"knockback respects actual wall collision")
	check(player.fsm.current_state!=player.fsm.states.hurt and not player.is_invulnerable,"hurt recovery restores state")
	get_viewport().get_texture().get_image().save_png("user://knockback-wall.png")
	print("SPEED_KNOCKBACK_RESULT ",checks-failures,"/",checks)
	get_tree().quit(0 if failures==0 else 1)
