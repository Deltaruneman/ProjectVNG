extends Stage

## Stage của basement_full.tscn. Các tầng B1/B2/B3/GroundExit chồng thật lên nhau, nên chỉ render
## tầng player đang đứng để các tầng khác không che camera.
##
## Một tầng là con trực tiếp của Stage có metadata `floor_level` (0 = B1, 1 = B2, …). Tầng có
## metadata `secret` (B1_5) chỉ hiện khi player đứng trong vùng sàn của nó.
##
## Chỉ đổi trạng thái render: va chạm vẫn còn, quái ở tầng bị ẩn vẫn chạy.
## Lưới nóc phòng chỉ ẩn ở phần hình ảnh; collision của GridMap không bị thay đổi.

## Mặt sàn tầng 0 ở độ cao này (ô y = 0, cell_center_y = false → 2·0 + 1).
@export var base_height := 1.0
## Chênh độ cao giữa hai tầng (3 ô × 2 m).
@export var floor_height := 6.0
## Bán kính vùng chuyển quanh marker cầu thang/thang nối tầng.
@export var connector_radius := 3.5
## Tránh chớp tầng khi player đứng sát ngưỡng chuyển.
@export var connector_hysteresis := 0.25

const CONNECTOR_DEFINITIONS := [
	{"path": NodePath("B1/LadderSpot_B1_B2"), "from": 0, "to": 1},
	{"path": NodePath("B2/LadderSpot_B2_B3"), "from": 1, "to": 2},
	{"path": NodePath("B3/LadderSpot_B3_Ground"), "from": 2, "to": 3},
]
const B1_CHEST := preload("res://levels/objects/skill_point/floor_clear_chest.tscn")

var _floors: Array[Node3D] = []
var _ceilings: Array[Node3D] = []
var _connectors: Array[Dictionary] = []
var _active_level := -1
## Tầng secret → Rect2 (x, z) vùng sàn của nó, theo tọa độ thế giới.
var _secret_areas: Dictionary[Node3D, Rect2] = {}


func _ready() -> void:
	super._ready()
	if has_node("B1/ChestSpot"):
		for zone: EnemyZone in $B1/EnemyZones.get_children():
			zone.cleared.connect(_spawn_b1_chest)
	for child: Node in get_children():
		var node := child as Node3D
		if node != null and node.has_meta("floor_level"):
			_floors.append(node)
			var ceiling := node.get_node_or_null("World/Ceiling") as Node3D
			if ceiling != null:
				_ceilings.append(ceiling)
			if node.get_meta("secret", false):
				_secret_areas[node] = _floor_area(node)
	for definition in CONNECTOR_DEFINITIONS:
		var marker := get_node_or_null(definition["path"]) as Marker3D
		if marker != null:
			var connector: Dictionary = definition.duplicate()
			connector["marker"] = marker
			_connectors.append(connector)
	_active_level = _height_level(player.global_position.y)
	_apply(true)


func _spawn_b1_chest() -> void:
	for zone: EnemyZone in $B1/EnemyZones.get_children():
		if not zone.is_cleared():
			return
	$B1/ChestSpot.add_child(B1_CHEST.instantiate())


func _physics_process(_delta: float) -> void:
	_apply(false)


## Ngoài lối nối, giữ tầng theo mặt sàn đang đỡ player. Trong lối nối, chuyển ở nửa chiều cao.
func current_level() -> int:
	var connector := _connector_near_player()
	if not connector.is_empty():
		var from_level := int(connector["from"])
		var to_level := int(connector["to"])
		var midpoint := base_height + (float(from_level) + 0.5) * floor_height
		var y := player.global_position.y
		if player.is_on_floor() or player.is_on_wall():
			if _active_level == from_level and y >= midpoint + connector_hysteresis:
				_active_level = to_level
			elif _active_level == to_level and y <= midpoint - connector_hysteresis:
				_active_level = from_level
		return _active_level

	if player.is_on_floor():
		var supported_level := _supporting_level()
		if supported_level >= 0:
			_active_level = supported_level
	return _active_level


func _height_level(y: float) -> int:
	return floori((y - base_height + floor_height / 2.0) / floor_height)


func _connector_near_player() -> Dictionary:
	var player_flat := Vector2(player.global_position.x, player.global_position.z)
	for connector in _connectors:
		var marker: Marker3D = connector["marker"]
		var marker_flat := Vector2(marker.global_position.x, marker.global_position.z)
		if player_flat.distance_to(marker_flat) <= connector_radius:
			return connector
	return {}


func _supporting_level() -> int:
	var query := PhysicsRayQueryParameters3D.create(
		player.global_position + Vector3.UP * 0.2,
		player.global_position - Vector3.UP * 0.35
	)
	query.exclude = [player.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return -1
	var collider := hit.get("collider") as Node
	while collider != null:
		for floor_node in _floors:
			if floor_node == collider or floor_node.is_ancestor_of(collider):
				return int(floor_node.get_meta("floor_level"))
		collider = collider.get_parent()
	return -1


func _apply(force: bool) -> void:
	var level := current_level()
	var flat := Vector2(player.global_position.x, player.global_position.z)
	for node in _floors:
		var show: bool = node.get_meta("floor_level") == level
		if _secret_areas.has(node):
			show = show and _secret_areas[node].has_point(flat)
		if force or node.visible != show:
			node.visible = show
	for ceiling in _ceilings:
		ceiling.visible = false


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
