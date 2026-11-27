extends Node3D
## Scene-owned flights, ground zones and one player infection, all on gameplay time.

const NODE_NAME := "PoisonPotionEffects"
const CATALOG := preload("res://scripts/item_catalog.gd")
const ZONE_FRAMES := preload("res://assets/effects/pixelfx/arcane/venom-zone.tres")
const ZONE_MATERIAL := preload("res://assets/effects/pixelfx/arcane/venom-zone-material.tres")
const WORLD_LAYER := 1
const THROW_RANGE := 4.0
const LANDING_STEP := 0.25
const STEP_HEIGHT := 0.43
const MIN_FLOOR_NORMAL_Y := 0.64
const FLIGHT_SECONDS := 0.42
const ARC_HEIGHT := 0.28
const BOTTLE_CLEARANCE := 0.10
const ZONE_RADIUS := 1.0
const ZONE_SECONDS := 8.0
const ENEMY_INTERVAL := 1.0
const FOX_INTERVAL := 2.0
const SAME_FLOOR_HEIGHT := 0.85
const LINE_HEIGHT := Vector3.UP * 0.45
const EPSILON := 0.000001


class Flight:
	var origin: Vector3
	var landing: Vector3
	var normal: Vector3
	var elapsed := 0.0
	var visual: Sprite3D


class Zone:
	var center: Vector3
	var expires_at: float
	var next_hit_at: float
	var visual: AnimatedSprite3D


var flights: Array[Flight] = []
var zones: Array[Zone] = []
var gameplay_time := 0.0
var infection_until := 0.0
var next_infection_hit := 0.0
@onready var _player: Node3D = get_parent().player


func _ready() -> void:
	_player.health_changed.connect(_on_player_health_changed)


static func infection_remaining(player: Node3D) -> float:
	if player.health <= 0:
		return 0.0
	var effects := player.get_parent().get_node_or_null(NODE_NAME)
	if effects == null:
		return 0.0
	return maxf(0.0, effects.infection_until - effects.gameplay_time)


func throw_from_camera() -> bool:
	var camera := get_viewport().get_camera_3d()
	var direction: Vector3 = -camera.global_basis.z if camera != null else _player.forward()
	direction.y = 0.0
	if direction.length_squared() < 0.01:
		direction = _player.forward()
	var origin := _player.global_position + Vector3.UP * 0.85
	var landing := _find_landing(_player.global_position, direction.normalized(), origin)
	if landing.is_empty():
		return false
	var flight := Flight.new()
	flight.origin = origin
	flight.landing = landing.position
	flight.normal = landing.normal
	flight.visual = Sprite3D.new()
	flight.visual.name = "VenomBottle"
	flight.visual.texture = CATALOG.texture("venom_potion")
	flight.visual.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	flight.visual.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	flight.visual.pixel_size = 0.013
	add_child(flight.visual)
	flight.visual.global_position = origin
	flights.append(flight)
	return true


func _find_landing(feet: Vector3, direction: Vector3, origin: Vector3) -> Dictionary:
	var support := _floor_near(feet, 0.22, 1.25)
	if support.is_empty():
		return {}
	# Follow the local floor (including a ramp) instead of casting through a
	# stair opening to another floor or accepting a point behind a wall.
	var candidates: Array[Dictionary] = []
	var previous: Vector3 = support.position
	for step in range(1, int(THROW_RANGE / LANDING_STEP) + 1):
		var sample := feet + direction * (step * LANDING_STEP)
		sample.y = previous.y
		var floor_hit := _floor_near(sample, STEP_HEIGHT, STEP_HEIGHT)
		if floor_hit.is_empty() or not _clear_line(previous + LINE_HEIGHT, floor_hit.position + LINE_HEIGHT):
			break
		candidates.append(floor_hit)
		previous = floor_hit.position
	for index in range(candidates.size() - 1, -1, -1):
		var hit := candidates[index]
		if _flight_is_clear(origin, hit.position + Vector3.UP * BOTTLE_CLEARANCE):
			return hit
	return {}


func _floor_near(point: Vector3, lift: float, drop: float) -> Dictionary:
	var hit := _world_ray(point + Vector3.UP * lift, point + Vector3.DOWN * drop)
	return hit if not hit.is_empty() and hit.normal.y >= MIN_FLOOR_NORMAL_Y else {}


func _flight_is_clear(origin: Vector3, destination: Vector3) -> bool:
	var previous := origin
	for sample in range(1, 9):
		var point := _arc_point(origin, destination, sample / 8.0)
		if not _clear_line(previous, point):
			return false
		previous = point
	return true


func _arc_point(origin: Vector3, destination: Vector3, fraction: float) -> Vector3:
	return origin.lerp(destination, fraction) + Vector3.UP * (4.0 * fraction * (1.0 - fraction) * ARC_HEIGHT)


func _world_ray(from: Vector3, to: Vector3) -> Dictionary:
	var query := PhysicsRayQueryParameters3D.create(from, to, WORLD_LAYER)
	query.hit_from_inside = true
	return get_world_3d().direct_space_state.intersect_ray(query)


func _clear_line(from: Vector3, to: Vector3) -> bool:
	return from.distance_squared_to(to) <= EPSILON or _world_ray(from, to).is_empty()


func _covers(center: Vector3, at: Vector3) -> bool:
	var offset := at - center
	return Vector2(offset.x, offset.z).length_squared() <= ZONE_RADIUS * ZONE_RADIUS \
		and absf(offset.y) <= SAME_FLOOR_HEIGHT and _clear_line(center + LINE_HEIGHT, at + LINE_HEIGHT)


func _physics_process(delta: float) -> void:
	# Sample exposure at this step's starting time so a full interval can
	# tick exactly at the deadline rather than being shortened by one step.
	_sample_player_exposure()
	gameplay_time += delta
	_tick_player_infection()
	_tick_zones()
	_advance_flights(delta)


func _sample_player_exposure() -> void:
	if _player.health <= 0:
		return
	var deadline := infection_until
	for zone in zones:
		if zone.expires_at > gameplay_time and _covers(zone.center, _player.global_position):
			deadline = maxf(deadline, zone.expires_at)
	if deadline > gameplay_time and infection_until <= gameplay_time:
		next_infection_hit = gameplay_time + FOX_INTERVAL
	infection_until = deadline


func _tick_player_infection() -> void:
	if infection_until <= 0.0 or _player.health <= 0:
		return
	var last_active_time := minf(gameplay_time, infection_until)
	while next_infection_hit <= last_active_time + EPSILON:
		next_infection_hit += FOX_INTERVAL
		# This periodic cost uses HP directly. Lethal damage uses the normal
		# Player death entry point, including the checkpoint/respawn path.
		if _player.health == 1:
			_player.die()
			return
		_player.health -= 1
	if gameplay_time + EPSILON >= infection_until:
		_clear_infection()


func _on_player_health_changed(current: float, _maximum: int) -> void:
	if current <= 0:
		_clear_infection()


func _clear_infection() -> void:
	infection_until = 0.0
	next_infection_hit = 0.0


func _tick_zones() -> void:
	for index in range(zones.size() - 1, -1, -1):
		var zone := zones[index]
		var last_active_time := minf(gameplay_time, zone.expires_at)
		while zone.next_hit_at <= last_active_time + EPSILON:
			zone.next_hit_at += ENEMY_INTERVAL
			_damage_enemies(zone)
		if gameplay_time + EPSILON >= zone.expires_at:
			zone.visual.hide()
			zone.visual.queue_free()
			zones.remove_at(index)


func _damage_enemies(zone: Zone) -> void:
	for member in get_tree().get_nodes_in_group("enemies"):
		var enemy := member as Node3D
		if not is_instance_valid(enemy) or not get_parent().is_ancestor_of(enemy) \
			or enemy.health <= 0 or not _covers(zone.center, enemy.global_position):
			continue
		var hurt := enemy.get_node_or_null("Direction/HurtArea3D") as HurtArea3D
		if hurt != null:
			hurt.take_damage(Vector3.ZERO, 1.0, _player)


func _advance_flights(delta: float) -> void:
	# Resolve in launch order when two bottles land during the same step.
	for flight in flights.duplicate():
		flight.elapsed += delta
		var fraction := minf(flight.elapsed / FLIGHT_SECONDS, 1.0)
		flight.visual.global_position = _arc_point(
			flight.origin, flight.landing + Vector3.UP * BOTTLE_CLEARANCE, fraction)
		if fraction >= 1.0:
			flight.visual.queue_free()
			flights.erase(flight)
			_impact(flight.landing, flight.normal)


func _impact(point: Vector3, normal: Vector3) -> void:
	for zone in zones:
		if _covers(zone.center, point):
			zone.expires_at = gameplay_time + ZONE_SECONDS
			return
	var zone := Zone.new()
	zone.center = point
	zone.expires_at = gameplay_time + ZONE_SECONDS
	zone.next_hit_at = gameplay_time + ENEMY_INTERVAL
	zone.visual = _make_zone_visual(point, normal)
	zones.append(zone)


func _make_zone_visual(point: Vector3, normal: Vector3) -> AnimatedSprite3D:
	var sprite := AnimatedSprite3D.new()
	sprite.name = "VenomZone"
	sprite.sprite_frames = ZONE_FRAMES
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sprite.pixel_size = 2.0 * ZONE_RADIUS / 44.0
	sprite.material_override = ZONE_MATERIAL
	add_child(sprite)
	sprite.global_position = point + normal * 0.035
	# All four packed pivots are (22, 7) in the 44×14 trims. Undo the baked
	# vertical foreshortening to place the motif on a one-meter ground disk.
	var tangent := Vector3.RIGHT.slide(normal).normalized()
	sprite.global_basis = Basis(tangent, normal.cross(tangent), normal).scaled_local(Vector3(1.0, 44.0 / 14.0, 1.0))
	sprite.play("default")
	return sprite
