extends Node3D
## Swept offhand flight: one hit per character; world obstruction always wins.
const CATALOG := preload("res://scripts/item_catalog.gd")
var thrower: Player
var direction := Vector3.FORWARD
var elemental_form := ""
var damage := 1
var speed := 14.0
var max_distance := 7.0
var travelled := 0.0
var definition := "bow"
var hit_ids: Dictionary = {}
var visual: Sprite3D

func _ready() -> void:
	visual = Sprite3D.new()
	var data := CATALOG.item(definition)
	visual.texture = load(CATALOG.RAVEN + str(data.get("projectile_icon", "DaggerT1")) + ".png")
	visual.pixel_size = 0.006
	visual.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	visual.no_depth_test = false
	visual.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	visual.modulate = {"fire": Color("ff995f"), "ice": Color("8deaff"), "lightning": Color("ffed7a"), "wind": Color("a3ffd7")}.get(elemental_form, Color.WHITE)
	add_child(visual)

func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera != null:
		var point := camera.unproject_position(global_position)
		var offset := camera.unproject_position(global_position + direction) - point
		visual.rotation.z = -offset.angle() - PI / 4.0

func _physics_process(delta: float) -> void:
	if not is_instance_valid(thrower) or thrower.health <= 0:
		queue_free()
		return
	var step := minf(speed * delta, max_distance - travelled)
	var destination := global_position + direction * step
	var space := get_world_3d().direct_space_state
	var wall_query := PhysicsRayQueryParameters3D.create(global_position, destination, thrower.collision_mask)
	var world_exclusions: Array[RID] = [thrower.get_rid()]
	# Some inherited enemy scenes still use the default body layer. Their hurt
	# areas, rather than their movement bodies, decide projectile contact.
	for enemy_body: Node in get_tree().get_nodes_in_group("enemies"):
		if enemy_body is CollisionObject3D:
			world_exclusions.append(enemy_body.get_rid())
	wall_query.exclude = world_exclusions
	var wall := space.intersect_ray(wall_query)
	if not wall.is_empty():
		destination = wall.position
	# Ray to the wall endpoint; then overlap a narrow swept sphere for hurt areas.
	var length := global_position.distance_to(destination)
	var shape := CapsuleShape3D.new()
	shape.radius = 0.14
	shape.height = maxf(0.28, length + 0.28)
	var sweep := PhysicsShapeQueryParameters3D.new()
	sweep.shape = shape
	var axis := direction.normalized()
	var tangent := axis.cross(Vector3.UP)
	if tangent.length_squared() < 0.001:
		tangent = axis.cross(Vector3.RIGHT)
	tangent = tangent.normalized()
	sweep.transform = Transform3D(Basis(tangent, axis, tangent.cross(axis)), (global_position + destination) * 0.5)
	sweep.collision_mask = 16
	sweep.collide_with_areas = true
	sweep.collide_with_bodies = false
	var hits := space.intersect_shape(sweep, 64)
	hits.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return global_position.distance_squared_to(a.collider.global_position) < global_position.distance_squared_to(b.collider.global_position))
	for hit: Dictionary in hits:
		var area := hit.collider as HurtArea3D
		if area == null:
			continue
		var enemy := thrower._get_enemy_from_hurt_area(area)
		if enemy == null or enemy.health <= 0 or hit_ids.has(enemy.get_instance_id()):
			continue
		# A wide hurt area on the far side of a wall must not receive splash-through.
		var sight := PhysicsRayQueryParameters3D.create(global_position, area.global_position, thrower.collision_mask)
		sight.exclude = world_exclusions
		if not space.intersect_ray(sight).is_empty():
			continue
		hit_ids[enemy.get_instance_id()] = true
		area.take_damage(direction, damage, thrower)
		thrower._weapon_hit_effect(area, "offhand")
		thrower._on_skill_hit(area, elemental_form)
		if elemental_form != "wind":
			queue_free()
			return
	global_position = destination
	travelled += step
	if not wall.is_empty() or travelled >= max_distance:
		queue_free()
