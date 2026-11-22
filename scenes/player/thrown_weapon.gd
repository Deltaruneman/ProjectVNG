extends Node3D
const CATALOG := preload("res://scripts/item_catalog.gd")
const DROP_KEY := "thrown_main_weapon"
var thrower: Player
var definition := ""
var item_uid := ""
var target := Vector3.ZERO
var origin := Vector3.ZERO
var damage := 1
const ARC_HEIGHT := 0.35
var falling := false
var fall_speed := 0.0
var fall_elapsed := 0.0
var safe_origin := Vector3.ZERO
var landed := false
var elapsed := 0.0
var duration := 0.6
var visual: Sprite3D
var visual_texture: Texture2D
var visual_pixel_size := 0.035
var visual_scale := Vector3.ONE
var prompt: Label3D
var hit_ids: Dictionary = {}

func _ready() -> void:
	add_to_group("thrown_weapons")
	visual = Sprite3D.new()
	visual.texture = visual_texture if visual_texture != null else CATALOG.texture(definition)
	visual.pixel_size = visual_pixel_size
	visual.scale = visual_scale
	visual.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	add_child(visual)
	prompt = Label3D.new()
	prompt.text = "F · Nhặt vũ khí"
	prompt.position.y = 1.1
	prompt.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	prompt.font_size = 40
	prompt.visible = false
	add_child(prompt)

func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera != null:
		var angle := -PI if definition == "starter_blade" else -PI * 1.25
		visual.global_basis = (camera.global_basis * Basis(Vector3.BACK, angle if landed else elapsed * 18.0)).scaled_local(visual_scale)
	var player := get_tree().get_first_node_in_group("player") as Player
	prompt.visible = landed and player != null and player.can_interact() and player.global_position.distance_to(global_position) < 2.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and not event.is_echo():
		if pickup():
			get_viewport().set_input_as_handled()

func pickup() -> bool:
	var player := get_tree().get_first_node_in_group("player") as Player
	if not landed or player == null or not player.can_interact() or player.global_position.distance_to(global_position) >= 2.0 or GameManager.has_checkpoint_conflict():
		return false
	var record: Dictionary = GameManager.flags.get(DROP_KEY, {})
	if str(record.get("uid", "")) != item_uid or not GameManager.inventory.items.has(item_uid):
		return false
	# Retain a tombstone: save_game merges flags with old payload fields.
	GameManager.flags[DROP_KEY] = {}
	GameManager.equip_item(item_uid)
	landed = false
	queue_free()
	return true

func _world_query(from: Vector3, to: Vector3) -> PhysicsRayQueryParameters3D:
	var mask := thrower.collision_mask if is_instance_valid(thrower) else 9
	var query := PhysicsRayQueryParameters3D.create(from, to, mask)
	if is_instance_valid(thrower):
		query.exclude = [thrower.get_rid()]
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if enemy is CollisionObject3D:
			query.exclude = query.exclude + [enemy.get_rid()]
	return query

func _physics_process(delta: float) -> void:
	if landed:
		return
	var space := get_world_3d().direct_space_state
	if falling:
		fall_elapsed += delta
		fall_speed += 12.0 * delta
		var down := global_position + Vector3.DOWN * maxf(0.05, fall_speed * delta)
		var floor_hit := space.intersect_ray(_world_query(global_position + Vector3.UP * 0.01, down))
		if not floor_hit.is_empty() and floor_hit.normal.y > 0.5:
			_land(floor_hit.position)
		elif fall_elapsed > 3.0:
			# No reachable floor (e.g. a void): retain a recoverable drop at launch.
			_land(safe_origin)
		else:
			global_position = down
		return
	if elapsed == 0.0:
		safe_origin = thrower.global_position if is_instance_valid(thrower) else origin
	elapsed += delta
	var t := clampf(elapsed / duration, 0.0, 1.0)
	var next := origin.lerp(target, t) + Vector3.UP * (4.0 * t * (1.0 - t) * ARC_HEIGHT)
	var wall := space.intersect_ray(_world_query(global_position, next))
	if not wall.is_empty():
		# Stay just before the surface; a ceiling/wall hit must fall, not stick high.
		next = wall.position + wall.normal * 0.04
	_damage_sweep(global_position, next)
	global_position = next
	if not wall.is_empty():
		if wall.normal.y > 0.5:
			_land(wall.position)
		else:
			falling = true
	elif t >= 1.0:
		falling = true

func _damage_sweep(from: Vector3, to: Vector3) -> void:
	if not is_instance_valid(thrower):
		return
	var axis := to - from
	var length := axis.length()
	if length < 0.0001:
		return
	axis /= length
	var tangent := axis.cross(Vector3.UP)
	if tangent.length_squared() < 0.001:
		tangent = axis.cross(Vector3.RIGHT)
	tangent = tangent.normalized()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.18
	capsule.height = length + 0.36
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = capsule
	query.transform = Transform3D(Basis(tangent, axis, tangent.cross(axis)), (from + to) * 0.5)
	query.collision_mask = 16
	query.collide_with_areas = true
	query.collide_with_bodies = false
	var space := get_world_3d().direct_space_state
	for hit: Dictionary in space.intersect_shape(query, 64):
		var area := hit.collider as HurtArea3D
		if area == null:
			continue
		var enemy := thrower._get_enemy_from_hurt_area(area)
		if enemy == null or enemy.health <= 0 or hit_ids.has(enemy.get_instance_id()):
			continue
		if not space.intersect_ray(_world_query(from, area.global_position)).is_empty():
			continue
		hit_ids[enemy.get_instance_id()] = true
		area.take_damage(axis, damage, thrower)
		thrower._on_skill_hit(area, "")

func _land(point: Vector3) -> void:
	global_position = point
	target = point
	landed = true
	falling = false
	var record: Dictionary = GameManager.flags.get(DROP_KEY, {})
	if str(record.get("uid", "")) == item_uid:
		record["position"] = [point.x, point.y, point.z]
		GameManager.flags[DROP_KEY] = record
		GameManager.save_game()