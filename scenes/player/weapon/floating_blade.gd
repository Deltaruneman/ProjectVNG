extends Node3D

const FLOAT_HEIGHT := 0.06
const FLOAT_FREQUENCY := 0.9
const SWAY_ANGLE := 0.0418879 # 2.4 degrees
const SWAY_FREQUENCY := 0.62
const TILT_ANGLE := 0.0139626 # 0.8 degrees

var _rest_position := Vector3.ZERO
var _rest_rotation := Vector3.ZERO
var _elapsed := 0.0
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
	position = _rest_position


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


func _process(delta: float) -> void:
	_elapsed += delta
	if _has_attack_pose:
		position = _attack_position
		rotation = _attack_rotation
		return
	var bob := sin(_elapsed * TAU * FLOAT_FREQUENCY) * FLOAT_HEIGHT
	var sway := sin(_elapsed * TAU * SWAY_FREQUENCY) * SWAY_ANGLE
	var tilt := sin(_elapsed * TAU * SWAY_FREQUENCY * 0.73 + 1.1) * TILT_ANGLE
	position = (_temporary_position if _has_temporary_position else _rest_position) + Vector3.UP * bob
	rotation = _rest_rotation + Vector3(tilt, 0.0, sway)