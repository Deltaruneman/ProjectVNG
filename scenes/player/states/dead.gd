extends PlayerState

func _enter() -> void:
	#Switch the animation to "dead"
	#Stop moving completely
	#Set the timer to 2 seconds
	pass


func _update(_delta: float) -> void:
	#When the timer runs out, reload the level
	pass


#Already dead, so no more damage
func take_damage(_damage: int = 1) -> void:
	pass
