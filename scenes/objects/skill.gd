class_name Skill
extends Node3D
# scenes/player/skill/skill.gd
# Cấu trúc: Phidao (Node3D, gắn script này) > Sprite3D, HitArea3D > CollisionShape3D
# Sát thương do HitArea3D lo (giống các đòn đánh khác của game). Script này chỉ lo bay.

@export var speed := 14.0           
@export var return_speed := 18.0    
@export var max_distance := 7.0     
@export var catch_distance := 0.8   
@export var catch_height := 0.8    
@export var spin_speed := 20.0      
## Layer được coi là tường. Để 0 = dùng luôn collision_mask của player (giống wall slide).
@export_flags_3d_physics var wall_mask := 0
## Khoảng cách đón đầu: skill quay lại ngay trước khi chạm tường, không cắm vào tường.
@export var wall_check_margin := 0.3

var thrower: Node3D = null
var direction := Vector3.FORWARD

var _start := Vector3.ZERO
var _returning := false

@onready var _sprite: Node3D = get_node_or_null("Sprite3D")
@onready var _hit_area: Area3D = get_node_or_null("HitArea3D")


func setup(thrower_node: Node3D, dir: Vector3) -> void:
	thrower = thrower_node
	direction = dir.normalized()
	_start = global_position
	# Ném đi -> ẩn blade trên người player
	if thrower != null and thrower.has_method("suppress_blade"):
		thrower.suppress_blade(true)


func _physics_process(delta: float) -> void:
	if _sprite != null:
		_sprite.rotation.z += spin_speed * delta

	if not _returning:
		var from := global_position
		var to := from + direction * speed * delta
		if _blocked(from, to):
			_start_return()
			return
		global_position = to
		if global_position.distance_to(_start) >= max_distance:
			_start_return()
		return

	if not is_instance_valid(thrower):
		queue_free()
		return
	var target := thrower.global_position + Vector3.UP * catch_height
	var to_target := target - global_position
	if to_target.length() <= catch_distance:
		_finish()
		return
	global_position += to_target.normalized() * return_speed * delta


## Skill đã quay về tay player: hiện lại blade rồi tự hủy.
func _finish() -> void:
	if is_instance_valid(thrower) and thrower.has_method("suppress_blade"):
		thrower.suppress_blade(false)
	queue_free()


func _start_return() -> void:
	_returning = true
	_reset_hit()

func _reset_hit() -> void:
	if _hit_area == null:
		return
	_hit_area.set_deferred("monitoring", false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	if is_instance_valid(_hit_area):
		_hit_area.monitoring = true


func _blocked(from: Vector3, to: Vector3) -> bool:
	var mask := _get_wall_mask()
	if mask == 0:
		return false
	var query := PhysicsRayQueryParameters3D.create(from, to + direction * wall_check_margin, mask)
	if thrower is CollisionObject3D:
		query.exclude = [(thrower as CollisionObject3D).get_rid()] # không tự va vào player
	return not get_world_3d().direct_space_state.intersect_ray(query).is_empty()


func _get_wall_mask() -> int:
	if wall_mask != 0:
		return wall_mask
	if thrower is CollisionObject3D:
		return (thrower as CollisionObject3D).collision_mask
	return 0
