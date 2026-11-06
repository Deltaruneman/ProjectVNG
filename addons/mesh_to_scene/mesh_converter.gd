@tool
class_name MeshToSceneConverter
extends RefCounted

## Pure conversion logic, with no dependency on the editor UI.
##
## Given a [MeshToSceneOptions], it scans a folder for imported mesh files,
## turns every MeshInstance3D it finds into its own scene (with optional
## collision), and optionally builds a MeshLibrary from all of them.
##
## The single entry point is [method convert]. Everything else is a helper.


## Runs a full conversion described by [param options].
##
## This is a coroutine: it yields a frame between files so a driving UI can
## repaint its progress bar and stay responsive. Call it with [code]await[/code].
##
## [param progress] is an optional Callable invoked as
## progress.call(done: int, total: int, message: String) so a UI can show a bar.
static func convert(options: MeshToSceneOptions, progress := Callable()) -> MeshToSceneReport:
	var report := MeshToSceneReport.new()

	var error := options.validate()
	if not error.is_empty():
		report.errors.append(error)
		return report

	var files := _gather_files(options.source_folder, options)
	if files.is_empty():
		report.warnings.append("No matching mesh files found in %s" % options.source_folder)
		return report

	var total := files.size()

	for i in files.size():
		var file_path := files[i]
		if progress.is_valid():
			progress.call(i, total, "Converting %s" % file_path.get_file())
		await _yield_frame()
		_convert_file(file_path, options, report)

	# Build the library from the scenes that were just created, so it is always a
	# faithful reflection of them (same meshes, same collision).
	if options.generate_mesh_library and not report.created_scenes.is_empty():
		await _build_mesh_library(report.created_scenes, options, report, progress)

	if progress.is_valid():
		progress.call(1, 1, "Done")
	return report


## Yields one idle frame so the caller's UI can repaint. Does nothing when no
## SceneTree is running (e.g. a headless MainLoop).
static func _yield_frame() -> void:
	var loop := Engine.get_main_loop()
	if loop is SceneTree:
		await (loop as SceneTree).process_frame


## Returns the res:// paths of the mesh files [param options] would convert.
## Public so a UI can preview the scope (file count) before running.
static func gather_files(options: MeshToSceneOptions) -> PackedStringArray:
	return _gather_files(options.source_folder, options)


## Recursively collects res:// paths of files matching the requested extensions.
static func _gather_files(folder: String, options: MeshToSceneOptions) -> PackedStringArray:
	var result: PackedStringArray = []
	var dir := DirAccess.open(folder)
	if dir == null:
		return result

	dir.list_dir_begin()
	var entry := dir.get_next()
	while entry != "":
		# Skip hidden entries (".", "..", ".import" siblings, etc.).
		if not entry.begins_with("."):
			var full := folder.path_join(entry)
			if dir.current_is_dir():
				if options.recursive:
					result.append_array(_gather_files(full, options))
			elif entry.get_extension().to_lower() in options.extensions:
				result.append(full)
		entry = dir.get_next()
	dir.list_dir_end()
	return result


## Loads one mesh file, extracts every MeshInstance3D, and saves a scene for each.
static func _convert_file(
	file_path: String,
	options: MeshToSceneOptions,
	report: MeshToSceneReport
) -> void:
	var packed := load(file_path) as PackedScene
	if packed == null:
		report.warnings.append("Could not load as a scene: %s" % file_path)
		return

	var instance := packed.instantiate()
	var mesh_nodes: Array[MeshInstance3D] = []
	_collect_mesh_instances(instance, mesh_nodes)

	if mesh_nodes.is_empty():
		report.skipped_files.append(file_path)
		instance.free()
		return

	if _has_skeleton(instance):
		report.warnings.append(
			"%s contains a skeleton/skin; meshes are exported as static geometry." % file_path.get_file()
		)

	for mesh_node in mesh_nodes:
		if mesh_node.mesh == null:
			continue
		# Bake the node's transform (the FBX/glTF axis and unit conversion) into
		# the mesh geometry, so every generated scene and MeshLibrary item can use
		# an identity transform. GridMap mishandles items whose transform carries
		# rotation plus non-uniform scale, so keeping items at identity is what
		# makes the library match the scenes.
		var xform := _transform_relative_to(mesh_node, instance)
		var baked := _bake_mesh(mesh_node.mesh, xform)
		_save_mesh_scene(baked, mesh_node.name, file_path, options, report)

	instance.free()


## Depth-first collection of every MeshInstance3D in a node tree.
static func _collect_mesh_instances(node: Node, out: Array[MeshInstance3D]) -> void:
	if node is MeshInstance3D:
		out.append(node)
	for child in node.get_children():
		_collect_mesh_instances(child, out)


## Returns the first MeshInstance3D in a tree (depth-first), or null.
static func _first_mesh_instance(node: Node) -> MeshInstance3D:
	if node is MeshInstance3D:
		return node
	for child in node.get_children():
		var found := _first_mesh_instance(child)
		if found != null:
			return found
	return null


## Returns the first CollisionShape3D in a tree (depth-first), or null.
static func _first_collision_shape(node: Node) -> CollisionShape3D:
	if node is CollisionShape3D:
		return node
	for child in node.get_children():
		var found := _first_collision_shape(child)
		if found != null:
			return found
	return null


static func _has_skeleton(node: Node) -> bool:
	if node is Skeleton3D:
		return true
	for child in node.get_children():
		if _has_skeleton(child):
			return true
	return false


## Transform of [param node] expressed relative to [param root], computed by
## walking up the parent chain (the tree is not inside the SceneTree, so
## global_transform is unavailable).
static func _transform_relative_to(node: Node3D, root: Node) -> Transform3D:
	var result := Transform3D.IDENTITY
	var current: Node = node
	while current != null and current != root:
		if current is Node3D:
			result = (current as Node3D).transform * result
		current = current.get_parent()
	return result


## Builds and saves a single scene for one mesh, and records an [Entry] for the library.
static func _save_mesh_scene(
	mesh: Mesh,
	node_name: String,
	source_file: String,
	options: MeshToSceneOptions,
	report: MeshToSceneReport
) -> void:
	var shape: Shape3D = null
	if options.add_collision:
		shape = _make_shape(mesh, options.collision_type)

	var scene_name := _sanitize(node_name)
	var root := _build_scene_tree(mesh, scene_name, shape, options)

	var out_dir := _output_dir_for(source_file, options)
	var save_error := _ensure_dir(out_dir)
	if save_error != OK:
		report.errors.append("Could not create folder %s (error %d)" % [out_dir, save_error])
		root.free()
		return

	var out_path := out_dir.path_join("%s.tscn" % scene_name)
	var existed := FileAccess.file_exists(out_path)

	var packed := PackedScene.new()
	var pack_error := packed.pack(root)
	if pack_error != OK:
		report.errors.append("Could not pack scene for %s (error %d)" % [scene_name, pack_error])
		root.free()
		return

	save_error = ResourceSaver.save(packed, out_path)
	root.free()
	if save_error != OK:
		report.errors.append("Could not save %s (error %d)" % [out_path, save_error])
		return

	report.created_scenes.append(out_path)
	if existed:
		report.overwritten.append(out_path)


## Creates the node tree for one scene according to the chosen root type.
## All non-root nodes get [param root] as their owner so PackedScene keeps them.
static func _build_scene_tree(
	mesh: Mesh,
	scene_name: String,
	shape: Shape3D,
	options: MeshToSceneOptions
) -> Node3D:
	var root: Node3D

	# The mesh geometry is already baked into world orientation, so every node
	# below keeps an identity transform.
	match options.scene_root:
		MeshToSceneOptions.SceneRoot.MESH_INSTANCE:
			var mesh_instance := MeshInstance3D.new()
			mesh_instance.mesh = mesh
			mesh_instance.name = scene_name
			if shape != null:
				var body := StaticBody3D.new()
				body.name = "StaticBody3D"
				var collision := CollisionShape3D.new()
				collision.name = "CollisionShape3D"
				collision.shape = shape
				body.add_child(collision)
				mesh_instance.add_child(body)
			root = mesh_instance

		MeshToSceneOptions.SceneRoot.STATIC_BODY:
			var body := StaticBody3D.new()
			body.name = scene_name
			var mesh_instance := MeshInstance3D.new()
			mesh_instance.name = "MeshInstance3D"
			mesh_instance.mesh = mesh
			body.add_child(mesh_instance)
			if shape != null:
				var collision := CollisionShape3D.new()
				collision.name = "CollisionShape3D"
				collision.shape = shape
				body.add_child(collision)
			root = body

	_set_owner_recursive(root, root)
	return root


static func _set_owner_recursive(node: Node, owner: Node) -> void:
	for child in node.get_children():
		child.owner = owner
		_set_owner_recursive(child, owner)


static func _make_shape(mesh: Mesh, type: MeshToSceneOptions.CollisionType) -> Shape3D:
	match type:
		MeshToSceneOptions.CollisionType.CONVEX:
			return mesh.create_convex_shape()
		_:
			return mesh.create_trimesh_shape()


## Returns a new ArrayMesh with [param xform] baked into its vertices, normals and
## tangents, so the geometry stands in world orientation at an identity transform.
## Materials are preserved. LODs/blend shapes are not carried over.
static func _bake_mesh(source: Mesh, xform: Transform3D) -> ArrayMesh:
	# Identity transform: nothing to bake, but still return a plain ArrayMesh so
	# every generated mesh is a fresh, saveable resource.
	var baked := ArrayMesh.new()

	# Normals transform by the inverse-transpose basis (handles non-uniform scale);
	# they are re-normalized afterwards.
	var normal_basis := xform.basis.inverse().transposed()
	# Flip tangent handedness when the transform mirrors the geometry.
	var flips_handedness := xform.basis.determinant() < 0.0

	for surface in source.get_surface_count():
		if source.surface_get_primitive_type(surface) != Mesh.PRIMITIVE_TRIANGLES:
			# Only triangle surfaces are expected for these assets; skip anything else.
			continue

		var arrays := source.surface_get_arrays(surface)

		var vertices: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		for i in vertices.size():
			vertices[i] = xform * vertices[i]
		arrays[Mesh.ARRAY_VERTEX] = vertices

		var normals = arrays[Mesh.ARRAY_NORMAL]
		if normals != null:
			for i in normals.size():
				normals[i] = (normal_basis * normals[i]).normalized()
			arrays[Mesh.ARRAY_NORMAL] = normals

		var tangents = arrays[Mesh.ARRAY_TANGENT]
		if tangents != null:
			# ARRAY_TANGENT packs 4 floats per vertex: xyz direction + w sign.
			for i in range(0, tangents.size(), 4):
				var t := Vector3(tangents[i], tangents[i + 1], tangents[i + 2])
				t = (xform.basis * t).normalized()
				tangents[i] = t.x
				tangents[i + 1] = t.y
				tangents[i + 2] = t.z
				if flips_handedness:
					tangents[i + 3] = -tangents[i + 3]
			arrays[Mesh.ARRAY_TANGENT] = tangents

		baked.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		var material := source.surface_get_material(surface)
		if material != null:
			baked.surface_set_material(surface, material)

	return baked


## Destination folder for a scene generated from [param source_file].
static func _output_dir_for(source_file: String, options: MeshToSceneOptions) -> String:
	if options.output_layout == MeshToSceneOptions.OutputLayout.FLATTEN:
		return options.output_folder

	# Mirror: reproduce the source file's sub-path under the output folder.
	var source_dir := source_file.get_base_dir()
	var relative := _relative_path(source_dir, options.source_folder)
	if relative.is_empty():
		return options.output_folder
	return options.output_folder.path_join(relative)


## Returns [param path] with the [param base] prefix removed (no leading slash),
## or "" when [param path] equals [param base].
static func _relative_path(path: String, base: String) -> String:
	var normalized_path := path.trim_suffix("/")
	var normalized_base := base.trim_suffix("/")
	if normalized_path == normalized_base:
		return ""
	if normalized_path.begins_with(normalized_base + "/"):
		return normalized_path.substr(normalized_base.length() + 1)
	return ""


static func _ensure_dir(path: String) -> int:
	if DirAccess.dir_exists_absolute(path):
		return OK
	return DirAccess.make_dir_recursive_absolute(path)


## Makes a string safe to use as a file name, falling back to "mesh" if empty.
static func _sanitize(name: String) -> String:
	var cleaned := name.validate_filename()
	if cleaned.is_empty():
		return "mesh"
	return cleaned


## Builds a MeshLibrary from the generated scene files and saves it, overwriting
## any existing file at the target path. Reading the scenes back guarantees the
## library matches exactly what was created.
static func _build_mesh_library(
	scene_paths: PackedStringArray,
	options: MeshToSceneOptions,
	report: MeshToSceneReport,
	progress := Callable()
) -> void:
	var library := MeshLibrary.new()
	var id := 0
	var total := scene_paths.size()
	for n in total:
		var path := scene_paths[n]
		if progress.is_valid():
			progress.call(n, total, "Building MeshLibrary %d/%d" % [n + 1, total])
		await _yield_frame()
		# Force a fresh read from disk: on a second run the scene file was just
		# overwritten, and a plain load() could return the cached older version.
		var packed := ResourceLoader.load(path, "PackedScene", ResourceLoader.CACHE_MODE_REPLACE) as PackedScene
		if packed == null:
			report.warnings.append("Could not load scene for the library: %s" % path)
			continue
		var root := packed.instantiate()

		var mesh_node := _first_mesh_instance(root)
		if mesh_node == null or mesh_node.mesh == null:
			root.free()
			continue

		library.create_item(id)
		library.set_item_name(id, root.name)
		# Geometry is baked at identity in the scenes, but transforms are read
		# relative to the root so the library stays correct regardless.
		library.set_item_mesh(id, mesh_node.mesh)
		library.set_item_mesh_transform(id, _transform_relative_to(mesh_node, root))

		var shape_node := _first_collision_shape(root)
		if shape_node != null and shape_node.shape != null:
			library.set_item_shapes(id, [shape_node.shape, _transform_relative_to(shape_node, root)])

		id += 1
		root.free()

	var dir_error := _ensure_dir(options.library_path)
	if dir_error != OK:
		report.errors.append("Could not create MeshLibrary folder %s (error %d)" % [options.library_path, dir_error])
		return

	var lib_path := options.library_path.path_join(options.library_file_name)
	var save_error := ResourceSaver.save(library, lib_path)
	if save_error != OK:
		report.errors.append("Could not save MeshLibrary %s (error %d)" % [lib_path, save_error])
		return

	report.library_path = lib_path
