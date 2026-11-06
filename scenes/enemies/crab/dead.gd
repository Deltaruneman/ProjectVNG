extends EnemyState


func _enter() -> void:
	obj.change_animation("dead")
	obj.stop_move()
	_disable("CollisionShape3D")
	_disable("Direction/HitArea3d/CollionShape3D")
	_disable("Direction/HurtArea3d/CollionShape3D")
	timer =1.0
func _update(delta: float ) -> void:
	if update_timer(delta):
		obj.queue_free()
func take_damage (damamge_dir: Vector3, damage: float)-> void:
	pass
func _disable(path:String) -> void:
	if obj.has_node(path):
		obj.get_node(path).set_deferred("disable",true)
