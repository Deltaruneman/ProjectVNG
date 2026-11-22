extends Stage

## Stage của basement_full.tscn. Các tầng B1/B2/B3/GroundExit chồng thật lên nhau, nên tầng trên che
## tầng dưới trước camera: mỗi frame ẩn mọi tầng nằm TRÊN tầng player đang đứng.
##
## Một tầng là con trực tiếp của Stage có metadata `floor_level` (0 = B1, 1 = B2, …). Tầng có
## metadata `secret` (B1_5) chỉ hiện khi player đứng trong vùng sàn của nó.
##
## Chỉ đổi `visible`: va chạm vẫn còn, quái ở tầng bị ẩn vẫn chạy (chúng cũng bị ẩn theo).

## Mặt sàn tầng 0 ở độ cao này (ô y = 0, cell_center_y = false → 2·0 + 1).
@export var base_height := 1.0
## Chênh độ cao giữa hai tầng (3 ô × 2 m).
@export var floor_height := 6.0
## Player cao hơn mặt sàn tầng dưới chừng này mới tính là đã lên tầng trên. 4.5 m: đứng trên
## High Ground (cao 2 m) rồi nhảy vẫn thuộc tầng dưới; mặt sàn tầng trên cao 6 m.
@export var switch_margin := 4.5

var _floors: Array[Node3D] = []
## Tầng secret → Rect2 (x, z) vùng sàn của nó, theo tọa độ thế giới.
var _secret_areas: Dictionary[Node3D, Rect2] = {}
var _current_level := -1


func _ready() -> void:
	super._ready()
	for child: Node in get_children():
		var node := child as Node3D
		if node != null and node.has_meta("floor_level"):
			_floors.append(node)
			if node.get_meta("secret", false):
				_secret_areas[node] = _floor_area(node)
	_apply(true)


func _process(_delta: float) -> void:
	_apply(false)


## Tầng player đang đứng (0 = B1).
func current_level() -> int:
	return floori((player.global_position.y - base_height + floor_height - switch_margin)
		/ floor_height)


func _apply(force: bool) -> void:
	var level := current_level()
	var flat := Vector2(player.global_position.x, player.global_position.z)
	for node in _floors:
		var show: bool = node.get_meta("floor_level") <= level
		if _secret_areas.has(node):
			show = show and _secret_areas[node].has_point(flat)
		if force or node.visible != show:
			node.visible = show
	_current_level = level


## Vùng (x, z) phủ bởi GridMap "World" của tầng, thu vào nửa ô để vách chung không tính.
func _floor_area(node: Node3D) -> Rect2:
	var map := node.get_node_or_null("World") as GridMap
	if map == null:
		return Rect2()
	var used := map.get_used_cells()
	if used.is_empty():
		return Rect2()
	var lo := map.to_global(map.map_to_local(used[0]))
	var hi := lo
	for cell in used:
		var p := map.to_global(map.map_to_local(cell))
		lo = lo.min(p)
		hi = hi.max(p)
	return Rect2(Vector2(lo.x, lo.z), Vector2(hi.x - lo.x, hi.z - lo.z))
