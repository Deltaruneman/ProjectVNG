class_name EnemyZone
extends Area3D

signal cleared

## A box that spawns one finite set of enemy slots. A defeated slot stays defeated across stage
## reloads; a living slot is recreated at its starting state when the Stage reloads.
##
## The box is the CollisionShape3D's BoxShape3D: drag its handles in the editor to resize the zone.
## The Area3D itself detects nothing (no layer, no mask) — it is only there to give the box a shape
## you can see and edit.

## What the zone spawns. Whatever has a `zone` property gets this zone written into it.
@export var enemy_scene: PackedScene
@export var max_enemies := 3
## Limit the number of enemies that must be defeated. Zero means this zone has no clear quota.
@export var clear_kills := 0
## Seconds between two spawns.
@export var spawn_interval := 4.0
## How far (flat, in meters) from the zone's center its enemies may chase the fox before giving up
## and walking back. Keep it larger than half the box's diagonal: otherwise an enemy wandering to a
## corner of the box would already count as too far.
@export var leash_radius := 7.0

var _alive := 0
var _defeated := 0
var _zone_key := ""
var _defeated_slots: Dictionary = {}
var _spawned_slots: Dictionary = {}
var _enemy_slots: Dictionary = {}

@onready var _box: CollisionShape3D = $CollisionShape3D
@onready var _timer: Timer = $Timer


func _ready() -> void:
	_zone_key = _make_zone_key()
	for slot in GameManager.enemy_zone_defeated_slots(_zone_key):
		_defeated_slots[slot] = true
	_defeated = _defeated_slots.size()
	_timer.wait_time = spawn_interval
	_timer.timeout.connect(_on_timer_timeout)
	if enemy_scene == null or _spawn_count() <= 0 or _all_slots_resolved():
		_timer.stop()
		return
	_timer.start()


## How many of this zone's enemies are in the tree right now (a dying one counts until it's gone).
func alive_count() -> int:
	return _alive


func is_cleared() -> bool:
	return clear_kills > 0 and _defeated >= clear_kills


## A random point of the box, pulled to the center of the nearest walkable cell. Vector3.INF when
## the stage has no Pathfinder.
func random_point() -> Vector3:
	var finder := GridPathfinder.find(self)
	if finder == null:
		return Vector3.INF
	var half: Vector3 = (_box.shape as BoxShape3D).size / 2.0
	var local := Vector3(randf_range(-half.x, half.x), 0.0, randf_range(-half.z, half.z))
	return finder.closest_point(_box.global_transform * local)


## The flat distance from the center of the box to `point`.
func distance_from_center(point: Vector3) -> float:
	var center := _box.global_position
	return Vector2(point.x - center.x, point.z - center.z).length()


func _make_zone_key() -> String:
	var stage: Node = self
	while stage != null and not stage is Stage:
		stage = stage.get_parent()
	if stage is Stage:
		return "%s|%s" % [(stage as Stage).scene_file_path, stage.get_path_to(self)]
	return str(get_path())


func _spawn_count() -> int:
	if clear_kills > 0:
		return maxi(0, mini(max_enemies, clear_kills))
	return maxi(0, max_enemies)


func _all_slots_resolved() -> bool:
	return _defeated_slots.size() >= _spawn_count()


func _on_timer_timeout() -> void:
	if _alive >= max_enemies or enemy_scene == null:
		return
	var slot := -1
	for candidate in _spawn_count():
		if _defeated_slots.has(candidate) or _spawned_slots.has(candidate):
			continue
		slot = candidate
		break
	if slot < 0:
		_timer.stop()
		return
	var point := random_point()
	if point == Vector3.INF:
		return    # no Pathfinder in this stage
	var enemy: Node3D = enemy_scene.instantiate()
	if "zone" in enemy:
		enemy.zone = self
	# A sibling of the zone, not a child: rotating or scaling the zone mustn't drag its enemies.
	var container := get_parent() as Node3D
	enemy.position = container.to_local(point)
	container.add_child(enemy)
	_spawned_slots[slot] = true
	_enemy_slots[enemy.get_instance_id()] = slot
	_alive += 1
	enemy.tree_exited.connect(_on_enemy_tree_exited.bind(enemy))


## An enemy that is picked up or thrown is reparented, which fires tree_exited too but leaves it
## alive and coming back: only one that is queued for deletion (Dead and KillZone both queue_free)
## is counted out.
func _on_enemy_tree_exited(enemy: Node) -> void:
	if enemy.is_queued_for_deletion():
		_alive = maxi(0, _alive - 1)
		var enemy_instance_id := enemy.get_instance_id()
		var slot := int(_enemy_slots.get(enemy_instance_id, -1))
		_enemy_slots.erase(enemy_instance_id)
		if slot >= 0 and enemy is EnemyCharacter and enemy.health <= 0 and not _defeated_slots.has(slot):
			_defeated_slots[slot] = true
			_defeated = _defeated_slots.size()
			GameManager.record_enemy_zone_defeat(_zone_key, slot)
			if is_cleared():
				_timer.stop()
				cleared.emit()
