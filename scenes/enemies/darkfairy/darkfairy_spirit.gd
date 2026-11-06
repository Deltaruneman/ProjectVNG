extends EnemyCharacter

var target: Node3D
var state: StringName = &"summoned"
var lifetime := 12.0


func _ready() -> void:
	super._ready()
	$HitArea3D.attacker = self
	$HitArea3D.damage = attack_damage
	anim_player.animation_finished.connect(_on_animation_finished)
	anim_player.play("spirit_summoned")


func _physics_process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0 and state != &"death":
		_die()
	if state != &"idle":
		return
	if not is_instance_valid(target) or target.health <= 0:
		_die()
		return
	var offset := target.global_position - global_position
	offset.y = 0.0
	velocity = offset.normalized() * movement_speed
	move_and_slide()
	sprite.flip_h = offset.x < 0.0
	if absf(target.global_position.y - global_position.y) > 3.0:
		_die()


func _on_hurt_area_3d_hurt(_hit_direction: Vector3, damage: float) -> void:
	if state in [&"death", &"hurt"]:
		return
	take_damage(int(damage))
	if health <= 0:
		_die()
	else:
		_hurt()


func _enter_parry_hurt(_hit_direction: Vector3) -> void:
	if state != &"death":
		_hurt()


func _hurt() -> void:
	state = &"hurt"
	$HitArea3D.set_deferred("monitoring", false)
	anim_player.play("spirit_hurt")


func _die() -> void:
	state = &"death"
	$HitArea3D.set_deferred("monitoring", false)
	$Direction/HurtArea3D.set_deferred("collision_layer", 0)
	anim_player.play("spirit_death")


func _on_animation_finished(animation: StringName) -> void:
	if animation == &"spirit_death":
		queue_free()
	else:
		state = &"idle"
		$HitArea3D.set_deferred("monitoring", true)
		anim_player.play("spirit_idle")
