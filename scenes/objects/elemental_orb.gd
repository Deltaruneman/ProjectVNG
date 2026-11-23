extends "res://scenes/objects/skill.gd"
## A single outbound flight; wind alone continues to use the original Skill script.
const BattleFX := preload("res://scenes/player/battle_vfx.gd")

var elemental_form := ""
var _visual: AnimatedSprite3D
var _distance_travelled := 0.0


func setup(thrower_node: Node3D, dir: Vector3) -> void:
	thrower = thrower_node
	direction = dir.normalized()
	_start = global_position
	_visual = BattleFX.elemental_orb(self, elemental_form, direction)
	process_priority = 200
	_update_visual_transform()
	if _hit_area is HitArea3D:
		(_hit_area as HitArea3D).attacker = thrower


func _physics_process(delta: float) -> void:
	if not is_instance_valid(thrower):
		_finish()
		return
	var step := minf(speed * delta, maxf(max_distance - _distance_travelled, 0.0))
	var next_position := global_position + direction * step
	if _blocked(global_position, next_position):
		BattleFX.impact(self, global_position, elemental_form, direction)
		_finish()
		return
	global_position = next_position
	_distance_travelled += step
	_update_visual_transform()
	if _distance_travelled >= max_distance:
		_finish()


func _finish() -> void:
	# No blade suppression or catch: this projectile is magic, not the equipped weapon.
	queue_free()


func _process(_delta: float) -> void:
	_update_visual_transform()


func _update_visual_transform() -> void:
	if not is_instance_valid(_visual):
		return
	var camera := get_viewport().get_camera_3d()
	_visual.visible = camera != null
	if camera == null:
		return
	_visual.global_position = global_position
	var start := camera.unproject_position(global_position)
	var screen_direction := camera.unproject_position(global_position + direction) - start
	var angle := -screen_direction.angle() if screen_direction.length_squared() > 0.001 else 0.0
	_visual.global_basis = camera.global_basis * Basis(Vector3.BACK, angle)
