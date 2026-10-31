extends EnemyState
class_name MushroomCarriedState
const LIFT_TIME := 0.2  

var _time := 0.0
var _start_pos := Vector3.ZERO


func _enter() -> void:
	if not obj.has_meta("orig_layer"):
		obj.set_meta("orig_layer", obj.collision_layer)
		obj.set_meta("orig_mask", obj.collision_mask)
	obj.collision_layer = 0
	obj.collision_mask = 0
	obj.velocity = Vector3.ZERO
	_start_pos = obj.position
	_time = 0.0

func _update(delta: float) -> void:
	obj.velocity = Vector3.ZERO
	_time += delta
	var t := clampf(_time / LIFT_TIME, 0.0, 1.0)
	t = t * (2.0 - t)   # ease-out
	obj.position = _start_pos.lerp(Vector3.ZERO, t)
	obj.rotation = Vector3.ZERO


func _exit() -> void:
	if obj.has_meta("orig_layer"):
		obj.collision_layer = obj.get_meta("orig_layer")
		obj.collision_mask = obj.get_meta("orig_mask")

func take_damage(_damage_dir: Vector3, _damage: float) -> void:
	pass
