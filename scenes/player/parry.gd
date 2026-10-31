extends PlayerState


enum Phase { WINDOW, RECOVERY, SUCCESS }

const RECOVERY_TIME := 0.2  
const SUCCESS_TIME := 0.35  

var _phase: Phase = Phase.WINDOW
var _set_invincible: bool = false

func _enter() -> void:
	_phase = Phase.WINDOW
	_set_invincible = false
	obj.parrying = true
	obj.stop_horizontal()
	obj.change_animation("parry")
	timer = obj.parry_window

func _exit() -> void:
	obj.parrying = false
	if _set_invincible:
		obj.invincible = false
	obj.parry_cooldown_timer = obj.parry_cooldown

func _update(delta: float) -> void:
	match _phase:
		Phase.WINDOW:
			if update_timer(delta):
				obj.parrying = false
				_phase = Phase.RECOVERY
				timer = RECOVERY_TIME
		Phase.RECOVERY:
			if update_timer(delta):
				change_state(fsm.states.idle)
		Phase.SUCCESS:
			if control_attack():
				return
			if update_timer(delta):
				change_state(fsm.states.idle)
func try_parry() -> bool:
	if _phase != Phase.WINDOW:
		return false
	_phase = Phase.SUCCESS
	obj.parrying = false
	obj.invincible = true
	_set_invincible = true
	timer = SUCCESS_TIME
	return true
