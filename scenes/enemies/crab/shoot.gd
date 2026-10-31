extends EnemyState

@export var shoot_delay: float = 0.3

var _fire_timer: float = 0.0
var _has_fired: bool = false

func _enter() -> void:
	obj.change_animation("shoot")
	obj.stop_move()
	_has_fired = false
	_fire_timer = shoot_delay
	# Length taken from the animation itself - see the same kind of note
	# in the fox's Attack state.
	timer = obj.anim_player.get_animation("shoot_%s" %
		obj.direction).length

func _update(delta: float) -> void:
	if not _has_fired:
		_fire_timer -= delta
		if _fire_timer <= 0.0:
			obj.fire()
			_has_fired = true
	if update_timer(delta):
		change_state(fsm.states.idle)
