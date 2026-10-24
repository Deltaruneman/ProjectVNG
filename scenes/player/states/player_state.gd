class_name PlayerState
extends FSMState

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _update(delta: float) -> void:
	pass

func move_by_input(speed_scale: float = 1.0) -> bool:
	var input: Vector2 = Input.get_vector("left", "right", "up", "down")
	if input.length() <= 0.1:
		obj.stop_horizontal()
		return false
	obj.change_direction(BaseCharacter.direction_from_input(input))
	obj.velocity.x = obj.movement_speed * speed_scale * input.x
	obj.velocity.z = obj.movement_speed * speed_scale * input.y
	return true

#Control moving and changing state to run
#Return true if moving
func control_moving() -> bool:
	var is_moving := move_by_input()
	if is_moving and obj.is_on_floor():
		change_state(fsm.states.run)
	return is_moving

#Control jumping
#Return true if jumping
func control_jump() -> bool:
	#If jump is pressed change to jump state and return true
	if Input.is_action_just_pressed("jump"):
		print(obj.curjump)
		if obj.curjump <obj.maxjump:
			obj.jump()
			change_state(fsm.states.jump)
			return true
	return false

#Control attack
#Return true if attacking
func control_attack() -> bool:
	if Input.is_action_just_pressed("attack"):
		change_state(fsm.states.attack)
		return true
	return false

#Control dash (Shift)
#Return true if dashing
func control_dash() -> bool:
	if Input.is_action_just_pressed("dash") and obj.dash_cooldown_timer <= 0.0:
		change_state(fsm.states.dash)
		return true
	return false

func take_damage(damage: int = 1) -> void:
	if obj.invincible:
		return
	# Đang trong khung parry -> gạt đòn, không mất máu
	if obj.parrying and fsm.states.has("parry") and fsm.states.parry.try_parry():
		return
	obj.take_damage(damage)
	if obj.health <= 0 :
		change_state(fsm.states.dead)
	else:
		change_state(fsm.states.hurt)

#Control parry
#Return true if parrying
func control_parry() -> bool:
	if Input.is_action_just_pressed("parry") and obj.parry_cooldown_timer <= 0.0 and obj.is_on_floor():
		change_state(fsm.states.parry)
		return true
	return false

func control_carry() -> bool:
	if Input.is_action_just_pressed("carry"):
		print("mang")
		change_state(fsm.states.carry)
		return true
	return false
func control_skill() -> bool:
	if Input.is_action_just_pressed("skill"):
		if fsm.states.skill.can_throw():
			change_state(fsm.states.skill)
			return true
	return false
