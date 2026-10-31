extends Area3D
class_name HurtArea3D

## The area that RECEIVES damage. It doesn't handle anything itself — it just reports up to the
## character that owns it, since how much health is lost and which state to switch to is the
## character's own business.

signal hurt(direction: Vector3, damage: float)

var attacker: Node3D = null

func take_damage(direction: Vector3, damage: float, source: Node3D = null) -> void:
	var previous_attacker := attacker
	attacker = source
	hurt.emit(direction, damage)
	attacker = previous_attacker
