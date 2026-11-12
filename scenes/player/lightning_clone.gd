extends Node3D

const BattleFX := preload("res://scenes/player/battle_vfx.gd")

const LIFETIME := 5.0
const TARGET_REFRESH_INTERVAL := 0.35
const ATTACK_REACH := 2.4
const ATTACK_WIDTH := 3.178

var _caster: Node3D
var _source_sprite: Sprite3D
var _clone_sprite: Sprite3D
var _path_agent: PathAgent
var _pathfinder: GridPathfinder
var _target: EnemyCharacter
var _skill_damage := 1
var _storm_rank := 0
var _attack_interval := 1.2
var _movement_speed := 6.0
var _elapsed := 0.0
var _attack_timer := 1.2
var _target_refresh_timer := 0.0
var _detonated := false


func configure(caster: Node3D, skill_damage: int, storm_rank: int, attack_interval: float, movement_speed: float, source_sprite: Sprite3D) -> void:
	_caster = caster
	_skill_damage = maxi(skill_damage, 1)
	_storm_rank = maxi(storm_rank, 0)
	_attack_interval = maxf(attack_interval, 0.1)
	_attack_timer = _attack_interval
	_movement_speed = maxf(movement_speed, 0.1)
	_source_sprite = source_sprite
	if is_instance_valid(caster):
		global_transform = caster.global_transform


func _ready() -> void:
	_path_agent = PathAgent.new()
	_path_agent.name = "PathAgent"
	add_child(_path_agent)
	_pathfinder = GridPathfinder.find(self)
	_create_clone_sprite()
	if is_instance_valid(_caster) and _caster.has_signal("died"):
		_caster.connect("died", _on_caster_died, CONNECT_ONE_SHOT)
	if is_instance_valid(_caster):
		BattleFX.play_pvfx(_caster, "lightning/static-burst", global_position + Vector3.UP * 0.55, 2.7, Color("e5fbff"))


func _process(_delta: float) -> void:
	if is_instance_valid(_source_sprite) and is_instance_valid(_clone_sprite):
		_clone_sprite.frame = _source_sprite.frame
		_clone_sprite.flip_h = _source_sprite.flip_h


func _physics_process(delta: float) -> void:
	if not _caster_is_alive():
		queue_free()
		return
	_elapsed += delta
	if _elapsed >= LIFETIME:
		_detonate()
		return
	_attack_timer -= delta
	_reselect_target_if_needed(delta)
	if not is_instance_valid(_target):
		return
	var target_offset := _target.global_position - global_position
	var target_distance := Vector2(target_offset.x, target_offset.z).length()
	if target_distance <= ATTACK_REACH and absf(target_offset.y) <= 2.5:
		if _attack_timer <= 0.0:
			_perform_basic_attack()
			_attack_timer = _attack_interval
		return
	_follow_target(delta)


func _create_clone_sprite() -> void:
	if not is_instance_valid(_source_sprite):
		return
	_clone_sprite = Sprite3D.new()
	_clone_sprite.name = "LightningCloneSprite"
	_clone_sprite.texture = _source_sprite.texture
	_clone_sprite.hframes = _source_sprite.hframes
	_clone_sprite.vframes = _source_sprite.vframes
	_clone_sprite.frame = _source_sprite.frame
	_clone_sprite.pixel_size = _source_sprite.pixel_size
	_clone_sprite.offset = _source_sprite.offset
	_clone_sprite.position = _source_sprite.position
	_clone_sprite.rotation = _source_sprite.rotation
	_clone_sprite.scale = _source_sprite.scale
	_clone_sprite.centered = _source_sprite.centered
	_clone_sprite.billboard = _source_sprite.billboard
	_clone_sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	_clone_sprite.shaded = false
	_clone_sprite.modulate = Color(0.55, 0.9, 1.0, 0.78)
	add_child(_clone_sprite)


func _reselect_target_if_needed(delta: float) -> void:
	_target_refresh_timer -= delta
	if is_instance_valid(_target) and _target.health <= 0:
		_target = null
		_target_refresh_timer = 0.0
	if _target_refresh_timer > 0.0:
		return
	_target = _find_nearest_enemy()
	_target_refresh_timer = TARGET_REFRESH_INTERVAL
	if is_instance_valid(_target):
		_path_agent.target_position = _target.global_position


func _find_nearest_enemy() -> EnemyCharacter:
	var nearest: EnemyCharacter
	var nearest_distance_squared := INF
	for candidate: Node in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(candidate) or not (candidate is EnemyCharacter):
			continue
		var enemy := candidate as EnemyCharacter
		if enemy.health <= 0 or enemy.get_node_or_null("Direction/HurtArea3D") == null:
			continue
		if _pathfinder != null and _pathfinder.find_path(global_position, enemy.global_position).is_empty():
			continue
		var offset := enemy.global_position - global_position
		var distance_squared := Vector2(offset.x, offset.z).length_squared()
		if distance_squared < nearest_distance_squared:
			nearest = enemy
			nearest_distance_squared = distance_squared
	return nearest


func _follow_target(delta: float) -> void:
	if not is_instance_valid(_target):
		return
	var next_position := _path_agent.get_next_path_position()
	if _pathfinder == null:
		var direct_offset := _target.global_position - global_position
		direct_offset.y = 0.0
		if direct_offset.length_squared() > 0.0001:
			global_position += direct_offset.normalized() * _movement_speed * delta
		return
	var path_offset := next_position - global_position
	if path_offset.length_squared() > 0.0001:
		global_position = global_position.move_toward(next_position, _movement_speed * delta)


func _perform_basic_attack() -> void:
	if not _caster_is_alive() or not is_instance_valid(_target):
		return
	var direction := _target.global_position - global_position
	direction.y = 0.0
	if direction.length_squared() < 0.0001:
		direction = Vector3.MODEL_FRONT
	direction = direction.normalized()
	var basic_damage := maxi(int(_caster.get("attack_damage")), 1)
	var hit_count := int(_caster.call("_damage_enemies_in_shape", global_position, direction, "box", ATTACK_REACH, ATTACK_WIDTH, 0.0, basic_damage))
	if hit_count > 0 and is_instance_valid(_target):
		BattleFX.play_pvfx(_caster, "lightning/lightning-strike", _target.global_position + Vector3.UP * 0.35, 2.1, Color("f4fdff"))


func _detonate() -> void:
	if _detonated:
		return
	_detonated = true
	if _caster_is_alive():
		BattleFX.play_pvfx(_caster, "lightning/static-burst", global_position + Vector3.UP * 0.6, 4.8, Color("effdff"))
		var hit_count := int(_caster.call("_damage_enemies_in_shape", global_position, Vector3.ZERO, "circle", 3.0, 0.0, 360.0, _skill_damage * (3 + _storm_rank), 0.6, 0.0, 0.0, 0.0, 0, "electrified"))
		if hit_count > 0:
			BattleFX.play_skill_sound(_caster, "lightning_hit")
	queue_free()


func _caster_is_alive() -> bool:
	return is_instance_valid(_caster) and _caster.is_inside_tree() and int(_caster.get("health")) > 0


func _on_caster_died() -> void:
	queue_free()
