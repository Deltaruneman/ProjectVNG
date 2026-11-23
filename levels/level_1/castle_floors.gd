extends Stage

## Stage của castle.tscn. Các tầng (F1, F2) chồng thật lên nhau nên chỉ hiện tầng player đang đứng
## và các tầng bên dưới nó: đứng ở F1 thì sàn F2 không che camera top-down, đứng ở F2 vẫn nhìn
## xuống F1 qua lỗ cầu thang.
##
## Một tầng là con trực tiếp của Stage có metadata `floor_level` (0 = F1, 1 = F2, …).
## Chỉ đổi phần hiển thị: va chạm vẫn còn, quái ở tầng bị ẩn vẫn chạy.
## Trần/mái từng tầng do castle_roof.gd tự bật tắt, dựa vào current_level().

## Mặt sàn tầng 0.
@export var base_height := 1.0
## Chênh độ cao giữa hai tầng.
@export var floor_height := 8.0

var _floors: Array[Node3D] = []
var _level := 0


func _ready() -> void:
	super._ready()
	for child: Node in get_children():
		var node := child as Node3D
		if node != null and node.has_meta("floor_level"):
			_floors.append(node)
	_level = _level_at(player.global_position.y)
	_apply()


func _physics_process(_delta: float) -> void:
	# Chỉ đổi tầng khi đang đứng trên sàn/cầu thang, để lúc nhảy không chớp tầng.
	if not player.is_on_floor():
		return
	var level := _level_at(player.global_position.y)
	if level != _level:
		_level = level
		_apply()


## Tầng player đang đứng (0 = F1).
func current_level() -> int:
	return _level


## Lên gần hết cầu thang (cách sàn trên 1 m) thì tính là tầng trên.
func _level_at(y: float) -> int:
	return maxi(0, floori((y - base_height + 1.0) / floor_height))


func _apply() -> void:
	for node in _floors:
		node.visible = int(node.get_meta("floor_level")) <= _level
