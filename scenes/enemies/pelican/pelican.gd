class_name Pelican
extends EnemyCharacter

enum FlightState {
	PATROL,
	DIVE,
	ASCEND,
}

const BULLET_SCENE := preload("res://scenes/enemies/pelican/pelican_bullet.tscn")

@export var patrol_height: float = 5.0
@export var patrol_speed: float = 1.5
@export var patrol_width: float = 4.0
@export var dive_speed: float = 9.0
@export var sight_height: float = 8.0
@export var sight_width: float = 10.0
@export var bullet_drop_interval: float = 3.0
@export var attack_cooldown: float = 1.5


@onready var player_detector: Area3D = $Direction/DetectPlayerArea3D
@onready var hit_area: Area3D = $Direction/HitArea3D

var flight_state: FlightState = FlightState.PATROL
var patrol_center: Vector3
var dive_target: Vector3
var tracked_player: Node3D
var bullet_timer: float
var cooldown_timer: float
var patrol_direction: float = 1.0


func _ready() -> void:
	movement_enabled = false
	gravity = 0.0
	patrol_center = global_position
	bullet_timer = bullet_drop_interval
	hit_area.set_deferred("monitoring", false)
	super._ready()
	anim_player.animation_finished.connect(_on_animation_finished)
	anim_player.play("move")


func _physics_process(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta

	match flight_state:
		FlightState.PATROL:
			_update_patrol(delta)
		FlightState.DIVE:
			_update_dive(delta)
		FlightState.ASCEND:
			_update_ascend(delta)


func _update_patrol(delta: float) -> void:
	var left_bound := patrol_center.x - patrol_width
	var right_bound := patrol_center.x + patrol_width
	if global_position.x >= right_bound:
		patrol_direction = -1.0
	elif global_position.x <= left_bound:
		patrol_direction = 1.0

	velocity = Vector3(patrol_direction * patrol_speed, 0.0, 0.0)
	move_and_slide()
	global_position.y = patrol_center.y + sin(Time.get_ticks_msec() * 0.003) * 0.15
	sprite.flip_h = patrol_direction < 0.0

	bullet_timer -= delta
	if bullet_timer <= 0.0:
		_drop_bullet()
		bullet_timer = bullet_drop_interval

	tracked_player = _find_airborne_player()
	if tracked_player != null and cooldown_timer <= 0.0:
		dive_target = tracked_player.global_position
		flight_state = FlightState.DIVE
		hit_area.set_deferred("monitoring", true)
		anim_player.play("atk")


func _update_dive(_delta: float) -> void:
	if is_instance_valid(tracked_player):
		if tracked_player.is_on_floor():
			flight_state = FlightState.ASCEND
			hit_area.set_deferred("monitoring", false)
			anim_player.play("move")
			return
		dive_target = tracked_player.global_position

	var target := Vector3(dive_target.x, maxf(dive_target.y, patrol_center.y - patrol_height), dive_target.z)
	velocity = global_position.direction_to(target) * dive_speed
	move_and_slide()

	if global_position.distance_to(target) < 0.35 or global_position.y <= patrol_center.y - patrol_height:
		flight_state = FlightState.ASCEND
		hit_area.set_deferred("monitoring", false)
		anim_player.play("move")


func _update_ascend(_delta: float) -> void:
	var target := Vector3(global_position.x, patrol_center.y, global_position.z)
	velocity = global_position.direction_to(target) * dive_speed
	move_and_slide()
	if absf(global_position.y - patrol_center.y) < 0.2:
		global_position.y = patrol_center.y
		velocity = Vector3.ZERO
		flight_state = FlightState.PATROL
		cooldown_timer = attack_cooldown
		bullet_timer = bullet_drop_interval
		anim_player.play("move")


func _find_airborne_player() -> Node3D:
	for body in player_detector.get_overlapping_bodies():
		if not body is Node3D or not body.has_method("is_on_floor"):
			continue
		if body.is_on_floor():
			continue
		return body
	return null


func _drop_bullet() -> void:
	var bullet := BULLET_SCENE.instantiate()
	register_projectile(bullet)
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + Vector3(0.0, -0.5, 0.0)


func _on_animation_finished(animation_name: StringName) -> void:
	if animation_name == &"atk":
		anim_player.play("move")
