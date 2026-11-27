class_name FloorBoundary
extends Node3D

## Tường vô hình bao quanh mép sàn của một tầng. Nhảy đôi (~6 m) vượt được tường basement (4 m) và
## rào đỏ, nên cần một lớp tường cao hơn nhiều, không nhìn thấy.
## Tường được dựng lúc chạy từ ô sàn của các GridMap trong `floor_maps` (gộp lại, nên phòng bí mật
## nối liền với sảnh thì không có tường giữa hai bên). Sửa sàn trong editor là tường tự theo.

## Các GridMap sàn. Ô nào ở tầng `floor_level` là có sàn.
@export var floor_maps: Array[GridMap] = []
@export var floor_level := 0
## Chiều cao tường tính từ mặt phẳng của GridMap (mét).
@export var wall_height := 10.0
@export var wall_thickness := 0.6
## Phần tường kéo xuống dưới sàn để không có khe hở.
@export var wall_depth := 2.0


func _ready() -> void:
	if floor_maps.is_empty():
		push_warning("%s chưa có floor_maps, không dựng tường." % get_path())
		return
	var cell_size := floor_maps[0].cell_size
	var floor_cells := {}
	for map in floor_maps:
		if map == null:
			continue
		if not map.cell_size.is_equal_approx(cell_size) \
				or not map.global_transform.is_equal_approx(floor_maps[0].global_transform):
			push_warning("%s: %s lệch cell_size/transform so với map đầu tiên, tường có thể sai chỗ." % [get_path(), map.get_path()])
		for cell: Vector3i in map.get_used_cells():
			if cell.y == floor_level:
				floor_cells[Vector2i(cell.x, cell.z)] = true

	var body := StaticBody3D.new()
	body.name = "Walls"
	body.collision_layer = 1
	body.collision_mask = 0
	add_child(body)
	body.global_transform = floor_maps[0].global_transform

	var sx := cell_size.x
	var sz := cell_size.z
	var t := wall_thickness
	var h := wall_height + wall_depth
	var y_center := (wall_height - wall_depth) / 2.0

	# Cạnh dọc theo trục X (hàng ô có ô trống kề trên/dưới theo Z), gộp các ô liền nhau thành một thanh.
	for side in [-1, 1]:
		var rows := {}
		for cell: Vector2i in floor_cells:
			if not floor_cells.has(Vector2i(cell.x, cell.y + side)):
				if not rows.has(cell.y):
					rows[cell.y] = []
				rows[cell.y].append(cell.x)
		for row in rows:
			for run in _runs(rows[row]):
				var x0 := float(run.x) * sx - t
				var x1 := float(run.y + 1) * sx + t
				var edge: float = float(row + (1 if side > 0 else 0)) * sz
				var z_center: float = edge + side * t / 2.0
				_add_box(body, Vector3((x0 + x1) / 2.0, y_center, z_center), Vector3(x1 - x0, h, t))

	# Cạnh dọc theo trục Z (cột ô có ô trống kề trái/phải theo X).
	for side in [-1, 1]:
		var cols := {}
		for cell: Vector2i in floor_cells:
			if not floor_cells.has(Vector2i(cell.x + side, cell.y)):
				if not cols.has(cell.x):
					cols[cell.x] = []
				cols[cell.x].append(cell.y)
		for col in cols:
			for run in _runs(cols[col]):
				var z0 := float(run.x) * sz - t
				var z1 := float(run.y + 1) * sz + t
				var edge: float = float(col + (1 if side > 0 else 0)) * sx
				var x_center: float = edge + side * t / 2.0
				_add_box(body, Vector3(x_center, y_center, (z0 + z1) / 2.0), Vector3(t, h, z1 - z0))


## Gộp danh sách số nguyên thành các đoạn liên tiếp, mỗi đoạn là Vector2i(đầu, cuối).
func _runs(values: Array) -> Array[Vector2i]:
	var sorted := values.duplicate()
	sorted.sort()
	var result: Array[Vector2i] = []
	var start: int = sorted[0]
	var prev: int = sorted[0]
	for i in range(1, sorted.size()):
		var v: int = sorted[i]
		if v != prev + 1:
			result.append(Vector2i(start, prev))
			start = v
		prev = v
	result.append(Vector2i(start, prev))
	return result


func _add_box(body: StaticBody3D, center: Vector3, size: Vector3) -> void:
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	shape.shape = box
	shape.position = center
	body.add_child(shape)
