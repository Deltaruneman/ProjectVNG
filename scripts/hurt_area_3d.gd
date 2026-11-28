extends Area3D
class_name HurtArea3D

## Receives damage and exposes its live source only during synchronous hurt delivery.
signal hurt(direction: Vector3, damage: float)

var _attacker: Variant = null
var attacker: Node3D:
	get:
		return _live_source(_attacker)
	set(value):
		_attacker = _live_source(value)


func _live_source(source: Variant) -> Node3D:
	if typeof(source) != TYPE_OBJECT or not is_instance_valid(source):
		return null
	if not source is Node3D or source.is_queued_for_deletion():
		return null
	return source


func take_damage(direction: Vector3, damage: float, source: Variant = null) -> void:
	# A Node3D parameter would reject freed sources before a validity guard can run.
	var previous_attacker: Variant = _attacker
	_attacker = _live_source(source)
	hurt.emit(direction, damage)
	# Listeners may destroy either source or the receiver, including in nested hits.
	if is_instance_valid(self):
		_attacker = _live_source(previous_attacker)
