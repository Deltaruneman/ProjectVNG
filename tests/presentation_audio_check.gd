extends Node3D
var failures := 0
func check(ok: bool, label: String):
	print("PASS " if ok else "FAIL ",label)
	if not ok: failures += 1
func frames(n: int):
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
func _ready():
	if not "ArcanaPresentation-20261126" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	_run.call_deferred()
func _run():
	GameManager.reset()
	GameManager.flags["story_possession"] = true
	GameManager.flags["story_dark_fairy_intro"] = true
	SaveSystem.save_path = "user://fixture.json"
	var stage = load("res://levels/level_1/basement_b3.tscn").instantiate()
	add_child(stage)
	await frames(20)
	var player: Player = stage.get_node("Player")
	player.invincible = true
	var rig: CameraRig = stage.get_node("CameraRig")
	var blade = player.get_node("Direction/Blade")
	var sprite: Sprite3D = blade.get_node("Sprite3D")
	player.set_physics_process(false)
	for state in player.fsm.get_children(): state.set_physics_process(false)
	player.face_movement(rig.movement_vector(Vector2.LEFT))
	blade.update_held_pose()
	check(not sprite.flip_h,"left-facing held weapon uses corrected source orientation")
	await frames(3)
	get_viewport().get_texture().get_image().save_png("user://weapon-left.png")
	player.face_movement(rig.movement_vector(Vector2.RIGHT))
	blade.update_held_pose()
	check(sprite.flip_h,"right-facing held weapon uses corrected mirror orientation")
	await frames(3)
	get_viewport().get_texture().get_image().save_png("user://weapon-right.png")
	var start_y: float = rig.global_position.y
	player.position.y += 0.3
	await frames(1)
	check(rig.global_position.y > start_y and rig.global_position.y < player.global_position.y+rig.focus_offset.y,"step-up camera height is eased")
	await frames(45)
	check(absf(rig.global_position.y-player.global_position.y-rig.focus_offset.y)<0.02,"camera settles at the landing height")
	player.position.y -= 0.3
	await frames(45)
	var wall: GridMap = stage.get_node("B3/World/Wall")
	var upper: GridMap = stage.get_node("B3/World/WallUpper")
	check(upper.get_used_cells()==wall.get_used_cells() and is_equal_approx(upper.position.y,7.2),"B3 second wall course preserves footprint at +7.2m")
	check(not stage.has_node("B3/World/Ceiling"),"B3 has no ceiling above the two wall courses")
	get_viewport().get_texture().get_image().save_png("user://b3-two-courses.png")
	var helper = rig._wall_occlusion
	var t := Time.get_ticks_usec()
	for i in 120: helper._physics_process(1.0/60.0)
	print("OCCLUSION_US_PER_TICK ",(Time.get_ticks_usec()-t)/120.0)
	print("AUDIO_BEFORE driver=",AudioServer.get_driver_name()," focused=",GameSettings._focused," muted=",AudioServer.is_bus_mute(0))
	GameSettings._notification(NOTIFICATION_APPLICATION_FOCUS_IN)
	var bus := AudioServer.get_bus_index("SFX")
	var peak := -1000.0
	preload("res://scenes/player/battle_vfx.gd").play_skill_sound(player,"weapon_attack")
	for i in 45:
		await frames(1)
		peak=maxf(peak,AudioServer.get_bus_peak_volume_left_db(bus,0))
	print("AUDIO_PEAK ",peak," muted=",AudioServer.is_bus_mute(0))
	check(peak > -60.0,"combat sound reaches the SFX mixer")
	# Walk real Player up six physical steps using normal movement and step-up logic.
	for i in 6:
		var body := StaticBody3D.new()
		var collision := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = Vector3(1,0.2*(i+1),4)
		collision.shape = shape
		body.add_child(collision)
		var visual := MeshInstance3D.new()
		var box := BoxMesh.new()
		box.size = shape.size
		visual.mesh = box
		body.add_child(visual)
		stage.add_child(body)
		body.position = Vector3(400.5+i,shape.size.y*0.5,400)
	player.global_position = Vector3(400.3,0.4,400)
	player.velocity = Vector3.ZERO
	player.set_physics_process(true)
	rig.snap_to_target()
	await frames(20)
	Input.action_press("right",0.7071)
	Input.action_press("up",0.7071)
	var worst_lag := 0.0
	for i in 40:
		await frames(1)
		worst_lag=maxf(worst_lag,absf(rig.global_position.y-player.global_position.y-rig.focus_offset.y))
	Input.action_release("right")
	Input.action_release("up")
	await frames(30)
	print("STAIR_POSITION ",player.global_position," max_camera_lag=",worst_lag)
	check(player.global_position.x>402 and player.global_position.y>0.55 and player.is_on_floor(),"real Player climbs physical steps and stays grounded")
	check(worst_lag<0.5,"stair follow remains within bounded vertical lag")
	get_viewport().get_texture().get_image().save_png("user://stairs.png")
	print("PRESENTATION_RESULT failures=",failures)
	get_tree().quit(1 if failures else 0)
