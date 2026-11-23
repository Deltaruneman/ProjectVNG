class_name WindUltimateState
extends PlayerState


func _enter() -> void:
	var player := obj as Player
	if player == null:
		change_state(fsm.states.idle)
		return
	player._enter_wind_ultimate_state()


func _update(delta: float) -> void:
	var player := obj as Player
	if player != null:
		player._update_wind_ultimate(delta)


func _exit() -> void:
	var player := obj as Player
	if player != null:
		player._finish_wind_ultimate()
