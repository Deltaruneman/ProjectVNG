extends PlayerState

func _update(delta: float) -> void:
	if obj.is_on_floor():
		change_state(fsm.states.idle)
		return
	if not obj.is_on_wall():
		change_state(fsm.states.fall)
		return
	if obj.velocity.y < -0.8:
		obj.velocity.y = -0.8
	control_moving()
	control_jump()
func control_jump() -> bool:
	if Input.is_action_just_pressed("jump"):
		var wall_normal: Vector3 = obj.get_wall_normal()
		if wall_normal == Vector3.ZERO:
			if obj.direction == "left": wall_normal = Vector3(1, 0, 0)
			elif obj.direction == "right": wall_normal = Vector3(-1, 0, 0)
			elif obj.direction == "up": wall_normal = Vector3(0, 0, 1)
			elif obj.direction == "down": wall_normal = Vector3(0, 0, -1)
		obj.velocity.y = obj.jump_speed
		var push_force: float = obj.movement_speed 
		obj.velocity.x = wall_normal.x * push_force
		obj.velocity.z = wall_normal.z * push_force
		obj.input_lock_timer = 0.3
		obj.curjump = 1 
		change_state(fsm.states.jump)
		return true
	return false
