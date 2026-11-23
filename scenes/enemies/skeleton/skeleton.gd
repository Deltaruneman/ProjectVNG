extends EnemyCharacter

const BULLET_SCENE := preload("res://scenes/enemies/skeleton/skeleton_bullet.tscn")

@export var ranged: bool = false
@export var attack_range: float = 1.5
@export var attack_cooldown: float = 0.8

var state: StringName = &"idle"
var cooldown: float = 0.0
var attack_target: Vector3


func _ready() -> void:
	super._ready()
	anim_player.animation_finished.connect(_on_animation_finished)
	anim_player.play("idle")


func _physics_process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	if state == &"idle" or state == &"walk":
		stop_horizontal()
		if is_instance_valid(found_player):
			var offset := found_player.global_position - global_position
			offset.y = 0.0
			if absf(offset.x) > 0.01:
				sprite.flip_h = offset.x < 0.0
			if offset.length() <= attack_range and absf(found_player.global_position.y - global_position.y) < 1.5:
				if cooldown <= 0.0:
					attack_target = found_player.global_position + Vector3.UP * 0.7
					_play(&"attack")
				else:
					_play(&"idle")
			elif not ranged:
				velocity.x = offset.normalized().x * movement_speed
				velocity.z = offset.normalized().z * movement_speed
				_play(&"walk")
			else:
				_play(&"idle")
		else:
			_play(&"idle")
	_update_movement(delta)


func _play(next: StringName) -> void:
	if state == next:
		return
	state = next
	anim_player.play(state)


# Called once by the attack animation, at the impact/cast frame.
func attack() -> void:
	if state != &"attack":
		return
	if ranged:
		var bullet := BULLET_SCENE.instantiate() as RigidBody3D
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position + Vector3.UP * 0.7
		bullet.linear_velocity = bullet.global_position.direction_to(attack_target) * 7.0
		bullet.get_node("HitArea3D").damage = attack_damage
		register_projectile(bullet)
	elif is_instance_valid(found_player):
		var offset := found_player.global_position - global_position
		if Vector2(offset.x, offset.z).length() <= attack_range and absf(offset.y) < 1.5:
			var hurt_area := found_player.get_node_or_null("Direction/HurtArea3D")
			if hurt_area != null:
				offset.y = 0.0
				hurt_area.take_damage(offset.normalized(), attack_damage, self)


func _on_hurt_area_3d_hurt(hit_direction: Vector3, damage: float) -> void:
	if state == &"death" or state == &"hurt":
		return
	take_damage(int(damage))
	stop_horizontal()
	if health <= 0:
		$Direction/HurtArea3D.set_deferred("collision_layer", 0)
		$CollisionShape3D.set_deferred("disabled", true)
		movement_enabled = false
		_play(&"death")
	else:
		velocity.x = hit_direction.x * 2.0
		velocity.z = hit_direction.z * 2.0
		_play(&"hurt")


func _enter_parry_hurt(hit_direction: Vector3) -> void:
	velocity.x = hit_direction.x * 2.0
	velocity.z = hit_direction.z * 2.0
	_play(&"hurt")


func _on_animation_finished(animation: StringName) -> void:
	if animation == &"death":
		queue_free()
	elif animation == &"attack" or animation == &"hurt":
		stop_horizontal()
		cooldown = attack_cooldown
		_play(&"idle")
