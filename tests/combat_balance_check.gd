extends Node3D
## Use a disposable project and custom user directory; never real saves.
var checks := 0
var failures := 0
var player: Player
var camera: Camera3D
var attack_events := 0
const EVIDENCE := "user://combat-balance-"
func check(ok: bool, label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ", label)
func frames(count: int = 3) -> void:
	for i in count:
		await get_tree().physics_frame
		await get_tree().process_frame
func seconds(duration: float) -> void:
	await get_tree().create_timer(duration).timeout
func spawn_enemy(path: String, at: Vector3) -> EnemyCharacter:
	var unit := load(path).instantiate() as EnemyCharacter
	unit.position = at
	unit.exp_point_drop = 0
	add_child(unit)
	return unit
func reset_player() -> void:
	player.fsm.change_state(player.fsm.states.idle)
	player.fsm._update(0.001)
	player.is_invulnerable = false
	player.invincible = false
	player.health = player.max_health
	player.potion_shield_health = 0.0
	player.velocity = Vector3.ZERO
func hit_player(damage: float) -> void:
	player.is_invulnerable = false
	player.fsm.change_state(player.fsm.states.idle)
	player.fsm._update(0.001)
	player.get_node("Direction/HurtArea3D").take_damage(Vector3.RIGHT, damage)
	player.fsm._update(0.001)
func on_animation(animation: StringName) -> void:
	if "attack" in str(animation) or "castspell" in str(animation) or str(animation) == "skill":
		attack_events += 1
func capture(label: String) -> void:
	if DisplayServer.get_name() != "headless":
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(EVIDENCE + label + ".png")
func _ready() -> void:
	if not "ArcanaCombatBalance-20261127" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	run.call_deferred()
func run() -> void:
	SaveSystem.save_path = "user://fixture.json"
	GameManager.reset()
	var floor_body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(120,0.2,120)
	shape.shape = box
	floor_body.add_child(shape)
	floor_body.position.y = -0.1
	add_child(floor_body)
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-60,-20,0)
	add_child(light)
	player = load("res://scenes/player/player.tscn").instantiate()
	add_child(player)
	await frames(3)
	player.set_physics_process(false)
	player.position = Vector3(0,0,4)
	camera = Camera3D.new()
	camera.position = Vector3(0,16,18)
	camera.projection = Camera3D.PROJECTION_ORTHOGONAL
	camera.size = 20
	add_child(camera)
	camera.look_at(Vector3(0,0,2))
	camera.make_current()
	reset_player()
	check(player.max_health==5 and player.health==5.0,"Player base scene starts with five HP")
	var original_hp := player.health
	hit_player(0.5)
	check(is_equal_approx(player.health,original_hp-0.5),"actual Player hurt path preserves half HP")
	hit_player(0.5)
	check(is_equal_approx(player.health,original_hp-1.0),"two half hits total one HP")
	reset_player()
	player.potion_shield_health = 1.0
	player.potion_shield_capacity = 1
	hit_player(0.5)
	check(player.potion_shield_health==0.5 and player.health==original_hp,"shield absorbs exactly half point")
	hit_player(1.0)
	check(player.potion_shield_health==0.0 and player.health==original_hp-0.5,"shield overflow preserves fractional HP damage")
	reset_player()
	player.health=1.5
	player._health_regen_rank=1
	player._update_health_regeneration(60.0)
	check(player.health==2.5,"regeneration adds one without truncating half HP")
	player._health_regen_rank=0
	GameManager.player_health=0.5
	check(GameManager.player_health==0.5,"stage transition carrier retains half HP")
	GameManager.player_health=-1.0
	var hud := player.get_node("Hud") as PlayerHUD
	await seconds(0.25)
	check(hud._bar is TextureProgressBar and hud._bar.texture_progress is AtlasTexture,"player HP uses supplied vendor atlas")
	check(is_equal_approx(hud._bar.value,2.5),"HUD displays fractional HP")
	for path in ["res://levels/level_1/basement_full.tscn","res://levels/level_1/basement_b3.tscn"]:
		var stage := load(path).instantiate() as Stage
		check(stage.enemy_attack_interval_scale==1.0 and stage.enemy_projectile_speed_scale==1.0,"normal enemy pacing in "+path)
		stage.free()
	var paths := ["skeleton/skeleton_warrior","skeleton/skeleton_mage","arcane/evil_wizard_1","arcane/evil_wizard_2","arcane/necromancer"]
	for i in paths.size():
		var unit := spawn_enemy("res://scenes/enemies/"+paths[i]+".tscn",Vector3(-6+i*3,0,-3))
		unit.set_physics_process(false)
		unit.found_player=player
		reset_player()
		var expected := 0.5 if i<2 else 1.0
		check(unit.attack_damage==expected,"fixed damage "+paths[i])
		unit.state=&"attack"
		if i==0 or i==3:
			player.position=unit.position+Vector3(0,0,1)
			if i==3: unit.attack_direction=Vector3.BACK
			unit.attack()
		else:
			unit.attack_target=player.position+Vector3.UP*0.7
			unit.attack()
			var bullet := get_child(get_child_count()-1)
			check(is_equal_approx(bullet.linear_velocity.length(),7.0),"projectile speed restored "+paths[i])
			bullet.get_node("HitArea3D").hit(player.get_node("Direction/HurtArea3D"))
			bullet.queue_free()
		check(is_equal_approx(player.health,original_hp-expected),"actual contact/projectile damage "+paths[i])
		check(unit.get_child(unit.get_child_count()-1).step==0.01,"enemy HP bar preserves fractions")
		unit.queue_free()
		await frames(2)
	player.position=Vector3(0,0,4)
	reset_player()
	var dummy := spawn_enemy("res://scenes/enemies/skeleton/skeleton_warrior.tscn",Vector3(0,0,0))
	dummy.set_physics_process(false)
	dummy.set_process(false)
	var before := dummy.health
	dummy.apply_skill_burn(player,99,99,0.1)
	dummy._process(0.99)
	check(dummy.health==before,"burn does not damage before one second")
	dummy._process(0.08)
	check(dummy.health==before-0.5 and not dummy._skill_burn_running,"overshoot delivers exactly final half-point tick then expires")
	dummy._process(2.0)
	check(dummy.health==before-0.5,"expired burn causes no extra ticks")
	dummy.state=&"idle"
	dummy.apply_skill_burn(player)
	await seconds(0.2)
	dummy.apply_skill_burn(player)
	dummy.set_process(true)
	await seconds(1.15)
	check(dummy.health==before-1.0 and not dummy._skill_burn_running,"reapplication refreshes one burn without stacking")
	dummy.state=&"hurt"
	before=dummy.health
	dummy.apply_skill_burn(player)
	dummy.set_process(false)
	dummy._process(1.1)
	check(dummy.health==before-0.5 and dummy.state==&"hurt","burn damages through hurt without restarting hitstun")
	dummy.state=&"idle"
	dummy.set_process(true)
	dummy.apply_skill_burn(player)
	before=dummy.health
	get_tree().paused=true
	await get_tree().create_timer(0.2,true).timeout
	check(dummy.health==before and dummy._skill_burn_remaining==1.0,"pause freezes burn damage and duration")
	get_tree().paused=false
	await seconds(1.15)
	check(dummy.health==before-0.5,"burn resumes once after pause")
	player.health=0.5
	var clone=load("res://scenes/player/lightning_clone.gd").new()
	clone._caster=player
	check(clone._caster_is_alive(),"lightning clone recognizes living half-HP caster")
	clone.free()
	GameManager.skill_allocations["evo_fire_ember"]=1
	GameManager.skill_allocations["char_element"]=1
	for skill in ["ultimate_fire_1","ultimate_fire_2"]:
		dummy.state=&"idle"
		dummy.max_health=200
		dummy.health=200
		player.health=player.max_health
		player.rage=Player.MAX_RAGE
		player._ultimate_cooldown_remaining=0.0
		GameManager.unlocked_skills.append(skill)
		check(player.cast_ultimate(skill),"casts "+skill)
		check(dummy._skill_burn_running and dummy._skill_burn_remaining<=1.0,"fire ultimate ignites "+skill)
		var after_impact := dummy.health
		await seconds(1.2)
		check(dummy.health==after_impact-0.5 and not dummy._skill_burn_running,"ultimate burn fixed half HP and one-second duration "+skill)
	dummy.queue_free()
	await frames(3)
	reset_player()
	player.invincible=true
	player.position=Vector3(0,0,4)
	for path in ["darkfairy/darkfairy","arcane/undead_executioner"]:
		var boss := spawn_enemy("res://scenes/enemies/"+path+".tscn",Vector3.ZERO)
		boss.max_health=200
		boss.health=200
		if "intro_seen" in boss: boss.intro_seen=true
		boss.found_player=player
		boss.anim_player.animation_started.connect(on_animation)
		attack_events=0
		for i in 70:
			await seconds(0.2)
			boss.get_node("Direction/HurtArea3D").take_damage(Vector3.RIGHT,0.5,player)
			if i%6==0: boss.apply_skill_burn(player)
			if i==5: await capture("boss-"+path.get_slice("/",0))
		check(attack_events>=2,"boss repeatedly attacks under continuous hits and burn "+path+" events="+str(attack_events))
		check(not boss._fallback_hurt_running and boss.is_physics_processing(),"boss AI remains enabled "+path)
		boss.on_parried(Vector3.RIGHT)
		check(boss.state==&"hurt","parry still interrupts boss "+path)
		await seconds(0.6)
		check(boss.state!=&"hurt","boss recovers from parry "+path)
		if "summons" in boss:
			check(boss.summons.size()>0,"executioner summon path completes with current EXP property")
		if "phase" in boss:
			print("FAIRY_ACTIONS ",boss.action_index," state=",boss.state)
			boss.shield_hits=0
			boss.invincible=false
			boss.get_node("Direction/HurtArea3D").take_damage(Vector3.ZERO,110,player)
			await seconds(2.2)
			check(boss.phase==2 and boss.state!=&"transformation","Dark Fairy completes phase transition")
			var old_events := attack_events
			await seconds(3.0)
			check(attack_events>old_events,"Dark Fairy attacks in phase two")
			boss.get_node("Direction/HurtArea3D").take_damage(Vector3.ZERO,200,player)
			await seconds(2.5)
			check(not is_instance_valid(boss),"Dark Fairy defeat completes")
		else:
			boss.get_node("Direction/HurtArea3D").take_damage(Vector3.ZERO,200,player)
			await seconds(2.0)
			check(not is_instance_valid(boss),"executioner death completes")
		await frames(3)
	reset_player()
	player.health=1.5
	var gallery := CanvasLayer.new()
	gallery.layer=150
	add_child(gallery)
	for i in 3:
		var node := SkillTreeNode.new()
		node.position=Vector2(30+i*140,75)
		node.title_text=["Chưa học","Đã học","Đã học / chọn"][i]
		node.rank_text="1/1" if i>0 else "0/1"
		node.available=true
		node.purchased=i>0
		node.selected=i==2
		node._hovered=i==2
		node.accent_color=Color("35a7ff")
		gallery.add_child(node)
	await seconds(0.3)
	await capture("hp-and-gold-nodes")
	if DisplayServer.get_name()!="headless":
		var picture=get_viewport().get_texture().get_image()
		var viewport_size=get_viewport().get_visible_rect().size
		for i in [1,2]:
			var pixel=Vector2(30+i*140+54,75+65)*Vector2(picture.get_size())/viewport_size
			var color=picture.get_pixelv(Vector2i(pixel))
			check(color.r>0.9 and color.g>0.7 and color.b<0.65,"learned node remains visibly gold selected/hover="+str(i==2))
	check(player.get_node("Hud")._bar.texture_under is AtlasTexture,"gold empty HP frame remains configured")
	print("COMBAT_BALANCE_RESULT checks=",checks," failures=",failures)
	gallery.queue_free()
	player.queue_free()
	await frames(3)
	get_tree().quit(0 if failures==0 else 1)