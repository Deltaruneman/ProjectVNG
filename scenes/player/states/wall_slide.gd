extends PlayerState
## Compatibility fallback for old scene references; wall movement has been removed.
func _enter() -> void:
	change_state(fsm.states.fall)
