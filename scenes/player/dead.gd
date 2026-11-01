extends PlayerState


func _enter() -> void:
	obj.change_animation("dead")
	obj.stop_move()
	obj.movement_enabled = false
	timer = 2.0
	var death_animation := "dead_%s" % obj.direction
	if obj.anim_player.has_animation(death_animation):
		timer = maxf(timer, obj.anim_player.get_animation(death_animation).length)


func _update(delta: float) -> void:
	if update_timer(delta):
		if obj.get_tree().current_scene is Stage:
			obj.died.emit()
		else:
			obj.get_tree().reload_current_scene()
func take_damage(_damage: int = 1) -> void:
	pass
