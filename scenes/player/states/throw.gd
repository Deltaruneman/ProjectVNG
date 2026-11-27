class_name PlayerThrowState
extends PlayerState

@export var min_throw_range := 3.0 
@export var max_throw_range := 6.0 
@export var apex_time := 0.3       
@export var recover_time := 0.3    

var _time := 0.0


func _enter() -> void:
	_time = 0.0
	obj.stop_horizontal()

	var carry: PlayerCarryState = fsm.states.carry
	var target: Node3D = carry.carried
	carry.carried = null
	if target == null:
		change_state(fsm.states.idle)
		return
	var dir: Vector3 = carry.facing
	if dir == Vector3.ZERO:
		dir = obj.get_node("Direction").global_transform.basis.z   # +Z là hướng trước (MODEL_FRONT)
		dir.y = 0.0
		dir = dir.normalized()

	target.reparent(obj.get_parent(), true)

	var thrown = target.fsm.states.thrown
	var g: float = thrown.gravity
	var vy := g * apex_time
	var h: float = maxf(target.global_position.y - obj.global_position.y, 0.0)
	var flight_time := (vy + sqrt(vy * vy + 2.0 * g * h)) / g
	var throw_range := lerpf(min_throw_range, max_throw_range, carry.charge_ratio)
	var vh := throw_range / flight_time

	thrown.launch_velocity = dir * vh + Vector3.UP * vy
	thrown.deals_damage = true
	thrown.thrower = obj
	target.fsm.change_state(thrown)


func _update(delta: float) -> void:
	_time += delta
	if _time >= recover_time:
		change_state(fsm.states.idle)
