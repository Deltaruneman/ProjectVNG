extends Node3D

## Trần/mái của một tầng castle. Trong editor luôn hiện để dễ dựng map.
## Khi chơi: chỉ hiện khi player đang ở tầng `floor_level` VÀ camera thấp hơn trần (TPS/FPS, nhìn
## lên thấy trần). Camera ở trên trần (góc top-down) thì ẩn để thấy nhân vật.
##
## `blocks_player` (bật ở mái trên cùng): Player bật thêm physics layer 9 (ROOF_LAYER) để va vào
## RoofCollision, nên không nhảy ra ngoài castle được. Camera chỉ dò layer 1 nên không bị mái kéo xuống.

## Độ cao đáy trần/mái.
@export var roof_height := 9.0
## Tầng mà trần này thuộc về (0 = F1).
@export var floor_level := 0
## Khoảng đệm để không chớp tắt khi camera đứng sát ngưỡng.
@export var margin := 0.3
@export var blocks_player := false

const ROOF_LAYER := 9


func _ready() -> void:
	if not blocks_player or owner == null:
		return
	# Stage._ready() chạy sau node con, nên lấy Player trực tiếp thay vì dùng Stage.player.
	var player := owner.get_node_or_null("Player") as CollisionObject3D
	if player != null:
		player.set_collision_mask_value(ROOF_LAYER, true)


func _process(_delta: float) -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		return
	var on_level := true
	if owner != null and owner.has_method("current_level"):
		on_level = int(owner.call("current_level")) == floor_level
	var y := camera.global_position.y
	var below := y <= roof_height + margin if visible else y < roof_height - margin
	var want_visible := on_level and below
	if visible != want_visible:
		visible = want_visible
