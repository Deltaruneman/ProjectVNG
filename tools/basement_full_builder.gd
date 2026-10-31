extends RefCounted

## Dựng levels/level_1/basement_full.tscn: B1, B1.5 (ẩn), B2, B3 và ô sàn GroundExit chồng lên nhau
## trong một scene. Mọi tile lấy từ basement_library THEO TÊN.
##
## Gọi từ tools/build_basement_full.gd (EditorScript, File | Run trong Script Editor) hoặc headless:
##   godot --headless --path . --script res://tests/run_build_basement_full.gd
## Đổi bố cục: sửa các hằng số / hàm _build_* bên dưới rồi chạy lại. Scene bị ghi đè toàn bộ.
##
## Quy ước lưới (giống stage_1_basement.tscn):
##   - cell_size (2, 2, 2), cell_center_y = false → mặt sàn của ô y nằm ở độ cao 2y + 1 m.
##   - +z là phía trước (camera nhìn từ +z về −z), −z là phía sau.
##   - Vách (wall_*) là tấm nằm ở nửa ô, mặt nhìn thấy ở tâm ô. Vách phòng đặt ở VÀNH ô bao ngoài
##     vùng sàn, mặt quay vào trong; ô vành cũng có sàn (để không hở khe) nhưng có vách ở trên nên
##     pathfinder không coi là đi được.
##   - Vách cao 2 ô (wall_bottom + wall_top) ở trái/phải/sau; phía trước chỉ wall_small 1 ô để không
##     che nhân vật.

const OUTPUT := "res://levels/level_1/basement_full.tscn"
const LIBRARY := "res://assets/meshes/basement_library.meshlib"
const STAGE_SCRIPT := "res://levels/level_1/basement_floor_visibility.gd"
const PATHFINDER_SCRIPT := "res://scripts/grid_pathfinder.gd"
const PLAYER_SCENE := "res://scenes/player/player.tscn"
const CAMERA_SCENE := "res://scenes/camera/camera_rig.tscn"
const ENEMY_ZONE_SCENE := "res://levels/objects/enemy_zone/enemy_zone.tscn"

const CELL := Vector3(2, 2, 2)
## Mỗi tầng cách nhau 3 ô theo chiều cao.
const FLOOR_STEP := 3

## Chỉ số xoay trực giao của GridMap (xoay quanh trục Y).
const R0 := 0      # vách mặt +z, stair leo về −z
const R90 := 16    # vách mặt +x, stair leo về −x
const R180 := 10   # vách mặt −z, stair leo về +z
const R270 := 22   # vách mặt −x, stair leo về +x

const GROUND_TILES: Array[String] = ["floor_ground_0", "floor_ground_1", "floor_ground_2",
	"floor_ground_3"]
const PATH_TILES: Array[String] = ["floor_path_0", "floor_path_1", "floor_path_2"]

var library: MeshLibrary
var rng := RandomNumberGenerator.new()
var missing: PackedStringArray = []


## Dựng và lưu scene. Trả về OK hoặc mã lỗi.
func build() -> int:
	library = load(LIBRARY)
	if library == null:
		push_error("Không load được %s" % LIBRARY)
		return ERR_CANT_OPEN
	rng.seed = 116

	var stage := Node3D.new()
	stage.name = "Stage"
	stage.set_script(load(STAGE_SCRIPT))

	_add_environment(stage)

	var b1 := _floor_node(stage, "B1", 0)
	var b1_5 := _floor_node(stage, "B1_5", 0)
	b1_5.set_meta("secret", true)
	var b2 := _floor_node(stage, "B2", 1)
	var b3 := _floor_node(stage, "B3", 2)
	var ground := _floor_node(stage, "GroundExit", 3)

	var gate := _build_b1_5(b1_5, stage)
	_build_b1(b1, stage, gate)
	_build_b2(b2, stage)
	_build_b3(b3, stage)
	_build_ground(ground, stage)

	# Player + camera + Spawn (mép trái B1, trong đường hầm).
	var spawn := Marker3D.new()
	spawn.name = "Spawn"
	spawn.position = _surface(-2, 0, 6.5)
	_add(stage, stage, spawn)

	var player: Node3D = (load(PLAYER_SCENE) as PackedScene).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	player.name = "Player"
	player.position = spawn.position + Vector3(0, 0.2, 0)
	_add(stage, stage, player)

	var rig: Node3D = (load(CAMERA_SCENE) as PackedScene).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	rig.name = "CameraRig"
	_add(stage, stage, rig)
	rig.set("target", player)

	var bullets := Node3D.new()
	bullets.name = "Bullets"
	_add(stage, stage, bullets)

	if not missing.is_empty():
		push_error("Thiếu item trong basement_library: %s" % ", ".join(missing))
		stage.free()
		return ERR_DOES_NOT_EXIST

	var packed := PackedScene.new()
	var error := packed.pack(stage)
	if error == OK:
		error = ResourceSaver.save(packed, OUTPUT)
	stage.free()
	if error != OK:
		push_error("Lưu %s thất bại: %d" % [OUTPUT, error])
	else:
		print("Đã dựng %s" % OUTPUT)
	return error


# ---------------------------------------------------------------- tầng

## B1 – y = 0, sàn x 0–17, z 0–13. Đường hầm ở mép trái (z 6–7), khối cao 1 ô ở góc trái-sau.
func _build_b1(b1: Node3D, stage: Node3D, gate: Dictionary) -> void:
	var y := 0
	var cells := {}
	_room(cells, y, 0, 17, 0, 13)
	# Cửa đường hầm trên vách trái: bỏ vách ở (−1, z 6–7), góc lồi hai bên cửa.
	for z in [6, 7]:
		_clear_walls(cells, -1, y, z)
	_put(cells, Vector3i(-1, y + 1, 5), "wall_bottom_corner", R0)
	_put(cells, Vector3i(-1, y + 2, 5), "wall_top_corner", R0)
	_put(cells, Vector3i(-1, y + 1, 8), "wall_bottom_corner", R90)
	_put(cells, Vector3i(-1, y + 2, 8), "wall_top_corner", R90)
	# Đường hầm x −3..−2: sàn path, vách hai bên + vách cuối.
	for x in [-3, -2]:
		for z in [6, 7]:
			_path(cells, Vector3i(x, y, z), z == 6)
		_floor(cells, Vector3i(x, y, 5))
		_floor(cells, Vector3i(x, y, 8))
		_wall2(cells, Vector3i(x, y, 5), R0)
		_wall2(cells, Vector3i(x, y, 8), R180)
	for z in range(5, 9):
		_floor(cells, Vector3i(-4, y, z))
	for z in [6, 7]:
		_wall2(cells, Vector3i(-4, y, z), R90)
	_put(cells, Vector3i(-4, y + 1, 5), "wall_bottom_inner", R0)
	_put(cells, Vector3i(-4, y + 2, 5), "wall_top_inner", R0)
	_put(cells, Vector3i(-4, y + 1, 8), "wall_bottom_inner", R90)
	_put(cells, Vector3i(-4, y + 2, 8), "wall_top_inner", R90)
	# Lối đi chính: path rộng 2 ô từ cửa hầm sang vách phải.
	for x in range(-1, 18):
		_path(cells, Vector3i(x, y, 6), true)
		_path(cells, Vector3i(x, y, 7), false)
	# Lối nhánh tới chỗ đặt thang lên B2 (x = 8, sát vách sau).
	for z in range(0, 6):
		_path(cells, Vector3i(8, y, z), true, true)
		_path(cells, Vector3i(9, y, z), false, true)
	# Vách chung với B1.5 ở x = 18: 2 ô lối vào tương lai nằm trong HiddenGate_B1_5.
	for cell: Vector3i in gate["b1_side"]:
		cells.erase(cell)
	# High Ground: khối cao 1 ô x 0–4, z 0–3 (không nằm dưới B2), bậc stair_small ở mép trước.
	_plateau(cells, y, 0, 4, 0, 3, [2, 3])

	var world := _grid(b1, stage, "World", cells)
	_pathfinder(b1, stage, world, gate["maps"])
	var zones := _node(b1, stage, "EnemyZones")
	_enemy_zone(zones, stage, "EnemyZone_A", _surface(13.5, y, 2.5))
	_enemy_zone(zones, stage, "EnemyZone_B", _surface(13.5, y, 10.5))
	_enemy_zone(zones, stage, "EnemyZone_C", _surface(4.5, y, 10.5))
	_marker(b1, stage, "ElevatorSlot", _surface(16.5, y, 0.5))
	_marker(b1, stage, "LadderSpot_B1_B2", _surface(8, y, 0))
	_torches(b1, stage, y, [[Vector2(7, -1), Vector2(0, 1)], [Vector2(14, -1), Vector2(0, 1)],
		[Vector2(-1, 11), Vector2(1, 0)], [Vector2(18, 3), Vector2(-1, 0)], [Vector2(18, 11), Vector2(-1, 0)]])


## B1.5 – phòng ẩn y = 0, sàn x 19–27, z 3–10. Vách chung x = 18 (B1 giữ ô sàn ở cột này).
## Trả về {"maps": [GridMap…], "b1_side": [ô vách phía B1 cần bỏ khỏi B1]}.
func _build_b1_5(b1_5: Node3D, stage: Node3D) -> Dictionary:
	var y := 0
	var cells := {}
	_room(cells, y, 19, 27, 3, 10)
	# Cột x = 18: sàn thuộc B1 (tránh 2 tile sàn trùng ô → z-fighting).
	for z in range(2, 12):
		cells.erase(Vector3i(18, y, z))

	var gate_rows := [6, 7]
	var b1_5_side := {}
	var b1_side := {}
	for z in gate_rows:
		for up in [1, 2]:
			var cell := Vector3i(18, y + up, z)
			b1_5_side[cell] = cells[cell]
			cells.erase(cell)
			b1_side[cell] = [_id("wall_bottom" if up == 1 else "wall_top"), R270]
	var world := _grid(b1_5, stage, "World", cells)

	# Cửa ẩn nằm dưới B1 (không phải B1_5): B1_5 bị ẩn khi player ở ngoài, nếu cửa nằm trong đó thì
	# vách B1 sẽ trông như bị thủng.
	var gate := _node(stage.get_node("B1"), stage, "HiddenGate_B1_5")
	gate.set_meta("note", "Lối vào B1.5 (x = 18, z 6–7). Mở: queue_free() node này. Ẩn (visible) KHÔNG tắt va chạm.")
	var map_b1 := _grid(gate, stage, "B1Side", b1_side)
	var map_b1_5 := _grid(gate, stage, "B1_5Side", b1_5_side)
	_pathfinder(b1_5, stage, world, [map_b1, map_b1_5])
	_torches(b1_5, stage, y, [[Vector2(23, 2), Vector2(0, 1)], [Vector2(28, 8), Vector2(-1, 0)]])
	return {"maps": [map_b1, map_b1_5], "b1_side": b1_side.keys()}


## B2 – y = 3, sàn x 6–27, z 0–13. Lỗ thang từ B1 ở (8, z 0), khu rương 6×6, chỗ thang lên B3 x = 25.
func _build_b2(b2: Node3D, stage: Node3D) -> void:
	var y := FLOOR_STEP
	var cells := {}
	_room(cells, y, 6, 27, 0, 13)
	for x in range(6, 28):
		_path(cells, Vector3i(x, y, 11), true)
		_path(cells, Vector3i(x, y, 12), false)
	_hole(cells, y, 8, 0)
	var world := _grid(b2, stage, "World", cells)
	_pathfinder(b2, stage, world, [])
	_marker(b2, stage, "ChestSpot_B2", _surface(16.5, y, 6.5))    # khu trống x 14–19, z 4–9
	var zones := _node(b2, stage, "EnemyZones")
	_enemy_zone(zones, stage, "EnemyZone_A", _surface(11.5, y, 6.5))
	_enemy_zone(zones, stage, "EnemyZone_B", _surface(21.5, y, 6.5))
	_marker(b2, stage, "ElevatorSlot", _surface(26.5, y, 0.5))
	_marker(b2, stage, "LadderSpot_B2_B3", _surface(25, y, 2))
	_torches(b2, stage, y, [[Vector2(12, -1), Vector2(0, 1)], [Vector2(20, -1), Vector2(0, 1)],
		[Vector2(5, 7), Vector2(1, 0)], [Vector2(28, 7), Vector2(-1, 0)]])


## B3 – y = 6, sàn x 12–27, z 0–13. Lỗ thang từ B2 ở (25, z 2), arena 10×10 x 14–23, z 2–11.
func _build_b3(b3: Node3D, stage: Node3D) -> void:
	var y := 2 * FLOOR_STEP
	var cells := {}
	_room(cells, y, 12, 27, 0, 13)
	_hole(cells, y, 25, 2)
	var world := _grid(b3, stage, "World", cells)
	_pathfinder(b3, stage, world, [])
	_marker(b3, stage, "MiniBossSpot_B3", _surface(18.5, y, 6.5))
	_marker(b3, stage, "ElevatorSlot", _surface(26.5, y, 0.5))
	_marker(b3, stage, "LadderSpot_B3_Ground", _surface(13, y, 1))
	_torches(b3, stage, y, [[Vector2(16, -1), Vector2(0, 1)], [Vector2(21, -1), Vector2(0, 1)],
		[Vector2(11, 6), Vector2(1, 0)], [Vector2(28, 8), Vector2(-1, 0)]])


## GroundExit – y = 9: vòng sàn 3×3 quanh miệng thang (13, z 1).
func _build_ground(ground: Node3D, stage: Node3D) -> void:
	var y := 3 * FLOOR_STEP
	var cells := {}
	for x in range(12, 15):
		for z in range(0, 3):
			if not (x == 13 and z == 1):
				_floor(cells, Vector3i(x, y, z))
	_grid(ground, stage, "World", cells)


# ---------------------------------------------------------------- khối dựng

## Phòng: sàn x0..x1 × z0..z1 + vành sàn bao ngoài, vách quay vào trong ở vành.
func _room(cells: Dictionary, y: int, x0: int, x1: int, z0: int, z1: int) -> void:
	for x in range(x0 - 1, x1 + 2):
		for z in range(z0 - 1, z1 + 2):
			_floor(cells, Vector3i(x, y, z))
	for z in range(z0, z1 + 1):
		_wall2(cells, Vector3i(x0 - 1, y, z), R90)    # trái, mặt +x
		_wall2(cells, Vector3i(x1 + 1, y, z), R270)   # phải, mặt −x
	for x in range(x0, x1 + 1):
		_wall2(cells, Vector3i(x, y, z0 - 1), R0)     # sau, mặt +z
		_put(cells, Vector3i(x, y + 1, z1 + 1), "wall_small", R180)    # trước, thấp
	_put(cells, Vector3i(x0 - 1, y + 1, z0 - 1), "wall_bottom_inner", R0)
	_put(cells, Vector3i(x0 - 1, y + 2, z0 - 1), "wall_top_inner", R0)
	_put(cells, Vector3i(x1 + 1, y + 1, z0 - 1), "wall_bottom_inner", R270)
	_put(cells, Vector3i(x1 + 1, y + 2, z0 - 1), "wall_top_inner", R270)
	_put(cells, Vector3i(x0 - 1, y + 1, z1 + 1), "wall_small_inner", R90)
	_put(cells, Vector3i(x1 + 1, y + 1, z1 + 1), "wall_small_inner", R180)


## Khối cao 1 ô áp vào góc trái-sau của phòng (x0, z0 là mép phòng). Vách ngoài là wall_small,
## bậc stair_small_left/right ở các cột `stair_x` của mép trước.
func _plateau(cells: Dictionary, y: int, x0: int, x1: int, z0: int, z1: int, stair_x: Array) -> void:
	var top := y + 1
	# Sàn thấp dưới khối không cần nữa.
	for x in range(x0, x1 + 1):
		for z in range(z0, z1 + 1):
			cells.erase(Vector3i(x, y, z))
			_floor(cells, Vector3i(x, top, z))
	# Vành phòng cạnh khối: nâng sàn lên ngang mặt khối, vách phòng chỉ còn wall_top ở trên.
	for z in range(z0 - 1, z1 + 1):
		var c := Vector3i(x0 - 1, y, z)
		cells.erase(c)
		_floor(cells, Vector3i(x0 - 1, top, z))
	for x in range(x0, x1 + 1):
		var c := Vector3i(x, y, z0 - 1)
		cells.erase(c)
		_floor(cells, Vector3i(x, top, z0 - 1))
	# Vách đá của khối (mặt quay ra ngoài, giống stage_1_basement).
	for z in range(z0, z1 + 1):
		_put(cells, Vector3i(x1 + 1, top, z), "wall_small", R90)
	for x in range(x0, x1 + 1):
		if x in stair_x:
			continue
		_put(cells, Vector3i(x, top, z1 + 1), "wall_small", R0)
	_put(cells, Vector3i(x1 + 1, top, z1 + 1), "wall_small_corner", R0)
	# Hai đầu vành đã nâng: góc lõm wall_small_inner bịt khe giữa vành nâng và vành thấp (không có nó
	# sẽ hở một rãnh đen 1 m ở chỗ khối giáp vách phòng).
	_put(cells, Vector3i(x0 - 1, top, z1 + 1), "wall_small_inner", R0)
	_put(cells, Vector3i(x1 + 1, top, z0 - 1), "wall_small_inner", R0)
	_put(cells, Vector3i(stair_x[0], top, z1 + 1), "stair_small_left", R0)
	_put(cells, Vector3i(stair_x[1], top, z1 + 1), "stair_small_right", R0)


## Lỗ sàn 1×1 với lan can wall_small ở trái, phải (và sau nếu không sát vách). Lan can quay mặt ra
## ngoài, nằm ở nửa ô sát lỗ. Phía trước (+z) để trống: phía bước ra khỏi thang.
func _hole(cells: Dictionary, y: int, x: int, z: int) -> void:
	cells.erase(Vector3i(x, y, z))
	_put(cells, Vector3i(x - 1, y + 1, z), "wall_small", R270)
	_put(cells, Vector3i(x + 1, y + 1, z), "wall_small", R90)
	if not cells.has(Vector3i(x, y + 1, z - 1)):
		_put(cells, Vector3i(x, y + 1, z - 1), "wall_small", R180)


func _wall2(cells: Dictionary, base: Vector3i, rot: int) -> void:
	_put(cells, base + Vector3i(0, 1, 0), "wall_bottom", rot)
	_put(cells, base + Vector3i(0, 2, 0), "wall_top", rot)


func _clear_walls(cells: Dictionary, x: int, y: int, z: int) -> void:
	cells.erase(Vector3i(x, y + 1, z))
	cells.erase(Vector3i(x, y + 2, z))


func _floor(cells: Dictionary, cell: Vector3i) -> void:
	_put(cells, cell, GROUND_TILES[rng.randi_range(0, GROUND_TILES.size() - 1)], R0)


## Ô path của một lối rộng 2 ô. Lối chạy theo x: hàng sau R0, hàng trước R180.
## `along_z`: lối chạy theo z: cột trái R90, cột phải R270 (như stage_1_basement).
func _path(cells: Dictionary, cell: Vector3i, first: bool, along_z := false) -> void:
	var rot := (R90 if first else R270) if along_z else (R0 if first else R180)
	_put(cells, cell, PATH_TILES[rng.randi_range(0, PATH_TILES.size() - 1)], rot)


func _put(cells: Dictionary, cell: Vector3i, item_name: String, rot: int) -> void:
	cells[cell] = [_id(item_name), rot]


func _id(item_name: String) -> int:
	var id := library.find_item_by_name(item_name)
	if id == -1 and not missing.has(item_name):
		missing.append(item_name)
	return id


# ---------------------------------------------------------------- node

func _add(stage: Node3D, parent: Node, child: Node) -> void:
	parent.add_child(child)
	child.owner = stage


func _node(parent: Node, stage: Node3D, node_name: String) -> Node3D:
	var node := Node3D.new()
	node.name = node_name
	_add(stage, parent, node)
	return node


func _floor_node(stage: Node3D, node_name: String, level: int) -> Node3D:
	var node := _node(stage, stage, node_name)
	node.set_meta("floor_level", level)
	return node


func _grid(parent: Node, stage: Node3D, node_name: String, cells: Dictionary) -> GridMap:
	var map := GridMap.new()
	map.name = node_name
	map.mesh_library = library
	map.cell_size = CELL
	map.cell_center_y = false
	for cell: Vector3i in cells:
		var v: Array = cells[cell]
		map.set_cell_item(cell, v[0], v[1])
	_add(stage, parent, map)
	return map


func _pathfinder(parent: Node, stage: Node3D, floor_map: GridMap, obstacles: Array) -> void:
	var finder := Node.new()
	finder.name = "Pathfinder"
	finder.set_script(load(PATHFINDER_SCRIPT))
	_add(stage, parent, finder)
	finder.set("floor_map", floor_map)
	var typed: Array[GridMap] = []
	for map: GridMap in obstacles:
		typed.append(map)
	finder.set("obstacle_maps", typed)


func _marker(parent: Node, stage: Node3D, node_name: String, pos: Vector3) -> void:
	var marker := Marker3D.new()
	marker.name = node_name
	marker.position = pos
	_add(stage, parent, marker)


## EnemyZone TRỐNG (enemy_scene = null): chưa sinh quái. Gán enemy_scene trong Inspector khi cần.
func _enemy_zone(parent: Node, stage: Node3D, node_name: String, pos: Vector3) -> void:
	var zone: Node3D = (load(ENEMY_ZONE_SCENE) as PackedScene).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	zone.name = node_name
	zone.position = pos
	_add(stage, parent, zone)
	zone.set("enemy_scene", null)


## Đuốc: OmniLight3D cam + khối phát sáng nhỏ. Mỗi spot = [Vector2(x, z) của ô vành có vách,
## Vector2(dx, dz) hướng vào trong phòng]. Mặt vách nằm ở tâm ô vành → đuốc cách mặt vách 0.4 m.
func _torches(parent: Node, stage: Node3D, y: int, spots: Array) -> void:
	var group := _node(parent, stage, "Torches")
	var mesh := BoxMesh.new()
	mesh.size = Vector3(0.25, 0.5, 0.25)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(1.0, 0.55, 0.2)
	material.emission_enabled = true
	material.emission = Color(1.0, 0.5, 0.15)
	material.emission_energy_multiplier = 3.0
	mesh.material = material
	var index := 0
	for spot: Array in spots:
		var cell: Vector2 = spot[0]
		var inward: Vector2 = spot[1]
		var torch := OmniLight3D.new()
		torch.name = "Torch%d" % index
		torch.light_color = Color(1.0, 0.62, 0.32)
		torch.light_energy = 2.2
		torch.omni_range = 11.0
		torch.omni_attenuation = 1.2
		torch.position = _surface(cell.x, y, cell.y) + Vector3(inward.x * 0.4, 2.6, inward.y * 0.4)
		_add(stage, group, torch)
		var flame := MeshInstance3D.new()
		flame.name = "Flame"
		flame.mesh = mesh
		flame.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		_add(stage, torch, flame)
		index += 1


## Tâm mặt sàn của ô (x, y, z) theo tọa độ thế giới (x, z có thể lẻ .5 để lấy giữa 2 ô).
func _surface(x: float, y: int, z: float) -> Vector3:
	return Vector3(x * CELL.x + CELL.x / 2.0, y * CELL.y + CELL.y / 2.0, z * CELL.z + CELL.z / 2.0)


func _add_environment(stage: Node3D) -> void:
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.015, 0.012, 0.02)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.45, 0.47, 0.62)
	env.ambient_light_energy = 0.35
	var world_env := WorldEnvironment.new()
	world_env.name = "WorldEnvironment"
	world_env.environment = env
	_add(stage, stage, world_env)
