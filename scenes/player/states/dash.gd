class_name DashState
extends PlayerState

const BattleFX := preload("res://scenes/player/battle_vfx.gd")
const TRAIL_INTERVAL := 0.032

var _timer: float = 0.0
var _dash_dir: Vector3 = Vector3.ZERO
var _trail_timer: float = 0.0

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
	_trail_timer = 0.0
	BattleFX.dash_trail_start(obj, _dash_dir)

func _update(delta: float) -> void:
	_timer -= delta
	_trail_timer += delta
	obj.velocity.x = _dash_dir.x * obj.dash_speed
	obj.velocity.z = _dash_dir.z * obj.dash_speed
	obj.velocity.y = 0.0 
	if _trail_timer >= TRAIL_INTERVAL:
		_trail_timer = 0.0
		BattleFX.dash_trail_afterimage(obj, _dash_dir)

	if _timer <= 0.0:
		obj.stop_horizontal()
		if obj.is_on_floor():
			change_state(fsm.states.idle)
		else:
			change_state(fsm.states.jump)

func _exit() -> void:
	obj.invincible = false
	obj.stop_horizontal()
	BattleFX.dash_trail_afterimage(obj, _dash_dir)
