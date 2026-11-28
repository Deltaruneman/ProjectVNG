extends PlayerState

var coyote_timer: float = 0.0

func _enter() -> void:
	obj.change_animation("fall")
	coyote_timer = 0.1 

func _update(delta: float) -> void:
	if coyote_timer > 0.0:
		coyote_timer -= delta
	var is_moving: bool = control_moving()
	if control_dash():
		return
	if obj.is_on_floor():
		obj.curjump = 0 
		if not is_moving:
			change_state(fsm.states.idle)
	else:
		control_jump()
func control_jump() -> bool:
	if Input.is_action_just_pressed("jump"):
		if coyote_timer > 0.0 and obj.can_start_ground_jump():
			obj.jump() 
			change_state(fsm.states.jump)
			return true
	return false
