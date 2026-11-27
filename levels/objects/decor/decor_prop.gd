@tool
class_name DecorProp
extends Node3D

## Một món trang trí của tầng hầm: dựng mô hình `model` và (nếu cần) một hộp va chạm.
## Hình và va chạm được dựng bằng code, không lưu vào .tscn, nên đổi `model` hay kích thước ngay
## trong Inspector là thấy liền. Muốn dời/xoay món đồ thì kéo node này.

## Mô hình (.gltf/.tscn) của món đồ. Gốc mô hình nằm ở chân đồ vật.
@export var model: PackedScene:
	set(value):
		model = value
		if is_inside_tree():
			_rebuild()
## Kích thước hộp va chạm (mét). Để 0 là không có va chạm (đồ treo tường).
@export var collision_size := Vector3.ZERO:
	set(value):
		collision_size = value
		if is_inside_tree():
			_rebuild()
## Dời hộp va chạm khỏi chân mô hình (ví dụ kệ dài lệch tâm).
@export var collision_offset := Vector3.ZERO:
	set(value):
		collision_offset = value
		if is_inside_tree():
			_rebuild()
## Có chặn đường đi của quái không (nhóm path_blockers: ô chứa node này bị coi là bị chặn).
@export var blocks_path := true

var _built: Node3D


func _ready() -> void:
	_rebuild()
	if blocks_path and collision_size != Vector3.ZERO and not Engine.is_editor_hint():
		add_to_group(&"path_blockers")


func _rebuild() -> void:
	if _built != null:
		_built.queue_free()
		_built = null
	# Không gán owner: node dựng bằng code không bị lưu vào file .tscn.
	_built = Node3D.new()
	_built.name = "_Built"
	add_child(_built, false, Node.INTERNAL_MODE_BACK)
	if model != null:
		_built.add_child(model.instantiate())
	if collision_size != Vector3.ZERO:
		var body := StaticBody3D.new()
		body.collision_layer = 1
		body.collision_mask = 0
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = collision_size
		shape.shape = box
		shape.position = collision_offset + Vector3(0, collision_size.y / 2.0, 0)
		body.add_child(shape)
		_built.add_child(body)
