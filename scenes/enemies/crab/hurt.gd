extends EnemyState


# Called when the node enters the scene tree for the first time.
func _enter() -> void:
	obj.change_animation("hurt")
	timer = 0.2
func _exit() -> void:
	obj.stop_horizontal()
func _update(delta: float) -> void:
	if update_timer(delta):
		if obj.health <= 0:
			change_state(fsm.states.dead)
		else:
			change_state(fsm.default_state)
func take_damage (damage_dir: Vector3, damage: float)-> void:
	pass
