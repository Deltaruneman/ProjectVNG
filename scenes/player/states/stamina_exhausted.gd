extends PlayerState

var _remaining := 0.0


func _enter() -> void:
	_remaining = Player.STAMINA_EXHAUSTION_DURATION
	obj.stamina_exhausted = true
	obj._cancel_skill_aim()
	obj.stop_horizontal()
	obj.change_animation("hurt")


func _exit() -> void:
	obj.stamina_exhausted = false
	obj.stop_horizontal()


func _update(delta: float) -> void:
	obj.stop_horizontal()
	_remaining -= delta
	if _remaining <= 0.0:
		change_state(fsm.states.idle if obj.is_on_floor() else fsm.states.fall)
