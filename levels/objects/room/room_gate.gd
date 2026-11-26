@tool
class_name RoomGate
extends Node3D

## Rào đỏ phát sáng có dấu X, chặn một lối ra/vào của phòng (giống Cult of the Lamb).
## BasementRoom gọi close()/open(). Hình và va chạm được dựng bằng code theo `width`, nên kéo
## node này tới cửa phòng, xoay cho thanh ngang nằm dọc theo bức tường là xong.

## Bề rộng lối đi (mét). Một ô GridMap = 2 m, lối 3 ô = 6 m.
@export var width := 6.0:
	set(value):
		width = maxf(value, 1.0)
		if is_inside_tree():
			_rebuild()
@export var height := 3.0:
	set(value):
		height = maxf(value, 0.5)
		if is_inside_tree():
			_rebuild()
## Trạng thái khi mới vào scene, trước khi BasementRoom quyết định.
@export var start_open := false:
	set(value):
		start_open = value
		if Engine.is_editor_hint() and is_inside_tree():
			_apply(start_open, false)

const COLOR := Color(1.0, 0.12, 0.16)

var is_open := false
var _built: Node3D
var _visual: Node3D
var _body: StaticBody3D
var _shape: CollisionShape3D
var _light: OmniLight3D
var _mark: Label3D
var _tween: Tween


func _ready() -> void:
	_rebuild()
	_apply(start_open, false)


func open(animated := true) -> void:
	_apply(true, animated)


func close(animated := true) -> void:
	_apply(false, animated)


func _apply(want_open: bool, animated: bool) -> void:
	is_open = want_open
	if _built == null:
		return
	if is_instance_valid(_tween):
		_tween.kill()
	_shape.set_deferred("disabled", want_open)
	if want_open:
		remove_from_group(&"path_blockers")
	else:
		add_to_group(&"path_blockers")
	var target_scale := Vector3(1, 0.001, 1) if want_open else Vector3.ONE
	var target_energy := 0.0 if want_open else 1.6
	if not animated:
		_visual.scale = target_scale
		_visual.visible = not want_open
		_light.light_energy = target_energy
		_mark.visible = not want_open
		return
	_visual.visible = true
	_mark.visible = not want_open
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_visual, "scale", target_scale, 0.35).set_trans(Tween.TRANS_QUAD)
	_tween.tween_property(_light, "light_energy", target_energy, 0.35)
	if want_open:
		_tween.chain().tween_callback(func() -> void: _visual.visible = false)


func _rebuild() -> void:
	if _built != null:
		_built.queue_free()
	# Không gán owner: các node dựng bằng code không bị lưu vào file .tscn.
	_built = Node3D.new()
	_built.name = "_Built"
	add_child(_built, false, Node.INTERNAL_MODE_BACK)

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = COLOR
	mat.emission_enabled = true
	mat.emission = COLOR
	mat.emission_energy_multiplier = 2.5

	_visual = Node3D.new()
	_built.add_child(_visual)
	# Ba thanh ngang + hai cột hai đầu.
	for y in [0.45, 1.05, 1.65]:
		_visual.add_child(_box(Vector3(width, 0.09, 0.09), Vector3(0, y, 0), mat))
	for x in [-width / 2.0, width / 2.0]:
		_visual.add_child(_box(Vector3(0.18, 2.0, 0.18), Vector3(x, 1.0, 0), mat))

	_mark = Label3D.new()
	_mark.text = "X"
	_mark.font_size = 140
	_mark.outline_size = 24
	_mark.modulate = COLOR
	_mark.outline_modulate = Color(0.2, 0, 0, 1)
	_mark.pixel_size = 0.006
	_mark.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_mark.no_depth_test = true
	_mark.position = Vector3(0, 2.6, 0)
	_built.add_child(_mark)

	_light = OmniLight3D.new()
	_light.light_color = COLOR
	_light.omni_range = 4.5
	_light.position = Vector3(0, 1.2, 0.6)
	_built.add_child(_light)

	_body = StaticBody3D.new()
	_body.collision_layer = 1
	_body.collision_mask = 0
	_shape = CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(width, height, 0.6)
	_shape.shape = box
	_shape.position = Vector3(0, height / 2.0, 0)
	_body.add_child(_shape)
	_built.add_child(_body)


func _box(size: Vector3, pos: Vector3, mat: Material) -> MeshInstance3D:
	var mesh := BoxMesh.new()
	mesh.size = size
	mesh.material = mat
	var node := MeshInstance3D.new()
	node.mesh = mesh
	node.position = pos
	node.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	return node
