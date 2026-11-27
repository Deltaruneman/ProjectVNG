class_name FallZone
extends Area3D

## Lưới an toàn dưới sàn: người chơi lọt xuống đây (nhảy ra hố, rơi khỏi map) thì được đưa về
## checkpoint đã lưu ở tầng này, hoặc điểm `default_spawn` nếu chưa lưu. Giữ nguyên máu và quái
## trong tầng, không tải lại scene.

## Id điểm hồi sinh (checkpoint/cửa trong scene) dùng khi chưa lưu checkpoint ở tầng này.
@export var default_spawn := ""
## Độ sâu mặt trên của vùng rơi so với gốc scene (mét, số âm = bên dưới).
@export var top_y := -8.0
## Kích thước vùng phủ theo X/Z. Lớn hơn mọi tầng là được.
@export var extent := 1000.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 2
	monitorable = false
	if get_child_count() == 0:
		var shape := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(extent, 4.0, extent)
		shape.shape = box
		shape.position = Vector3(0, top_y - 2.0, 0)
		add_child(shape)
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if not body is Player:
		return
	_recover.call_deferred(body)


func _recover(player: Player) -> void:
	var stage := GameManager.current_stage
	if stage == null or not is_instance_valid(stage) or not stage.is_ancestor_of(self):
		return
	var spawn := default_spawn
	if GameManager.checkpoint_id != "" and GameManager.checkpoint_stage == stage.scene_file_path:
		spawn = GameManager.checkpoint_id
	if spawn != "" and stage.place_player_at(spawn):
		return
	# Không tìm thấy id: về điểm Spawn mặc định của scene.
	var marker := stage.get_node_or_null("Spawn") as Marker3D
	if marker != null:
		player.global_position = marker.global_position
		player.velocity = Vector3.ZERO
		stage.camera_rig.snap_to_target()
