class_name PlayerSkillState
extends PlayerState
@export var skill_scene: PackedScene  
@export var cast_time := 0.3           
@export var spawn_height := 0.8
@export var spawn_forward := 0.5

var active: Node3D = null  
var _time := 0.0


func can_throw() -> bool:
	return skill_scene != null and not is_instance_valid(active)


func _enter() -> void:
	_time = 0.0
	obj.stop_horizontal()
	if not can_throw():
		return  

	var input: Vector2 = Input.get_vector("left", "right", "up", "down")
	var dir := Vector3(input.x, 0.0, input.y)
	if dir.length() <= 0.1:
		dir = obj.get_node("Direction").global_transform.basis.z   # +Z là hướng trước (MODEL_FRONT)
		dir.y = 0.0
	dir = dir.normalized()

	active = skill_scene.instantiate()
	obj.get_parent().add_child(active)
	active.global_position = obj.global_position + Vector3.UP * spawn_height + dir * spawn_forward
	active.setup(obj, dir)
	obj.suppress_blade(true) 


func _update(delta: float) -> void:
	_time += delta
	if _time >= cast_time or active == null:
		change_state(fsm.states.idle)
		obj.suppress_blade(false)
func _finish() -> void:
	if is_instance_valid(obj) and obj.has_method("suppress_blade"):
		obj.suppress_blade(false)
	queue_free()
