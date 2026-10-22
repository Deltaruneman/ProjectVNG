extends PlayerState

func _enter() -> void:
	obj.change_animation("attack")
	obj.stop_horizontal()
	timer = obj.anim_player.get_animation("attack_%s"%obj.direction).length
	_hit_shape().disabled = false
	
	pass


func _exit() -> void:
	_hit_shape().disabled = true
	#Disable the CollisionShape3D of Direction/HitArea3D
	pass


func _update(_delta: float) -> void:
	if update_timer(_delta):
		change_state(fsm.previous_state)
	#When the timer runs out, return to the previous state (fsm.previous_state)
	pass
func _hit_shape() -> CollisionShape3D:
	return obj.get_node("Direction/HitArea3D/CollisionShape3D")
