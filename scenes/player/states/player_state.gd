class_name PlayerState
extends FSMState

const PLAYER_HIT_FX := preload("res://scenes/player/battle_vfx.gd")

func _enter() -> void:
	pass

func _exit() -> void:
	pass

func _update(delta: float) -> void:
	pass

func move_by_input(speed_scale: float = 1.0) -> bool:
	var input: Vector3 = obj.get_camera_movement_input()
	if input.length() <= 0.1:
		obj.stop_horizontal()
		return false
	obj.face_movement(input)
	obj.velocity.x = obj.movement_speed * speed_scale * input.x
	obj.velocity.z = obj.movement_speed * speed_scale * input.z
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
	var player := obj as Player
	if Input.is_action_just_pressed("attack") and player != null and player.attack_input_cooldown <= 0.0 and GameManager.inventory.id_for_slot("main") != "":
		change_state(fsm.states.attack)
		return true
	return false

#Control dash (Shift)
#Return true if dashing
func control_dash() -> bool:
	if Input.is_action_just_pressed("dash") and obj.dash_cooldown_timer <= 0.0:
		if not obj.try_spend_stamina(Player.STAMINA_DASH_COST):
			return obj.stamina_exhausted
		obj._cancel_skill_aim()
		change_state(fsm.states.dash)
		return true
	return false

func take_damage(damage: int = 1) -> void:
	if obj.invincible:
		return
	# Đang trong khung parry -> gạt đòn, không mất máu
	if obj.parrying and fsm.states.has("parry") and fsm.states.parry.try_parry():
		return
	if damage > 0:
		PLAYER_HIT_FX.play_skill_sound(obj, "player_hit")
	var hp_damage: int = obj.absorb_potion_damage(damage)
	if damage > 0 and hp_damage == 0:
		return
	obj.take_damage(hp_damage)
	if obj.health <= 0 :
		change_state(fsm.states.dead)
	else:
		change_state(fsm.states.hurt)

#Control parry
#Return true if parrying
func control_parry() -> bool:
	if Input.is_action_just_pressed("parry") and obj.parry_cooldown_timer <= 0.0 and obj.is_on_floor():
		if not obj.try_spend_stamina(Player.STAMINA_PARRY_COST):
			return obj.stamina_exhausted
		change_state(fsm.states.parry)
		return true
	return false

func control_carry() -> bool:
	if Input.is_action_just_pressed("carry"):
		print("mang")
		change_state(fsm.states.carry)
		return true
	return false
