@tool

extends Node3D

@export var source_folder: String = "res://Medieval Village MegaKit[Standard]/Medieval Village MegaKit[Standard]/glTF"
@export var output_mesh_library_path: String = "res://assets/mv_mesh_library.tres"
@export var generate_library: bool = false:
	set(value):
		if value:
			_build_mesh_library()

func _build_mesh_library() -> void:
	var dir = DirAccess.open(source_folder)
	if not dir:
		print("Không thể mở thư mục: ", source_folder)
		return
		
	var mesh_lib = MeshLibrary.new()
	dir.list_dir_begin()
	var file_name = dir.get_next()
	var id_counter = 0
	
	while file_name != "":
		if not dir.current_is_dir() and (file_name.ends_with(".gltf") or file_name.ends_with(".glb")):
			var file_path = source_folder + "/" + file_name
			var scene = load(file_path) as PackedScene
			if scene:
				var instance = scene.instantiate()
				# Tìm kiếm tất cả các MeshInstance3D bên trong file gltf
				_extract_meshes(instance, mesh_lib, id_counter, file_name.get_basename())
				instance.queue_free()
		file_name = dir.get_next()
		
	# Lưu thành file MeshLibrary (.tres)
	ResourceSaver.save(mesh_lib, output_mesh_library_path)
	print("Đã tạo thành công MeshLibrary tại: ", output_mesh_library_path)

func _extract_meshes(node: Node, mesh_lib: MeshLibrary, id_counter: int, item_name: String):
	if node is MeshInstance3D and node.mesh:
		mesh_lib.create_item(id_counter)
		mesh_lib.set_item_name(id_counter, item_name)
		mesh_lib.set_item_mesh(id_counter, node.mesh)
		
		# (Tùy chọn) Tự động tạo Collision Shape cho GridMap từ Mesh
		var shape = node.mesh.create_convex_shape()
		if shape:
			mesh_lib.set_item_shapes(id_counter, [shape])
			
		id_counter += 1
		
	for child in node.get_children():
		_extract_meshes(child, mesh_lib, id_counter, item_name)
