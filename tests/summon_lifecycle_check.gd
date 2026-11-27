extends Node3D
var checks := 0
var failures := 0
var player: Player
var boss: EnemyCharacter
func check(ok: bool,label: String) -> void:
	checks+=1
	if not ok: failures+=1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int=3) -> void:
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame
func seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
func begin_attack() -> void:
	boss.state=&"idle"
	boss.summon_timer=0.0
	boss._begin_attack(Vector3.BACK)
	boss.anim_player.stop()
func _ready() -> void:
	if not "ArcanaCombatBalance-20261127" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	run.call_deferred()
func run() -> void:
	SaveSystem.save_path="user://summon-lifecycle-fixture.json"
	GameManager.reset()
	var floor_body:=StaticBody3D.new()
	var shape:=CollisionShape3D.new()
	var box:=BoxShape3D.new()
	box.size=Vector3(100,0.2,100)
	shape.shape=box
	floor_body.add_child(shape)
	floor_body.position.y=-0.1
	add_child(floor_body)
	player=load("res://scenes/player/player.tscn").instantiate()
	player.position=Vector3(0,0,2)
	add_child(player)
	var camera:=Camera3D.new()
	camera.position=Vector3(0,8,12)
	add_child(camera)
	camera.look_at(Vector3.ZERO)
	camera.make_current()
	await frames()
	player.invincible=true
	player.set_physics_process(false)
	boss=load("res://scenes/enemies/arcane/undead_executioner.tscn").instantiate()
	add_child(boss)
	boss.set_physics_process(false)
	boss.found_player=player
	var freed:=Node3D.new()
	add_child(freed)
	boss.summons.append(freed)
	freed.free()
	begin_attack()
	check(boss.summons.is_empty(),"next attack prunes already-freed summon without typed-lambda failure")
	if OS.get_cmdline_user_args().has("--repro"):
		print("SUMMON_REPRO_RESULT checks=",checks," failures=",failures)
		boss.queue_free()
		player.queue_free()
		await frames()
		get_tree().quit(0 if failures==0 else 1)
		return
	check(boss.summons.is_typed() and boss.summons.get_typed_class_name()==&"Node3D","summon collection keeps Array[Node3D] type")
	check(boss.state==&"summon","boss chooses resummon after expired entry is removed")
	var first:=Node3D.new()
	var second:=Node3D.new()
	var queued:=Node3D.new()
	var another_freed:=Node3D.new()
	for node in [first,queued,second,another_freed]: add_child(node)
	for node in [first,queued,second,another_freed]: boss.summons.append(node)
	boss.summons.append(null)
	var original_collection=boss.summons
	queued.queue_free()
	another_freed.free()
	begin_attack()
	check(boss.summons.size()==2 and boss.summons[0]==first and boss.summons[1]==second,"mixed null/freed/queued entries removed, living order preserved")
	check(original_collection.size()==2,"pruning updates original typed array in place")
	first.free()
	second.free()
	begin_attack()
	check(boss.summons.is_empty(),"consecutive invalid entries all removed")
	begin_attack()
	check(boss.summons.is_empty(),"empty array safely supports repeated attacks")
	boss.attack()
	check(boss.summons.size()==1 and is_instance_valid(boss.summons[0]),"real summon animation callback creates replacement")
	var summoned=boss.summons[0]
	var natural_lifetime: float=summoned._lifetime
	check(natural_lifetime==18.0,"actual authored summon lifetime is eighteen seconds")
	await seconds(20.5)
	check(not is_instance_valid(summoned),"actual summoned unit naturally expires and finishes death animation")
	begin_attack()
	check(boss.summons.is_empty() and boss.state==&"summon","boss attacks/resummons after natural lifetime expiry")
	boss.attack()
	check(boss.summons.size()==1 and is_instance_valid(boss.summons[0]),"boss creates another summon after natural expiry")
	var killed=boss.summons[0]
	await seconds(1.0)
	killed.get_node("Direction/HurtArea3D").take_damage(Vector3.RIGHT,99,player)
	await seconds(2.0)
	check(not is_instance_valid(killed),"damage-killed summoned unit completes actual death lifecycle")
	var previous_attacks: int=boss.attack_count
	for i in 3: begin_attack()
	check(boss.summons.is_empty() and boss.attack_count==previous_attacks+3,"repeated attacks continue after damage-killed summon")
	var necromancer=load("res://scenes/enemies/arcane/necromancer.tscn").instantiate()
	necromancer.position=Vector3(10,0,0)
	add_child(necromancer)
	necromancer.set_physics_process(false)
	necromancer.found_player=player
	var expired:=Node3D.new()
	add_child(expired)
	necromancer.summons.append(expired)
	expired.free()
	necromancer.summon_timer=0.0
	necromancer._begin_attack(Vector3.LEFT)
	necromancer.anim_player.stop()
	check(necromancer.summons.is_empty() and necromancer.state==&"summon","Necromancer shares safe expired-summon recovery")
	necromancer.queue_free()
	boss.queue_free()
	player.queue_free()
	await frames()
	print("SUMMON_LIFECYCLE_RESULT checks=",checks," failures=",failures)
	get_tree().quit(0 if failures==0 else 1)