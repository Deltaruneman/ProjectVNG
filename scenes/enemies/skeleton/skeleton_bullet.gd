extends RigidBody3D

@export var lifetime: float = 4.0
var _reflected := false
var _consumed := false


func _ready() -> void:
	$HitArea3D.hitted.connect(_on_hitted)
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(queue_free)


func _on_hitted(area: Area3D) -> void:
	# The Player HurtArea contact that triggers a successful parry is not a returned hit.
	if _reflected and (area.collision_layer & 4) != 0:
		return
	_consume()


func _on_body_entered(_body: Node) -> void:
	_consume()


func _consume() -> void:
	if _consumed:
		return
	_consumed = true
	$HitArea3D.projectile_consumed = true
	$HitArea3D.set_deferred("monitoring", false)
	queue_free()


func parry_from_player(_player: Node3D) -> void:
	if _reflected:
		return
	_reflected = true
	var speed := maxf(linear_velocity.length(), 1.0)
	var reverse := -linear_velocity
	if reverse.length_squared() < 0.0001:
		reverse = Vector3.BACK
	linear_velocity = reverse.normalized() * speed
	$HitArea3D.attacker = _player
	$HitArea3D.set_deferred("collision_mask", 16)
