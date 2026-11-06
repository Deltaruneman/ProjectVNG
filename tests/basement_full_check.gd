extends SceneTree

## Kiểm tra levels/level_1/basement_full.tscn (headless):
##   godot --headless --path . --script res://tests/basement_full_check.gd
## In: item thiếu, số ô đi được + số đảo của từng Pathfinder, ô đi được bị che đầu (xét MỌI GridMap
## trong scene), ô trùng nhau giữa các GridMap (nguy cơ z-fighting).

const SCENE := "res://levels/level_1/basement_full.tscn"
const LIBRARY := "res://assets/meshes/basement_library.meshlib"
const NAMES: Array[String] = ["floor_ground_0", "floor_ground_1", "floor_ground_2", "floor_ground_3",
	"floor_path_0", "floor_path_1", "floor_path_2", "floor_path_corner_in", "floor_path_corner_out",
	"stair_bottom_left", "stair_bottom_right", "stair_medium_left", "stair_medium_right",
	"stair_small_left", "stair_small_right", "stair_top_left", "stair_top_right",
	"stair_beside_bottom", "stair_beside_medium", "stair_beside_top",
	"wall_bottom", "wall_bottom_corner", "wall_bottom_inner", "wall_medium", "wall_medium_corner",
	"wall_medium_inner", "wall_small", "wall_small_corner", "wall_small_inner", "wall_top",
	"wall_top_corner", "wall_top_inner"]

var _fails := 0


func _initialize() -> void:
	var library: MeshLibrary = load(LIBRARY)
	var missing: Array[String] = []
	for item_name in NAMES:
		if library.find_item_by_name(item_name) == -1:
			missing.append(item_name)
	_check(missing.is_empty(), "32 item tìm theo tên", "thiếu: %s" % [missing])

	var stage: Node = (load(SCENE) as PackedScene).instantiate()
	root.add_child.call_deferred(stage)
	await process_frame
	var maps: Array[GridMap] = []
	_collect_maps(stage, maps)

	# Ô dùng chung giữa các GridMap.
	var owners := {}
	var bad_items := 0
	for map in maps:
		for cell in map.get_used_cells():
			var item := map.get_cell_item(cell)
			if item < 0 or not library.get_item_list().has(item):
				bad_items += 1
			if not owners.has(cell):
				owners[cell] = []
			owners[cell].append([map, library.get_item_name(item), map.get_cell_item_orientation(cell)])
	_check(bad_items == 0, "không ô nào trỏ tới item không tồn tại", "%d ô lỗi" % bad_items)
	var shared := 0
	var shared_floor := 0
	for cell in owners:
		var list: Array = owners[cell]
		if list.size() > 1:
			shared += 1
			var floors := 0
			var rots := {}
			for entry in list:
				if String(entry[1]).begins_with("floor_") or String(entry[1]).begins_with("stair_"):
					floors += 1
				rots[entry[2]] = true
			if floors > 1 or rots.size() < list.size():
				shared_floor += 1
				print("   z-fighting? ", cell, " ", list.map(func(e): return "%s:%s@%d" % [_short(e[0]), e[1], e[2]]))
	_check(shared_floor == 0, "không có 2 sàn/2 vách cùng hướng chung một ô (z-fighting)",
		"%d ô" % shared_floor)
	print("   (ô có 2 GridMap: %d — vách chung x=18 quay lưng nhau, mặt ngược chiều: hợp lệ)" % shared)

	# Pathfinder từng tầng.
	for floor_node: Node in stage.get_children():
		var finder := floor_node.get_node_or_null("Pathfinder")
		if finder == null:
			continue
		var count: int = finder.point_count()
		var astar: AStar3D = finder._astar
		var islands := _islands(astar)
		_check(count > 0 and islands == 1, "%s: %d ô đi được, %d đảo" % [floor_node.name, count, islands],
			"pathfinder bị chia đảo")
		# Che đầu: xét mọi GridMap của scene, không chỉ map của tầng.
		var blocked := 0
		for cell: Vector3i in finder._ids:
			for up in [1, 2]:
				var above := cell + Vector3i(0, up, 0)
				if owners.has(above):
					blocked += 1
					print("   che đầu ", floor_node.name, " ", cell, " bởi ", owners[above].map(
						func(e): return "%s:%s" % [_short(e[0]), e[1]]))
		_check(blocked == 0, "%s: mọi ô đi được trống 2 ô phía trên (mọi GridMap)" % floor_node.name,
			"%d ô bị che" % blocked)

	# Marker bắt buộc.
	for path in ["Spawn", "B1/ElevatorSlot", "B2/ElevatorSlot", "B3/ElevatorSlot", "B2/ChestSpot_B2",
			"B3/MiniBossSpot_B3", "B1/HiddenGate_B1_5"]:
		_check(stage.has_node(path), "có node %s" % path, "thiếu")
	print("KET QUA: %s (%d lỗi)" % ["QUA" if _fails == 0 else "TRUOT", _fails])
	quit(1 if _fails > 0 else 0)


func _collect_maps(node: Node, out: Array[GridMap]) -> void:
	if node is GridMap:
		out.append(node)
	for child in node.get_children():
		_collect_maps(child, out)


func _islands(astar: AStar3D) -> int:
	var seen := {}
	var islands := 0
	for id in astar.get_point_ids():
		if seen.has(id):
			continue
		islands += 1
		var stack := [id]
		seen[id] = true
		while not stack.is_empty():
			var p: int = stack.pop_back()
			for q in astar.get_point_connections(p):
				if not seen.has(q):
					seen[q] = true
					stack.append(q)
	return islands


func _short(map: GridMap) -> String:
	return "%s/%s" % [map.get_parent().name, map.name]


func _check(ok: bool, label: String, detail: String) -> void:
	print(("  [OK]   " if ok else "  [LỖI] ") + label + ("" if ok else " — " + detail))
	if not ok:
		_fails += 1
