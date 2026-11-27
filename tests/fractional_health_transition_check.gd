extends SceneTree
var checks := 0
var failures := 0
var manager: Node
func _initialize() -> void:
	run.call_deferred()
	watchdog.call_deferred()
func watchdog() -> void:
	await create_timer(90).timeout
	push_error("Fractional health fixture timed out")
	quit(2)
func check(ok: bool, label: String) -> void:
	checks+=1
	if not ok: failures+=1
	print("PASS " if ok else "FAIL ",label)
func ticks(count: int) -> void:
	for i in count:
		await physics_frame
		await process_frame
func run() -> void:
	if not "ArcanaCombatBalance-20261127" in OS.get_user_data_dir():
		quit(2)
		return
	manager=root.get_node("GameManager")
	root.get_node("SaveSystem").save_path="user://transition-fixture.json"
	manager.reset()
	manager.change_stage("res://levels/level_1/garden.tscn","",false)
	await scene_changed
	await ticks(15)
	check(manager.current_stage.scene_file_path.ends_with("garden.tscn"),"loads actual Garden")
	manager.current_stage.player.health=0.5
	manager.change_stage("res://levels/level_1/castle.tscn")
	await scene_changed
	await ticks(15)
	check(manager.current_stage.scene_file_path.ends_with("castle.tscn") and manager.current_stage.player.health==0.5,"actual Garden-to-Castle carries half HP")
	manager.current_stage.player.health=1.5
	manager.change_stage("res://levels/level_1/garden.tscn")
	await scene_changed
	await ticks(15)
	var player=manager.current_stage.player
	check(player.health==1.5,"actual Castle-to-Garden carries fractional HP")
	player.apply_potion("protection_potion")
	player.apply_potion("strength_potion")
	check(player.potion_shield_health>0 and player.potion_strength_remaining>0,"actual potion effects active before transition")
	manager.change_stage("res://levels/level_1/castle.tscn")
	await scene_changed
	await ticks(15)
	player=manager.current_stage.player
	check(player.health==1.5 and player.potion_shield_health==0 and player.potion_strength_remaining==0,"transition preserves fractional HP and clears transient effects")
	manager.change_stage("res://levels/level_1/garden.tscn")
	await scene_changed
	await ticks(15)
	var stage=manager.current_stage
	player=stage.player
	player.global_position=stage.get_node("Transitions/Checkpoint_garden").global_position
	await ticks(10)
	check(manager.checkpoint_id=="garden_start","actual Garden checkpoint activated")
	player.health=0.5
	player.apply_potion("protection_potion")
	player.apply_potion("strength_potion")
	player.is_invulnerable=false
	player.invincible=false
	player.get_node("Direction/HurtArea3D").take_damage(Vector3.RIGHT,99)
	await scene_changed
	await ticks(15)
	player=manager.current_stage.player
	check(manager.current_stage.scene_file_path.ends_with("garden.tscn") and player.health==player.max_health,"death at half HP respawns at actual Garden checkpoint with full HP")
	check(player.potion_shield_health==0 and player.potion_strength_remaining==0,"death/respawn clears both transient potion effects")
	print("FRACTIONAL_TRANSITION_RESULT checks=",checks," failures=",failures)
	quit(0 if failures==0 else 1)