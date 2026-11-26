extends Node3D
## Held equipment. The historical filename is retained to preserve resource UIDs.
## Combat owns attack trajectories; idle/run keep the grip at the visible hand.
var _rest_position := Vector3.ZERO
var _rest_rotation := Vector3.ZERO
var _temporary_position := Vector3.ZERO
var _has_temporary_position := false
var _attack_position := Vector3.ZERO
var _attack_rotation := Vector3.ZERO
var _has_attack_pose := false

func set_temporary_position(local_position: Vector3) -> void:
	_temporary_position = local_position
	_has_temporary_position = true
	position = local_position

func clear_temporary_position() -> void:
	_has_temporary_position = false
	update_held_pose()

func set_attack_pose(local_position: Vector3, local_rotation: Vector3) -> void:
	_attack_position = local_position
	_attack_rotation = local_rotation
	_has_attack_pose = true

func clear_attack_pose() -> void:
	_has_attack_pose = false

func get_attack_rest_rotation() -> Vector3:
	return _rest_rotation

func _ready() -> void:
	_rest_position = position
	_rest_rotation = rotation
	process_priority = 90
	update_held_pose()

func _process(_delta: float) -> void:
	$Sprite3D.position = Vector3.ZERO
	if _has_attack_pose:
		position = _attack_position
		rotation = _attack_rotation
	elif _has_temporary_position:
		position = _temporary_position
	else:
		update_held_pose()

func update_held_pose() -> void:
	if not is_inside_tree() or get_viewport() == null:
		return
	var camera := get_viewport().get_camera_3d()
	var player := get_parent().get_parent()
	if camera == null or not player.has_method("_view_direction"):
		position = _rest_position
		return
	var facing: String = player._view_direction()
	var sprite := $Sprite3D as Sprite3D
	if facing == "left":
		sprite.flip_h = true
	elif facing == "right":
		sprite.flip_h = false
	var body := player.get_node("Sprite3D") as Sprite3D
	# Hand pixels in the existing 64px Foxy frames (right/left hand by facing).
	# Use the billboard plane so the grip remains attached at the elevated angle.
	var hand_x := -7.0 if facing in ["down", "left"] else 7.0
	var hand_y := body.texture.get_height() / float(body.vframes) * 0.5 + body.offset.y - 45.0
	global_position = body.global_position + (camera.global_basis.x * hand_x + camera.global_basis.y * hand_y) * body.pixel_size
	var tip := Vector2(signf(hand_x) * 0.45, 1.0)
	if sprite.texture != null:
		var size := sprite.texture.get_size()
		var definition: Dictionary = GameManager.inventory.definition_for_slot("main")
		var legacy: bool = definition.get("legacy", false)
		var source_tip := PI / 2.0 if legacy else 3.0 * PI / 4.0
		if sprite.flip_h:
			source_tip = PI - source_tip
		global_basis = camera.global_basis * Basis(Vector3.BACK, tip.angle() - source_tip)
		sprite.offset = Vector2(0.0, size.y * 0.3) if legacy else Vector2(-size.x * 0.25, size.y * 0.25)
		if sprite.flip_h:
			sprite.offset.x = -sprite.offset.x
	player.place_weapon_below_body(sprite)
