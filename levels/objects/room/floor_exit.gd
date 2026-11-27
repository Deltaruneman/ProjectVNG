extends Area3D

## Cuối hành lang tối: người chơi bước vào là chuyển sang tầng/scene khác.
## Nếu đặt `id`, node này còn là điểm xuất hiện (có con Marker3D tên Spawn) khi quay về từ scene
## khác, ví dụ cửa Garden dẫn ngược về tầng hầm.

@export var id := ""
@export_file("*.tscn") var target_stage := ""
@export var target_spawn := ""

var _armed := false


func _ready() -> void:
	if id != "":
		add_to_group("spawn_points")
	body_entered.connect(_on_body_entered)
	# Người chơi vừa xuất hiện ngay trong vùng này (quay về từ Garden) thì không bị đẩy đi lại.
	await get_tree().physics_frame
	await get_tree().physics_frame
	_armed = true


func _on_body_entered(body: Node3D) -> void:
	if not _armed or not body is Player or target_stage.is_empty():
		return
	GameManager.change_stage(target_stage, target_spawn)
