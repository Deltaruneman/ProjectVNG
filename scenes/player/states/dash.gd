class_name DashState
extends PlayerState

var _timer: float = 0.0
var _dash_dir: Vector3 = Vector3.ZERO

func _enter() -> void:
	_timer = obj.dash_duration
	obj.invincible = true
	obj.dash_cooldown_timer = obj.dash_cooldown

	var input: Vector2 = Input.get_vector("left", "right", "up", "down")
	if input.length() > 0.1:
		_dash_dir = Vector3(input.x, 0.0, input.y).normalized()
		obj.change_direction(BaseCharacter.direction_from_input(input))
	else:
		_dash_dir = obj.forward()

	if obj.anim_player != null and obj.anim_player.has_animation("dash_%s" % obj.direction):
		obj.change_animation("dash")
	else:
		obj.change_animation("run")

func _update(delta: float) -> void:
	_timer -= delta
	obj.velocity.x = _dash_dir.x * obj.dash_speed
	obj.velocity.z = _dash_dir.z * obj.dash_speed
	obj.velocity.y = 0.0 

	if _timer <= 0.0:
		obj.stop_horizontal()
		if obj.is_on_floor():
			change_state(fsm.states.idle)
		else:
			change_state(fsm.states.jump)

func _exit() -> void:
	obj.invincible = false
	obj.stop_horizontal()
