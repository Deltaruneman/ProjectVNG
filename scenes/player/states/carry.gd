class_name PlayerCarryState
extends PlayerState
# scenes/player/states/carry.gd

const CARRY_SPEED_SCALE := 0.6
const LIFT_TIME := 0.2  
var carried: Node3D = null      
var facing := Vector3.ZERO     
var handoff := false           
var charge_ratio := 0.0       
var charging := false
var _charge_time := 0.0
var _time := 0.0

@export var max_charge_time := 1.0


func _enter() -> void:
	handoff = false
	facing = Vector3.ZERO
	_time = 0.0
	charging = false
	charge_ratio = 0.0
	_charge_time = 0.0
	carried = _find_target()
	if carried == null:
		change_state(fsm.states.idle)
		return
	carried.fsm.change_state(carried.fsm.states.carried)
	carried.reparent(obj.get_node("HoldPoint"), true)
	carried.rotation = Vector3.ZERO
func _update(delta: float) -> void:
	if carried == null:
		return
	_time += delta
	if _time >= LIFT_TIME:
		if not charging and Input.is_action_just_pressed("carry"):
			charging = true
			_charge_time = 0.0
		if charging:
			_charge_time += delta
			charge_ratio = clampf(_charge_time / max_charge_time, 0.0, 1.0)
			if not Input.is_action_pressed("carry"):
				handoff = true
				change_state(fsm.states.throw)
				return

	var input: Vector2 = Input.get_vector("left", "right", "up", "down")
	if move_by_input(CARRY_SPEED_SCALE):
		facing = Vector3(input.x, 0.0, input.y).normalized()


func _exit() -> void:
	if carried != null and not handoff:
		carried.reparent(obj.get_parent(), true)
		var thrown = carried.fsm.states.thrown
		thrown.launch_velocity = Vector3.ZERO
		thrown.deals_damage = false
		carried.fsm.change_state(thrown)
		carried = null


func _find_target() -> Node3D:
	var grab_area: Area3D = obj.get_node("Direction/GrabArea3D")
	var nearest: Node3D = null
	var best := INF
	for body in grab_area.get_overlapping_bodies():
		if body.is_in_group("grabbable"):
			var d: float = obj.global_position.distance_squared_to(body.global_position)
			if d < best:
				best = d
				nearest = body
	return nearest
