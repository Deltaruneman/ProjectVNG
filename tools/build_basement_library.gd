
@tool
extends EditorScript

## Dựng assets/meshes/basement_library.tscn từ các file .glb
## trong assets/grid_map/basement.
##
## - Gộp tất cả MeshInstance3D trong mỗi model.
## - Giữ transform của các mesh con.
## - Cầu thang dùng ramp hình nêm để nhân vật đi lên mượt hơn.
## - Các model khác dùng trimesh.
##
## Cách chạy:
## Mở file trong Script Editor rồi bấm File | Run
## (Ctrl + Shift + X).

const SOURCE_DIR := "res://assets/grid_map/basement"
const OUTPUT := "res://assets/meshes/basement_library.tscn"

const SHELF_SPACING := 3.0
const SHELF_COLUMNS := 8

## Tên file chứa một trong những từ này sẽ dùng collider ramp.
const STAIR_KEYWORDS := ["stair", "step"]

## Ngưỡng tương quan tối thiểu để xác định hướng leo.
const MIN_STAIR_CORRELATION := 0.05


func _run() -> void:
	var dir := DirAccess.open(SOURCE_DIR)
	if dir == null:
		push_error("Không mở được thư mục: %s" % SOURCE_DIR)
		return

	var files := dir.get_files()
	files.sort()

	var root := Node3D.new()
	root.name = "BasementLibrary"

	var index := 0
	var skipped := 0

	for file: String in files:
		if not file.to_lower().ends_with(".glb"):
			continue

		var item_name := file.get_basename()
		var path := SOURCE_DIR.path_join(file)

		print("\nĐang xử lý: %s" % file)

		## Tải và gộp toàn bộ mesh, bao gồm transform của node con.
		var mesh := _load_mesh(path)

		if mesh == null or mesh.get_surface_count() == 0:
			push_warning("%s: không tìm thấy mesh hợp lệ" % file)
			skipped += 1
			continue

		## Tạo node hiển thị của item.
		var instance := MeshInstance3D.new()
		instance.name = item_name
		instance.mesh = mesh

		instance.position = Vector3(
			(index % SHELF_COLUMNS) * SHELF_SPACING,
			0.0,
			(index / SHELF_COLUMNS) * SHELF_SPACING
		)

		root.add_child(instance)
		instance.owner = root

		## Tạo physics body.
		var body := StaticBody3D.new()
		body.name = "StaticBody3D"
		instance.add_child(body)
		body.owner = root

		## Tạo collision shape.
		var collision := CollisionShape3D.new()
		collision.name = "CollisionShape3D"

		var shaped := _shape_for(item_name, mesh)

		if shaped[0] == null:
			push_warning("%s: không tạo được collision shape" % item_name)
			body.queue_free()
			instance.queue_free()
			skipped += 1
			continue

		collision.shape = shaped[0]
		collision.transform = shaped[1]

		body.add_child(collision)
		collision.owner = root

		print("  Collider: %s" % shaped[2])

		index += 1

	## Đóng gói scene.
	var packed := PackedScene.new()
	var error := packed.pack(root)

	if error == OK:
		error = ResourceSaver.save(packed, OUTPUT)

	if error != OK:
		push_error("Lưu %s thất bại: %d" % [OUTPUT, error])
		root.free()
		return

	print("\n========================================")
	print("Đã dựng thư viện: %s" % OUTPUT)
	print("Số item thành công: %d" % index)
	print("Số item bị bỏ qua: %d" % skipped)
	print("========================================")

	root.free()

	## Làm mới FileSystem dock.
	EditorInterface.get_resource_filesystem().scan()


## ============================================================
## TẠO COLLIDER
## ============================================================

func _shape_for(item_name: String, mesh: Mesh) -> Array:
	var lower := item_name.to_lower()

	for keyword: String in STAIR_KEYWORDS:
		if lower.contains(keyword):
			var ramp := _make_ramp(mesh)

			if ramp != null:
				return [
					ramp,
					Transform3D.IDENTITY,
					"ramp (wedge)"
				]

			push_warning(
				"%s: không xác định được hướng ramp, dùng trimesh"
				% item_name
			)
			break

	var trimesh := mesh.create_trimesh_shape()

	if trimesh == null:
		return [null, Transform3D.IDENTITY, "failed"]

	return [
		trimesh,
		Transform3D.IDENTITY,
		"trimesh"
	]


## Tạo ramp hình lăng trụ tam giác.
##
## Dùng tương quan giữa độ cao Y với trục X/Z để dò hướng cầu thang.
## Tương quan dương: phía cao nằm về phía tọa độ tăng.
## Tương quan âm: phía cao nằm về phía tọa độ giảm.
func _make_ramp(mesh: Mesh) -> ConvexPolygonShape3D:
	var faces := mesh.get_faces()

	if faces.is_empty():
		return null

	var box := mesh.get_aabb()
	var min_p := box.position
	var max_p := box.end

	if box.size.y <= 0.001:
		return null

	## Tính trung bình Y và phương sai Y.
	var mean_y := 0.0

	for vertex: Vector3 in faces:
		mean_y += vertex.y

	mean_y /= float(faces.size())

	var variance_y := 0.0

	for vertex: Vector3 in faces:
		var dy := vertex.y - mean_y
		variance_y += dy * dy

	if variance_y <= 0.000001:
		return null

	## Tìm trục X hoặc Z có tương quan mạnh nhất với độ cao.
	var best_axis := -1
	var best_correlation := 0.0
	var best_covariance := 0.0

	for axis: int in [0, 2]:
		var mean_axis := 0.0

		for vertex: Vector3 in faces:
			mean_axis += vertex[axis]

		mean_axis /= float(faces.size())

		var covariance := 0.0
		var variance_axis := 0.0

		for vertex: Vector3 in faces:
			var dx := vertex[axis] - mean_axis
			var dy := vertex.y - mean_y

			covariance += dx * dy
			variance_axis += dx * dx

		if variance_axis <= 0.000001:
			continue

		var denominator := sqrt(variance_axis * variance_y)

		if denominator <= 0.000001:
			continue

		var correlation := covariance / denominator

		if absf(correlation) > absf(best_correlation):
			best_correlation = correlation
			best_covariance = covariance
			best_axis = axis

	## Không đủ thông tin để xác định hướng dốc.
	if best_axis == -1:
		return null

	if absf(best_correlation) < MIN_STAIR_CORRELATION:
		return null

	## Phía chân thang và phía đỉnh thang.
	var low_edge: float
	var high_edge: float

	if best_covariance > 0.0:
		low_edge = min_p[best_axis]
		high_edge = max_p[best_axis]
	else:
		low_edge = max_p[best_axis]
		high_edge = min_p[best_axis]

	var side_axis := 2 if best_axis == 0 else 0

	var side_min := min_p[side_axis]
	var side_max := max_p[side_axis]

	## Sáu đỉnh tạo thành một hình nêm kín:
	## - đáy nằm ở min_p.y
	## - mặt dốc nối chân thang với đỉnh thang
	## - mặt bên phủ hết chiều rộng model.
	var points := PackedVector3Array()

	for side: float in [side_min, side_max]:
		## Chân thang.
		points.append(
			_point(
				best_axis,
				low_edge,
				side_axis,
				side,
				min_p.y
			)
		)

		## Đáy phía đỉnh thang.
		points.append(
			_point(
				best_axis,
				high_edge,
				side_axis,
				side,
				min_p.y
			)
		)

		## Đỉnh phía trên của ramp.
		points.append(
			_point(
				best_axis,
				high_edge,
				side_axis,
				side,
				max_p.y
			)
		)

	var shape := ConvexPolygonShape3D.new()
	shape.points = points

	var axis_name := "X" if best_axis == 0 else "Z"
	var slope_angle := rad_to_deg(
		atan2(box.size.y, box.size[best_axis])
	)

	print(
		"  Hướng leo: %s | Tương quan: %.2f | Góc ramp ước tính: %.1f°"
		% [axis_name, best_correlation, slope_angle]
	)

	return shape


func _point(
	axis: int,
	axis_value: float,
	side_axis: int,
	side_value: float,
	y: float
) -> Vector3:
	var point := Vector3(0.0, y, 0.0)
	point[axis] = axis_value
	point[side_axis] = side_value
	return point


## ============================================================
## ĐỌC VÀ GỘP MESH TỪ GLB
## ============================================================

func _load_mesh(path: String) -> Mesh:
	var packed_scene := load(path) as PackedScene

	if packed_scene == null:
		push_warning("Không load được PackedScene: %s" % path)
		return null

	var source_root := packed_scene.instantiate()
	var combined := ArrayMesh.new()

	## Duyệt toàn bộ cây node thay vì chỉ lấy MeshInstance3D đầu tiên.
	_append_meshes(source_root, source_root, combined)

	source_root.free()

	if combined.get_surface_count() == 0:
		return null

	return combined


func _append_meshes(
	node: Node,
	source_root: Node,
	output: ArrayMesh
) -> void:
	if node is MeshInstance3D:
		var mesh_instance := node as MeshInstance3D

		if mesh_instance.mesh != null:
			var mesh_transform := _transform_to_root(
				source_root,
				mesh_instance
			)

			_append_mesh_surfaces(
				mesh_instance.mesh,
				mesh_transform,
				output,
				mesh_instance
			)

	for child: Node in node.get_children():
		_append_meshes(child, source_root, output)


## Tính transform từ hệ tọa độ của mesh về hệ tọa độ root.
## Các transform sẽ được bake vào vertex trước khi tính collider.
func _transform_to_root(
	source_root: Node,
	target: Node
) -> Transform3D:
	var chain: Array[Node3D] = []
	var current: Node = target

	while current != null:
		if current is Node3D:
			chain.append(current as Node3D)

		if current == source_root:
			break

		current = current.get_parent()

	var result := Transform3D.IDENTITY

	for i: int in range(chain.size() - 1, -1, -1):
		result = result * chain[i].transform

	return result


## Sao chép từng surface sang ArrayMesh mới và áp dụng transform
## cho vertex, normal và tangent.
func _append_mesh_surfaces(
	source_mesh: Mesh,
	mesh_transform: Transform3D,
	output: ArrayMesh,
	source_instance: MeshInstance3D
) -> void:
	for surface_index: int in range(source_mesh.get_surface_count()):
		## Mesh dùng cho collider này cần là tam giác.
		if source_mesh.surface_get_primitive_type(surface_index) \
				!= Mesh.PRIMITIVE_TRIANGLES:
			continue

		var arrays: Array = source_mesh.surface_get_arrays(surface_index)

		if arrays.is_empty():
			continue

		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]

		if vertices.is_empty():
			continue

		## Bake vị trí vertex.
		for i: int in range(vertices.size()):
			vertices[i] = mesh_transform * vertices[i]

		arrays[Mesh.ARRAY_VERTEX] = vertices

		## Chuyển đổi normal bằng inverse-transpose để xử lý scale.
		var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]

		if not normals.is_empty():
			var normal_basis := mesh_transform.basis

			if absf(mesh_transform.basis.determinant()) > 0.000001:
				normal_basis = (
					mesh_transform.basis.inverse().transposed()
				)

			for i: int in range(normals.size()):
				normals[i] = (
					normal_basis * normals[i]
				).normalized()

			arrays[Mesh.ARRAY_NORMAL] = normals

		## Chuyển đổi tangent nếu surface có dữ liệu tangent.
		var tangents: PackedFloat32Array = arrays[Mesh.ARRAY_TANGENT]

		if not tangents.is_empty():
			for i: int in range(0, tangents.size() - 3, 4):
				var tangent := Vector3(
					tangents[i],
					tangents[i + 1],
					tangents[i + 2]
				)

				tangent = (
					mesh_transform.basis * tangent
				).normalized()

				tangents[i] = tangent.x
				tangents[i + 1] = tangent.y
				tangents[i + 2] = tangent.z

			arrays[Mesh.ARRAY_TANGENT] = tangents

		## Thêm surface mới.
		var new_surface_index := output.get_surface_count()

		output.add_surface_from_arrays(
			Mesh.PRIMITIVE_TRIANGLES,
			arrays
		)

		## Ưu tiên material override của MeshInstance3D.
		var material: Material = source_instance.material_override

		if material == null:
			material = source_instance.get_surface_override_material(
				surface_index
			)

		if material == null:
			material = source_mesh.surface_get_material(surface_index)

		if material != null:
			output.surface_set_material(new_surface_index, material)
