## T086 actual-basement walking/camera regression. Run the .tscn with a renderer in a
## disposable copy whose exact user data was verified BEFORE production autoloads.
## The guard below is an additional check; never launch this in the original project.
extends Node
var stage: Node3D
var player: Player
var rig: CameraRig
var checks := 0
var failures := 0
var sample_id := 0


func _ready():
	process_mode=Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene=null
	run.call_deferred()


func ticks(n: int=1):
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame


func check(ok: bool,label: String):
	checks+=1
	if not ok:failures+=1
	print("PASS " if ok else "FAIL ",label)


func stop():
	for action in ["left","right","up","down"]:Input.action_release(action)


func drive(target: Vector3,frames: int=100):
	for i in frames:
		var d: Vector3=target-player.global_position
		d.y=0
		if d.length()<0.16:break
		var input: Vector3=d.normalized().rotated(Vector3.UP,-rig.yaw)
		stop()
		if absf(input.x)>0.02:Input.action_press("right" if input.x>0 else "left",absf(input.x))
		if absf(input.z)>0.02:Input.action_press("down" if input.z>0 else "up",absf(input.z))
		await ticks()
	stop()
	await ticks(3)


func paths(hits: Array)->Array:
	var out: Array=[]
	for hit in hits:out.append(str(hit.collider.get_path()))
	return out


func trace(label: String):
	var space:=stage.get_world_3d().direct_space_state
	var rq:=PhysicsRayQueryParameters3D.create(player.global_position+Vector3.UP*0.2,player.global_position-Vector3.UP*2.0,1)
	rq.exclude=[player.get_rid()]
	var support:=space.intersect_ray(rq)
	var sq:=PhysicsShapeQueryParameters3D.new()
	sq.shape=SphereShape3D.new()
	sq.shape.radius=rig.collision_radius
	sq.collision_mask=rig.collision_mask
	sq.exclude=[player.get_rid()]
	sq.transform=Transform3D(Basis.IDENTITY,rig.camera.global_position)
	var lens_hits:=paths(space.intersect_shape(sq,8))
	sq.transform.origin=rig.global_position
	var focus_hits:=paths(space.intersect_shape(sq,8))
	var boom: Vector3=rig._boom_direction()
	var obstruction:=space.intersect_ray(PhysicsRayQueryParameters3D.create(rig.global_position,rig.global_position+boom*rig.orbit_distance,1))
	var connector: Dictionary=stage._connector_near_player()
	var checkpoint_path: String="B1/Checkpoint_b1" if label.begins_with("B1-") else "B2/Checkpoint_b2"
	var cp: Node3D=stage.get_node(checkpoint_path)
	var marker: AnimatedSprite3D=cp.get_node("AnimatedSprite3D")
	var record={"tag":label,"player":str(player.global_position),"grounded":player.is_on_floor(),"support":str(support.collider.get_path()) if not support.is_empty() else "none","support_at":str(support.get("position",Vector3.INF)),"level":stage.current_level(),"B1":stage.get_node("B1").visible,"B1_5":stage.get_node("B1_5").visible,"B2":stage.get_node("B2").visible,"camera":str(rig.camera.global_position),"focus":str(rig.global_position),"anchor":str(player.global_position+rig.focus_offset),"distance":rig.current_distance,"zoom":rig.orbit_distance,"yaw":rig.yaw,"obstruction":str(obstruction.collider.get_path()) if not obstruction.is_empty() else "none","lens_overlaps":lens_hits,"focus_overlaps":focus_hits,"connector":str(connector.get("path","none")),"from":connector.get("from",-1),"to":connector.get("to",-1),"marker_visible":marker.is_visible_in_tree(),"marker_alpha":marker.modulate.a,"marker_distance":marker.global_position.distance_to(rig.camera.global_position)}
	var sight_query:=PhysicsRayQueryParameters3D.create(rig.camera.global_position,player.global_position+Vector3.UP*0.7,1)
	sight_query.exclude=[player.get_rid()]
	var sight: Dictionary=space.intersect_ray(sight_query)
	record["sightline_collider"]=str(sight.collider.get_path()) if not sight.is_empty() else "none"
	record["marker_path"]=str(marker.get_path())
	record["marker_view_position"]=str(rig.camera.to_local(marker.global_transform*marker.get_aabb().get_center()))
	var ceilings: Dictionary={}
	for ceiling in stage._ceilings:ceilings[str(ceiling.get_path())]=ceiling.visible
	record["ceilings"]=ceilings
	print("TRACE ",JSON.stringify(record))
	FileAccess.open("user://trace-%03d.json"%sample_id,FileAccess.WRITE).store_string(JSON.stringify(record))
	sample_id+=1
	if OS.get_cmdline_user_args().has("--capture") and DisplayServer.get_name()!="headless" and (label.begins_with("B2-z-yaw0-zoom9") or label.begins_with("B1-yaw0-zoom9")):
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("user://"+label+".png")
	return record


func setup(pos: Vector3,yaw_value: float,zoom: float):
	stop()
	player.global_position=pos
	player.velocity=Vector3.ZERO
	player.fsm.change_state(player.fsm.states.idle)
	rig.yaw=yaw_value
	rig.orbit_distance=zoom
	rig.snap_to_target()
	await ticks(35)


func run():
	if OS.get_user_data_dir().replace("\\", "/") != OS.get_environment("ARCANA_EXPECTED_USERDATA").replace("\\", "/") or not OS.get_cmdline_user_args().has("--isolated-copy") or not str(ProjectSettings.get_setting("application/config/custom_user_dir_name", "")).begins_with("ArcanaCheckpoint-"):
		get_tree().quit(2)
		return
	GameManager.reset()
	get_tree().change_scene_to_file("res://levels/level_1/basement_full.tscn")
	await get_tree().scene_changed
	stage=get_tree().current_scene
	player=stage.get_node("Player")
	rig=stage.get_node("CameraRig")
	player.invincible=true
	if stage.has_node("DarkFairy"):
		stage.get_node("DarkFairy").set_physics_process(false)
	for timer in stage.find_children("*","Timer",true,false):
		if timer.get_parent() is EnemyZone:timer.stop()
	var cp: Node3D=stage.get_node("B2/Checkpoint_b2")
	print("CHECKPOINT_TRANSFORMS area=",cp.global_position," spawn=",cp.get_node("Spawn").global_position)
	for yaw_deg in [0,90,180]:
		for zoom in [3.0,9.0,14.0]:
			for axis in ["z","x"]:
				var tag: String="B2-%s-yaw%d-zoom%d"%[axis,yaw_deg,int(zoom)]
				var start:=Vector3(49,11.2,9) if axis=="z" else Vector3(44,11.2,3)
				var near:=Vector3(49,11.1,3.9) if axis=="z" else Vector3(48.5,11.1,3)
				await setup(start,deg_to_rad(yaw_deg),zoom)
				await trace(tag+"-before")
				await drive(near)
				var inside: Dictionary=await trace(tag+"-near")
				check(player.global_position.distance_to(near)<0.65,"walk reaches B2 "+tag)
				check(inside.level==1 and inside.B2,"B2 stays selected before F "+tag)
				check(inside.grounded and inside.support.begins_with("/root/Stage/B2/"),"actual B2 support "+tag)
				check(inside.lens_overlaps.is_empty(),"camera lens outside world "+tag)
				await drive(start)
				var after: Dictionary=await trace(tag+"-after")
				check(after.level==1 and after.B2,"B2 visible after leaving "+tag)
				check(GameManager.checkpoint_id=="","walking does not activate "+tag)
			var tag: String="B1-yaw%d-zoom%d"%[yaw_deg,int(zoom)]
			await setup(Vector3(-3,1.2,15),deg_to_rad(yaw_deg),zoom)
			await trace(tag+"-before")
			await drive(Vector3(-3,1.1,13.2))
			var b1: Dictionary=await trace(tag+"-near")
			check(b1.level==0 and b1.B1,"B1 approach remains visible "+tag)
			check(b1.lens_overlaps.is_empty(),"B1 camera lens outside world "+tag)
			await drive(Vector3(-3,1.1,15))
			await trace(tag+"-after")
	print("APPROACH_RESULT checks=",checks," failures=",failures)
	get_tree().quit(1 if failures else 0)
