extends Node3D
var start: Vector3
var finish: Vector3
var visual: AnimatedSprite3D
var _age := 0.0

func _ready() -> void:
	process_priority = 200

func _process(delta: float) -> void:
	_age += delta
	if _age >= 0.4:
		queue_free()
		return
	if visual == null:
		return
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var x := (finish - start).normalized()
	var z := (camera.global_position - (start + finish) * 0.5).slide(x).normalized()
	if z.length_squared() < 0.001:
		z = camera.global_basis.y.slide(x).normalized()
	global_transform = Transform3D(Basis(x, z.cross(x).normalized(), z), start)
	visual.modulate.a = minf(1.0, (0.4 - _age) / 0.12)
