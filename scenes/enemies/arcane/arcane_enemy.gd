extends EnemyCharacter

signal defeated

const BULLET := preload("res://scenes/enemies/skeleton/skeleton_bullet.tscn")
const SKELETON := preload("res://scenes/enemies/skeleton/skeleton_warrior.tscn")

@export_enum("wizard_1", "wizard_2", "necromancer", "executioner", "summon") var kind := "wizard_1"
@export var attack_range := 6.0
@export var attack_cooldown := 1.5
@export var summon_limit := 2
@export var summon_cooldown := 8.0
@export var summon_scene: PackedScene

var state: StringName = &"idle"
var cooldown := 0.8
var summon_timer := 3.0
var attack_count := 0
var attack_target := Vector3.ZERO
var attack_direction := Vector3.FORWARD
var summons: Array[Node3D] = []
var enraged := false
var _frozen_animation := false
var _lifetime := 18.0


func _ready() -> void:
	super._ready()
	anim_player.animation_finished.connect(_on_animation_finished)
	fallback_hurt_finished.connect(_on_fallback_finished)
	anim_player.play("idle")
	if kind == "executioner":
		add_to_group("bosses")
	if kind == "summon":
		_play(&"appear")


func _physics_process(delta: float) -> void:
	if state == &"death":
		return
	if is_skill_frozen():
		anim_player.pause()
		_frozen_animation = true
		return
	if _frozen_animation:
		_frozen_animation = false
		anim_player.play()
	if kind == "summon":
		_lifetime -= delta
		if _lifetime <= 0.0:
			_die()
			return
	cooldown = maxf(0.0, cooldown - delta)
	summon_timer = maxf(0.0, summon_timer - delta)
	if state in [&"idle", &"walk"]:
		stop_horizontal()
		if _has_target():
			var offset := found_player.global_position - global_position
			offset.y = 0.0
			sprite.flip_h = offset.x < 0.0
			if offset.length() <= attack_range and _has_line_of_sight():
				if cooldown <= 0.0:
					_begin_attack(offset)
				else:
					_play(&"idle")
			else:
				velocity.x = offset.normalized().x * movement_speed
				velocity.z = offset.normalized().z * movement_speed
				_play(&"walk")
		else:
			_play(&"idle")
	_update_movement(delta)


func _has_target() -> bool:
	return is_instance_valid(found_player) and found_player is BaseCharacter and found_player.health > 0 and absf(found_player.global_position.y - global_position.y) < 1.5


func _has_line_of_sight() -> bool:
	var ray := PhysicsRayQueryParameters3D.create(global_position + Vector3.UP * 0.7, found_player.global_position + Vector3.UP * 0.7, 1)
	return get_world_3d().direct_space_state.intersect_ray(ray).is_empty()


func _begin_attack(offset: Vector3) -> void:
	attack_target = found_player.global_position + Vector3.UP * 0.7
	attack_direction = offset.normalized()
	attack_count += 1
	summons = summons.filter(func(unit: Node3D) -> bool: return is_instance_valid(unit) and not unit.is_queued_for_deletion())
	if kind in ["necromancer", "executioner"] and summon_timer <= 0.0 and summons.size() < summon_limit:
		_play(&"summon")
	elif kind == "executioner" and attack_count % 3 == 0:
		_play(&"skill")
	elif kind == "wizard_2" and attack_count % 2 == 0:
		_play(&"attack2")
	else:
		_play(&"attack")


## Animation method tracks call this only at the visible impact frame.
func attack() -> void:
	if health <= 0 or is_skill_frozen() or _fallback_hurt_running:
		return
	if state == &"summon":
		_spawn_summon()
		return
	if state not in [&"attack", &"attack2", &"skill"]:
		return
	if kind in ["wizard_1", "necromancer"]:
		var bullet := BULLET.instantiate() as RigidBody3D
		get_parent().add_child(bullet)
		bullet.global_position = global_position + Vector3.UP * 0.7
		bullet.linear_velocity = bullet.global_position.direction_to(attack_target) * 7.0
		bullet.get_node("HitArea3D").damage = attack_damage
		register_projectile(bullet)
	elif _has_target() and _has_line_of_sight():
		var offset := found_player.global_position - global_position
		offset.y = 0.0
		var reach := attack_range + (1.0 if state == &"skill" else 0.0)
		if offset.length() > reach:
			return
		if state != &"skill" and offset.length() > 0.1 and attack_direction.dot(offset.normalized()) < 0.3:
			return
		var hurt := found_player.get_node_or_null("Direction/HurtArea3D") as HurtArea3D
		if hurt != null:
			hurt.take_damage(offset.normalized(), attack_damage + (1 if state == &"skill" else 0), self)


func _spawn_summon() -> void:
	if summons.size() >= summon_limit:
		return
	var packed := summon_scene if summon_scene != null else SKELETON
	# Place only on a nearby world surface with room for the summoned body.
	for side in [-1.0, 1.0]:
		var point := global_position + Vector3(side * 1.4, 1.0, 0.0)
		var ray := PhysicsRayQueryParameters3D.create(point, point - Vector3.UP * 2.0, 1)
		var floor_hit := get_world_3d().direct_space_state.intersect_ray(ray)
		if floor_hit.is_empty():
			continue
		var spawn_position: Vector3 = floor_hit.position + Vector3.UP * 0.05
		var query := PhysicsShapeQueryParameters3D.new()
		var shape := CapsuleShape3D.new()
		shape.radius = 0.35
		shape.height = 1.2
		query.shape = shape
		query.transform.origin = spawn_position + Vector3.UP * 0.6
		query.collision_mask = 11
		if not get_world_3d().direct_space_state.intersect_shape(query).is_empty():
			continue
		var unit := packed.instantiate() as EnemyCharacter
		unit.skill_point_drop = 0
		get_parent().add_child(unit)
		unit.global_position = spawn_position
		unit.found_player = found_player
		summons.append(unit)
		break
	summon_timer = summon_cooldown


func _on_hurt_area_3d_hurt(_hit_direction: Vector3, damage: float) -> void:
	if invincible or state in [&"death", &"hurt", &"appear"] or _fallback_hurt_running or damage <= 0.0:
		return
	take_damage(int(damage))
	stop_horizontal()
	if health <= 0:
		_die()
	else:
		if kind == "executioner" and health * 2 <= max_health:
			enraged = true
		state = &"hurt"
		if has_hurt_animation():
			anim_player.play("hurt")


func _enter_parry_hurt(_hit_direction: Vector3) -> void:
	if state == &"death":
		return
	stop_horizontal()
	state = &"hurt"
	if has_hurt_animation():
		anim_player.play("hurt")
	else:
		_play_fallback_hurt()


func _on_fallback_finished() -> void:
	if state == &"hurt" and health > 0:
		cooldown = attack_cooldown * (0.65 if enraged else 1.0)
		_play(&"idle")


func _die() -> void:
	health = 0
	stop_move()
	movement_enabled = false
	$Direction/HurtArea3D.set_deferred("collision_layer", 0)
	$CollisionShape3D.set_deferred("disabled", true)
	_clear_summons()
	_play(&"death")
	defeated.emit()


func _clear_summons() -> void:
	for unit in summons:
		if is_instance_valid(unit):
			unit.queue_free()
	summons.clear()


func _exit_tree() -> void:
	_clear_summons()


func _play(next: StringName) -> void:
	if state == next:
		return
	state = next
	anim_player.play(state)


func _on_animation_finished(animation: StringName) -> void:
	if animation == &"death":
		queue_free()
	elif state != &"death":
		cooldown = attack_cooldown * (0.65 if enraged else 1.0)
		_play(&"idle")
