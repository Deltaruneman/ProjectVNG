extends Node3D
var checks := 0
var failures := 0
var player: Player
var hud: PlayerHUD
var bar: TextureProgressBar
func check(ok: bool,label: String) -> void:
	checks+=1
	if not ok: failures+=1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int=3) -> void:
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame
func settle() -> void:
	await get_tree().create_timer(0.3).timeout
	if DisplayServer.get_name()!="headless": await RenderingServer.frame_post_draw
func reset_player() -> void:
	player.fsm.change_state(player.fsm.states.idle)
	player.fsm._update(0.001)
	player.invincible=false
	player.is_invulnerable=false
	player.health=player.max_health
	player.potion_shield_health=0.0
func picture() -> Image:
	return get_viewport().get_texture().get_image()
func sample(image: Image, local: Vector2) -> Color:
	var screen:=bar.get_global_transform()*local
	var pixel:=screen*Vector2(image.get_size())/get_viewport().get_visible_rect().size
	return image.get_pixelv(Vector2i(pixel))
func separator_count(image: Image) -> int:
	var count:=0
	var previous:=false
	for x in range(4,int(bar.size.x)-4):
		var color:=sample(image,Vector2(x+0.5,bar.size.y/2.0+0.5))
		var dark:=color.r<0.15 and color.g<0.15 and color.b<0.15
		if dark and not previous: count+=1
		previous=dark
	return count
func screenshot(label: String) -> void:
	if DisplayServer.get_name()!="headless": picture().save_png("user://hp-segments-"+label+".png")
func enemy_paths(folder: String) -> Array[String]:
	var paths: Array[String]=[]
	for file in DirAccess.get_files_at(folder):
		if file.ends_with(".tscn"): paths.append(folder+"/"+file)
	for directory in DirAccess.get_directories_at(folder): paths.append_array(enemy_paths(folder+"/"+directory))
	return paths
func _ready() -> void:
	if not "ArcanaCombatBalance-20261127" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	run.call_deferred()
func run() -> void:
	SaveSystem.save_path="user://hp-segments-fixture.json"
	GameManager.reset()
	var floor_body:=StaticBody3D.new()
	var collider:=CollisionShape3D.new()
	var box:=BoxShape3D.new()
	box.size=Vector3(100,0.2,100)
	collider.shape=box
	floor_body.add_child(collider)
	floor_body.position.y=-0.1
	add_child(floor_body)
	player=load("res://scenes/player/player.tscn").instantiate()
	add_child(player)
	await frames()
	player.set_physics_process(false)
	reset_player()
	var camera:=Camera3D.new()
	add_child(camera)
	camera.position=Vector3(0,8,12)
	camera.look_at(Vector3.ZERO)
	camera.make_current()
	hud=player.get_node("Hud")
	bar=hud._bar
	await settle()
	check(player.max_health==5 and player.health==5.0,"actual Player base is five full HP")
	check(bar.max_value==5 and bar.value==5,"HUD capacity matches five HP")
	if DisplayServer.get_name()!="headless":
		check(separator_count(picture())==4,"render has four inner dividers defining five one-HP segments")
		screenshot("five-full")
	player.get_node("Direction/HurtArea3D").take_damage(Vector3.RIGHT,0.5)
	await settle()
	check(player.health==4.5 and bar.value==4.5,"half hit leaves four-and-half HP")
	if DisplayServer.get_name()!="headless":
		var image:=picture()
		var filled:=sample(image,Vector2(bar.size.x*0.85,4.5))
		var empty:=sample(image,Vector2(bar.size.x*0.95,4.5))
		check(filled.r>0.25 and empty.r<0.15,"half HP empties the outer half of the last segment")
		screenshot("four-and-half")
	reset_player()
	player.get_node("Direction/HurtArea3D").take_damage(Vector3.RIGHT,1.0)
	await settle()
	check(player.health==4 and bar.value==4,"one hit removes exactly one HP segment")
	GameManager.skill_allocations["char_health"]=2
	GameManager.skill_progress_changed.emit()
	player.health=player.max_health
	await settle()
	check(player.max_health==7 and bar.max_value==7,"health upgrades add to the new five-HP base")
	if DisplayServer.get_name()!="headless":
		check(separator_count(picture())==6,"seven HP renders seven one-HP segments")
		screenshot("seven-upgraded")
	GameManager.skill_allocations.erase("char_health")
	GameManager.skill_progress_changed.emit()
	reset_player()
	var enemies:=0
	for path in enemy_paths("res://scenes/enemies"):
		var node=load(path).instantiate()
		if node is EnemyCharacter:
			enemies+=1
			var expected:=0.5 if node.get_script().resource_path=="res://scenes/enemies/skeleton/skeleton.gd" else 1.0
			check(node.attack_damage==expected,"enemy damage "+path+" = "+str(expected))
		node.free()
	check(enemies>=10,"all authored enemy-character scenes inspected")
	for kind in ["attack","skill"]:
		var boss=load("res://scenes/enemies/arcane/undead_executioner.tscn").instantiate()
		add_child(boss)
		boss.set_physics_process(false)
		player.position=Vector3(0,0,1.5)
		reset_player()
		boss.found_player=player
		boss.state=StringName(kind)
		boss.attack_direction=Vector3.BACK
		boss.attack()
		check(player.health==4.0,"actual Executioner "+kind+" deals one HP")
		boss.queue_free()
		await frames()
	var fairy=load("res://scenes/enemies/darkfairy/darkfairy.tscn").instantiate()
	add_child(fairy)
	fairy.set_physics_process(false)
	fairy.intro_seen=true
	player.position=Vector3(0,0,1.5)
	await frames()
	reset_player()
	fairy.state=&"closeattack"
	fairy.close_attack()
	check(player.health==4.0,"actual Dark Fairy melee deals one HP")
	for phase in [1,2]:
		reset_player()
		fairy._spawn_spell(player.global_position,phase,1.25)
		var spell=get_child(get_child_count()-1)
		spell.set_physics_process(false)
		await frames()
		spell._physics_process(0.8)
		check(player.health==4.0,"actual Dark Fairy phase "+str(phase)+" spell deals one HP")
		spell.queue_free()
		await frames()
	fairy.queue_free()
	await frames()
	print("HP_SEGMENTS_DAMAGE_RESULT checks=",checks," failures=",failures," enemy_scenes=",enemies)
	player.queue_free()
	await frames()
	get_tree().quit(0 if failures==0 else 1)