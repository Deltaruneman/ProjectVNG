extends EnemyState
class_name MushroomThrownState
@export var gravity := 20.0
@export var min_air_time := 0.1
@export var hit_damage := 1.0

var launch_velocity := Vector3.ZERO  
var deals_damage := true            
var thrower: Node = null            

var _time := 0.0
var _already_hit: Array = []       


func _enter() -> void:
	_time = 0.0
	_already_hit.clear()
	if obj.has_meta("orig_layer"):
		obj.collision_layer = obj.get_meta("orig_layer")
		obj.collision_mask = obj.get_meta("orig_mask")
	print("[Thrown enter] layer/mask: ", obj.collision_layer, " / ", obj.collision_mask)
	obj.velocity = launch_velocity

func _update(delta: float) -> void:
	_time += delta
	obj.velocity.y -= gravity * delta
	obj.move_and_slide()  

	if deals_damage:
		for i in obj.get_slide_collision_count():
			var other := obj.get_slide_collision(i).get_collider()
			if other == null or other == obj or other == thrower or _already_hit.has(other):
				continue
			_already_hit.append(other)
			_hit(other)

	if obj.is_on_floor() and _time > min_air_time:
		obj.velocity = Vector3.ZERO
		deals_damage = true
		thrower = null
		change_state(fsm.states.run)


func _hit(other: Object) -> void:
	var dir := Vector3(obj.velocity.x, 0.0, obj.velocity.z).normalized()
	var other_fsm = other.get("fsm")
	if other_fsm != null:
		var st = other_fsm.current_state
		if st is EnemyState:
			st.take_damage(dir, hit_damage)  
			return
		if st is PlayerState:
			return                        
	if other.has_method("take_damage"):
		other.take_damage(int(hit_damage))

func take_damage(_damage_dir: Vector3, _damage: float) -> void:
	pass
