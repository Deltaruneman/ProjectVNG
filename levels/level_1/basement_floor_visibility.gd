extends Stage

## Stage của basement_full.tscn. Các nhánh tầng chồng thật lên nhau, nên chỉ render
## tầng nhân vật đang đứng; tầng phía trên không được che tầng phía dưới.
##
## Một tầng là con trực tiếp của Stage có metadata `floor_level` (0 = B1, 1 = B2, …). Tầng có
## metadata `secret` (B1_5) hiện khi mở cửa hoặc player đứng trong vùng sàn của nó.
##
## Phòng bí mật giữ cơ chế mở; chỉ ẩn hình trần, không đổi va chạm.
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
const B1_CHEST := preload("res://levels/objects/experience_point/floor_clear_chest.tscn")

var _floors: Array[Node3D] = []
var _ceilings: Array[Node3D] = []
var _connectors: Array[Dictionary] = []
var _active_level := -1
var _floor_heights: Dictionary[int, float] = {}
## Tầng secret → Rect2 (x, z) vùng sàn của nó, theo tọa độ thế giới.
var _secret_areas: Dictionary[Node3D, Rect2] = {}


func _ready() -> void:
	super._ready()
	var b1_zones := get_node_or_null("B1/EnemyZones")
	if has_node("B1/ChestSpot") and b1_zones != null:
		for child: Node in b1_zones.get_children():
			if child is EnemyZone:
				(child as EnemyZone).cleared.connect(_spawn_b1_chest)
		_spawn_b1_chest.call_deferred()
	for child: Node in get_children():
		var node := child as Node3D
		if node != null and node.has_meta("floor_level"):
			_floors.append(node)
			var ceiling := node.get_node_or_null("World/Ceiling") as Node3D
			if ceiling != null:
				_ceilings.append(ceiling)
			if node.get_meta("secret", false):
				_secret_areas[node] = _floor_area(node)
	for floor_node in _floors:
		if not floor_node.get_meta("secret", false):
			_floor_heights[int(floor_node.get_meta("floor_level"))] = _surface_height(floor_node)
	for definition in CONNECTOR_DEFINITIONS:
		# A door to a separate scene is not a connector to an integrated floor.
		if not _has_level(int(definition["from"])) or not _has_level(int(definition["to"])):
			continue
		var marker := get_node_or_null(definition["path"]) as Marker3D
		if marker != null:
			var connector: Dictionary = definition.duplicate()
			connector["marker"] = marker
			_connectors.append(connector)
	_active_level = _height_level(player.global_position.y)
	_apply(true)


func _spawn_b1_chest() -> void:
	var chest_spot := get_node_or_null("B1/ChestSpot") as Node3D
	var b1_zones := get_node_or_null("B1/EnemyZones")
	if chest_spot == null or b1_zones == null:
		return
	var active_zone_count := 0
	for child: Node in b1_zones.get_children():
		if not child is EnemyZone:
			continue
		var zone := child as EnemyZone
		if zone.enemy_scene == null or zone.clear_kills <= 0:
			continue
		active_zone_count += 1
		if not zone.is_cleared():
			return
	if active_zone_count == 0:
		return
	for child: Node in chest_spot.get_children():
		if child.name == "FloorClearChest":
			return
	chest_spot.add_child(B1_CHEST.instantiate())


func _physics_process(_delta: float) -> void:
	_apply(false)


## Ground contact owns floor selection; ladder transitions occur at the actual landing.
func current_level() -> int:
	if not _has_level(_active_level):
		_active_level = _height_level(player.global_position.y)
	if player.is_on_floor():
		var supported_level := _supporting_level()
		if supported_level >= 0:
			_active_level = supported_level
			return _active_level
	var connector := _connector_near_player()
	if not connector.is_empty() and player.is_climbing_stairs():
		var from_level := int(connector["from"])
		var to_level := int(connector["to"])
		var landing: float = _floor_heights.get(to_level, base_height + to_level * floor_height)
		if _active_level == from_level and player.global_position.y >= landing - 0.15:
			_active_level = to_level
		elif _active_level == to_level and player.global_position.y < landing - connector_hysteresis - 0.15:
			_active_level = from_level
	return _active_level


func _height_level(y: float) -> int:
	var selected := -1
	var best_height := -INF
	var lowest_level := -1
	var lowest_height := INF
	for level: int in _floor_heights:
		var height: float = _floor_heights[level]
		if height < lowest_height:
			lowest_level = level
			lowest_height = height
		if height <= y + 0.35 and height > best_height:
			selected = level
			best_height = height
	return selected if selected >= 0 else lowest_level


func _surface_height(floor_node: Node3D) -> float:
	var map := floor_node.get_node_or_null("World/Floor") as GridMap
	if map == null:
		map = floor_node.get_node_or_null("World") as GridMap
	var heights: Array[float] = []
	if map != null and map.mesh_library != null:
		for cell: Vector3i in map.get_used_cells():
			var item := map.get_cell_item(cell)
			var mesh := map.mesh_library.get_item_mesh(item)
			if mesh == null: continue
			var cell_transform := Transform3D(map.get_cell_item_basis(cell).scaled(Vector3.ONE * map.cell_scale), map.map_to_local(cell)) * map.mesh_library.get_item_mesh_transform(item)
			var bounds: AABB = (map.global_transform * cell_transform) * mesh.get_aabb()
			heights.append(bounds.end.y)
	if heights.is_empty():
		return floor_node.global_position.y + base_height + int(floor_node.get_meta("floor_level")) * floor_height
	heights.sort()
	return heights[heights.size() / 2]


func place_player_at(spawn_name: String) -> bool:
	var placed := super.place_player_at(spawn_name)
	if placed and not _floor_heights.is_empty():
		_active_level = _height_level(player.global_position.y)
		_apply(true)
	return placed


func _has_level(level: int) -> bool:
	for node in _floors:
		if int(node.get_meta("floor_level")) == level:
			return true
	return false


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
		player.global_position - Vector3.UP * 0.35, 1
	)
	query.exclude = [player.get_rid()]
	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return -1
	var normal: Vector3 = hit.get("normal", Vector3.ZERO)
	if normal.y < 0.65:
		return -1
	var collider := hit.get("collider") as Node
	for floor_node in _floors:
		var floor_map := floor_node.get_node_or_null("World/Floor")
		if floor_map == null: floor_map = floor_node.get_node_or_null("World")
		var support := floor_node.get_node_or_null("FloorSupport")
		if (floor_map != null and (floor_map == collider or floor_map.is_ancestor_of(collider))) \
				or (support != null and (support == collider or support.is_ancestor_of(collider))):
			return int(floor_node.get_meta("floor_level"))
	return -1


func _apply(force: bool) -> void:
	var level := current_level()
	var flat := Vector2(player.global_position.x, player.global_position.z)
	for node in _floors:
		var show: bool = int(node.get_meta("floor_level")) == level
		if _secret_areas.has(node):
			var reveal_flag := String(node.get_meta("reveal_flag", ""))
			var opened := not reveal_flag.is_empty() and bool(GameManager.flags.get(reveal_flag, false))
			show = show and (opened or _secret_areas[node].has_point(flat))
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
