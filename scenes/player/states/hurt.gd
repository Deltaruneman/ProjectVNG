extends PlayerState

func _enter() -> void:
	#Switch the animation to "hurt"
	#Turn on obj.is_invulnerable so one hit doesn't drain health every frame in a row
	#Push the character back in the XZ plane and hop it up slightly along the Y axis
	#Set the timer to 0.5 seconds
	pass


func _exit() -> void:
	#Turn off obj.is_invulnerable
	pass


func _update(_delta: float) -> void:
	#When the timer runs out, return to Idle. Meanwhile do NOT call control_moving()/control_jump()
	#— can't be controlled while stunned
	pass
