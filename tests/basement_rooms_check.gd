extends Node

## Kiểm tra headless cho basement_1/2/3: tường vô hình bao kín, rào đỏ cao, vùng rơi đưa về checkpoint.
## Chạy: godot --headless --path . res://tests/basement_rooms_check.tscn

const SCENES := [
	"res://levels/level_1/basement_1.tscn",
	"res://levels/level_1/basement_2.tscn",
	"res://levels/level_1/basement_3.tscn",
]

var failures := 0


func _ready() -> void:
	_run.call_deferred()


func _fail(msg: String) -> void:
	failures += 1
	print("FAIL: ", msg)


func _run() -> void:
	for path in SCENES:
		await _check_scene(path)
	print("RESULT: ", "OK" if failures == 0 else "%d FAIL" % failures)
	get_tree().quit(1 if failures > 0 else 0)


func _check_scene(path: String) -> void:
	print("== ", path)
	var packed := load(path) as PackedScene
	if packed == null:
		_fail("không nạp được scene")
		return
	var stage := packed.instantiate()
	get_tree().root.add_child(stage)
	for i in 4:
		await get_tree().physics_frame

	var boundary := stage.get_node_or_null("FloorBoundary") as FloorBoundary
	var walls := boundary.get_node_or_null("Walls") if boundary != null else null
	if walls == null:
		_fail("thiếu FloorBoundary/Walls")
	else:
		var shapes := walls.get_child_count()
		print("   số hộp tường: ", shapes)
		if shapes < 4:
			_fail("quá ít hộp tường")

	# Kín: từ mọi điểm Spawn/checkpoint bắn tia ở độ cao 8 m (cao hơn tường thật 4 m) ra 16 hướng.
	var space := (stage as Node3D).get_world_3d().direct_space_state
	var origins: Array[Vector3] = []
	for point in get_tree().get_nodes_in_group("spawn_points"):
		if stage.is_ancestor_of(point):
			origins.append(point.get_node("Spawn").global_position)
	var marker := stage.get_node_or_null("Spawn") as Marker3D
	if marker != null:
		origins.append(marker.global_position)
	# Thêm tâm mọi ô sàn làm điểm kiểm tra, và chắc chắn lối ra/điểm hồi sinh nằm trên ô sàn.
	var floor_cells := {}
	if boundary != null:
		for map in boundary.floor_maps:
			for cell: Vector3i in map.get_used_cells():
				if cell.y == boundary.floor_level:
					floor_cells[Vector2i(cell.x, cell.z)] = true
					origins.append(map.to_global(map.map_to_local(cell)))
		var probes: Array[Vector3] = []
		for node in stage.find_children("*", "Area3D", true, false):
			if node.get("target_stage") != null:
				probes.append((node as Node3D).global_position)
		for point in get_tree().get_nodes_in_group("spawn_points"):
			if stage.is_ancestor_of(point):
				probes.append(point.get_node("Spawn").global_position)
		var map0 := boundary.floor_maps[0]
		for pos in probes:
			var cell := map0.local_to_map(map0.to_local(pos))
			if not floor_cells.has(Vector2i(cell.x, cell.z)):
				_fail("điểm %s nằm ngoài sàn (ô %s)" % [pos, cell])
	var leaks := 0
	for o in origins:
		for k in 16:
			var dir := Vector3(cos(TAU * k / 16.0), 0, sin(TAU * k / 16.0))
			var from := Vector3(o.x, 8.0, o.z)
			var q := PhysicsRayQueryParameters3D.create(from, from + dir * 400.0, 1)
			if space.intersect_ray(q).is_empty():
				leaks += 1
	print("   điểm kiểm tra: %d, tia lọt: %d" % [origins.size(), leaks])
	if leaks > 0:
		_fail("tường không kín (%d tia lọt)" % leaks)

	# Rào đỏ cao ≥ 10 m.
	for gate in stage.find_children("*", "Node3D", true, false):
		if gate is RoomGate:
			var rg := gate as RoomGate
			if rg.height < 10.0:
				_fail("%s cao %.1f" % [rg.get_path(), rg.height])
	print("   rào đỏ: ", stage.find_children("*", "Node3D", true, false).filter(func(n): return n is RoomGate).size())

	# Vùng rơi: thả người chơi xuống dưới sàn, phải được đưa lên lại.
	var player := stage.get_node("Player") as Player
	var fall_zone := stage.get_node_or_null("FallZone") as FallZone
	if fall_zone == null:
		_fail("thiếu FallZone")
	else:
		var start := player.global_position
		player.global_position = Vector3(start.x, fall_zone.top_y - 1.0, start.z)
		player.velocity = Vector3.ZERO
		for i in 6:
			await get_tree().physics_frame
		print("   sau khi rơi: y=%.2f (spawn y=%.2f)" % [player.global_position.y, start.y])
		if player.global_position.y < fall_zone.top_y:
			_fail("người chơi vẫn ở dưới vùng rơi")

	# Decor: có món nào, món có va chạm vào nhóm path_blockers, và đường đi từ điểm xuất hiện tới lối ra vẫn thông.
	var props := stage.find_children("*", "DecorProp", true, false)
	var blockers := 0
	for prop in props:
		if (prop as DecorProp).collision_size != Vector3.ZERO and (prop as DecorProp).is_in_group(&"path_blockers"):
			blockers += 1
	print("   decor: %d món, %d chặn đường" % [props.size(), blockers])
	if props.is_empty():
		_fail("không có decor")
	var finders := stage.find_children("*", "GridPathfinder", true, false)
	if finders.is_empty():
		_fail("thiếu Pathfinder")
	else:
		var finder := finders[0] as GridPathfinder
		var spawn_marker := stage.get_node("Spawn") as Marker3D
		for node in stage.find_children("*", "Area3D", true, false):
			if node.get("target_stage") != null:
				var route := finder.find_path(spawn_marker.global_position, (node as Node3D).global_position)
				print("   đường tới %s: %d điểm" % [node.name, route.size()])
				if route.is_empty():
					_fail("không có đường từ điểm xuất hiện tới %s" % node.name)

	stage.queue_free()
	for i in 3:
		await get_tree().physics_frame
