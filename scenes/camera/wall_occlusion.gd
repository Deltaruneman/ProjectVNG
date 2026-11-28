extends Node
## Camera-local wall presentation. Physics, GridMap cells and shared resources stay intact.
const WALL_ALPHA := 0.22
const FADE_SPEED := 8.0
const RESTORE_SPEED := 5.0
var rig: Node3D
var _grids: Dictionary = {}
var _meshes: Dictionary = {}
var _scan_timer := 0.0

func _ready() -> void:
	process_physics_priority = 110

func _physics_process(delta: float) -> void:
	if not is_instance_valid(rig) or not is_instance_valid(rig.target):
		return
	if not rig.is_physics_processing() or not rig.camera.is_current():
		restore()
		return
	if get_tree().paused:
		return
	_scan_timer -= delta
	if _scan_timer <= 0.0:
		_scan_timer = 0.25
		_scan()
	var camera: Camera3D = rig.camera
	var target: Node3D = rig.target
	var anchors: Array[Vector3] = [target.global_position + Vector3.UP * 0.35,
		target.global_position + Vector3.UP * 1.15]
	var sprite := target.get_node_or_null("Sprite3D") as Sprite3D
	anchors.append(sprite.global_position + camera.global_basis.y * 1.6 if sprite else target.global_position + Vector3.UP * 2.0)
	# Include sprite edges so a side wall cannot cover half the body unnoticed.
	var edge := camera.global_basis.x * 0.85
	anchors.append(target.global_position + Vector3.UP * 1.15 + edge)
	anchors.append(target.global_position + Vector3.UP * 1.15 - edge)
	for map in _grids.keys():
		if not is_instance_valid(map):
			var stale: Dictionary = _grids[map]
			if is_instance_valid(stale.visuals): stale.visuals.queue_free()
			_grids.erase(map)
			continue
		_update_grid(map, camera.global_position, anchors, delta)
	for mesh in _meshes.keys():
		if not is_instance_valid(mesh):
			_meshes.erase(mesh)
			continue
		var entry: Dictionary = _meshes[mesh]
		var wanted: bool = mesh.is_visible_in_tree() and _blocks(mesh.global_transform, mesh.get_aabb(), camera.global_position, anchors)
		entry.blend = move_toward(float(entry.blend), 1.0 if wanted else 0.0, delta * (FADE_SPEED if wanted else RESTORE_SPEED))
		_apply_alpha(mesh, entry, entry.blend)

func _scan() -> void:
	var root := rig.get_parent()
	for candidate: Node in root.find_children("*", "GridMap", true, false):
		var map := candidate as GridMap
		if map == null:
			continue
		if not _can_replace_grid(map):
			if _grids.has(map):
				var state: Dictionary = _grids[map]
				_restore_grid(map, state)
				if is_instance_valid(state.visuals): state.visuals.queue_free()
				_grids.erase(map)
			continue
		if not _grids.has(map):
			_grids[map] = {"signature":0, "records":[], "visuals":null, "active":false, "visible":map.visible, "poll":0.0}
	for mesh: MeshInstance3D in root.find_children("*", "MeshInstance3D", true, false):
		if _meshes.has(mesh) or mesh.has_meta("camera_wall_visual") or mesh.mesh == null:
			continue
		# Solid mesh walls/pillars; do not register actors, particles or decorative flames.
		if mesh.get_parent() is StaticBody3D or not mesh.find_children("*", "StaticBody3D", true, false).is_empty():
			_meshes[mesh] = _material_entry(mesh)

func _can_replace_grid(map: GridMap) -> bool:
	# GridMap has no self-only rendering visibility switch: hiding a container
	# also hides every child Floor/Wall. Replace only independent leaf visuals.
	if "floor" in str(map.name).to_lower():
		return false
	return map.find_children("*", "GridMap", true, false).is_empty() \
		and map.find_children("*", "VisualInstance3D", true, false).is_empty()

func _blocks(transform: Transform3D, bounds: AABB, origin: Vector3, anchors: Array[Vector3]) -> bool:
	var world_bounds := transform * bounds
	var feet_y: float = rig.target.global_position.y
	if world_bounds.size.y < 0.7 and world_bounds.end.y <= feet_y + 0.15:
		return false # Supporting floors remain opaque; overhead tiles can obscure Player.
	var intersects := false
	for point: Vector3 in anchors:
		if world_bounds.grow(0.2).intersects_segment(origin, point) != null:
			intersects = true
			break
	if not intersects:
		return false
	var inverse := transform.affine_inverse()
	var local_origin := inverse * origin
	for point: Vector3 in anchors:
		if bounds.grow(0.12).intersects_segment(local_origin, inverse * point) != null:
			return true
	return false

func _update_grid(map: GridMap, origin: Vector3, anchors: Array[Vector3], delta: float) -> void:
	var state: Dictionary = _grids[map]
	state.poll -= delta
	var cells: Array[Vector3i] = []
	var signature: int = state.signature
	if state.poll <= 0.0:
		state.poll = 0.1
		cells = map.get_used_cells()
		signature = hash(cells)
	if state.signature != signature:
		_restore_grid(map, state)
		if is_instance_valid(state.visuals):
			state.visuals.queue_free()
		state.visuals = null
		state.signature = signature
		state.records = []
		if map.mesh_library != null:
			var item_ids := map.mesh_library.get_item_list()
			for cell: Vector3i in cells:
				var item := map.get_cell_item(cell)
				if not item_ids.has(item):
					continue
				var mesh := map.mesh_library.get_item_mesh(item)
				if mesh == null:
					continue
				var local := Transform3D(map.get_cell_item_basis(cell).scaled(Vector3.ONE * map.cell_scale), map.map_to_local(cell)) * map.mesh_library.get_item_mesh_transform(item)
				state.records.append({"cell":cell,"mesh":mesh,"local":local,"blend":0.0,"node":null,"material":{}})
	var parent_visible := map.get_parent() is Node3D and (map.get_parent() as Node3D).is_visible_in_tree()
	var visible: bool = (bool(state.visible) and parent_visible) if state.active else map.is_visible_in_tree()
	var active := false
	for record: Dictionary in state.records:
		var wanted := visible and _blocks(map.global_transform * record.local, record.mesh.get_aabb(), origin, anchors)
		record.blend = move_toward(float(record.blend), 1.0 if wanted else 0.0, delta * (FADE_SPEED if wanted else RESTORE_SPEED))
		active = active or record.blend > 0.0
	if active:
		if not is_instance_valid(state.visuals):
			_build_visuals(map, state)
		if not state.active:
			state.visible = map.visible
			map.visible = false # Rendering only; source cells and collision are untouched.
			state.active = true
		state.visuals.transform = map.transform
		state.visuals.visible = bool(state.visible)
		for record: Dictionary in state.records:
			if record.blend > 0.0 or not record.material.is_empty():
				if record.material.is_empty():
					record.material = _material_entry(record.node)
				_apply_alpha(record.node, record.material, record.blend)
	else:
		_restore_grid(map, state)

func _build_visuals(map: GridMap, state: Dictionary) -> void:
	var visuals := Node3D.new()
	visuals.name = "_CameraWallVisuals"
	map.get_parent().add_child(visuals)
	visuals.transform = map.transform
	state.visuals = visuals
	for record: Dictionary in state.records:
		var node := MeshInstance3D.new()
		node.set_meta("camera_wall_visual", true)
		node.mesh = record.mesh
		node.transform = record.local
		visuals.add_child(node)
		record.node = node

func _material_entry(mesh: MeshInstance3D) -> Dictionary:
	var originals: Array = []
	var copies: Array = []
	for surface in mesh.mesh.get_surface_count():
		originals.append(mesh.get_surface_override_material(surface))
		var material := mesh.get_active_material(surface)
		var copy: BaseMaterial3D
		if material is BaseMaterial3D:
			copy = material.duplicate() as BaseMaterial3D
		elif material == null:
			copy = StandardMaterial3D.new()
		else:
			# Preserve custom shader materials rather than replacing their appearance.
			copies.append(null)
			continue
		copy.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		copies.append({"material":copy,"alpha":copy.albedo_color.a})
	return {"blend":0.0,"override":mesh.material_override,"surfaces":originals,"copies":copies,"shadow":mesh.cast_shadow}

func _apply_alpha(mesh: MeshInstance3D, entry: Dictionary, blend: float) -> void:
	if is_equal_approx(float(entry.get("applied_blend", -1.0)), blend):
		return
	entry.applied_blend = blend
	if blend <= 0.0:
		mesh.material_override = entry.override
		mesh.cast_shadow = entry.shadow
		for surface in entry.surfaces.size():
			mesh.set_surface_override_material(surface, entry.surfaces[surface])
		return
	mesh.material_override = null
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for surface in entry.copies.size():
		var copy: Variant = entry.copies[surface]
		if copy == null:
			continue
		var material: BaseMaterial3D = copy.material
		var color := material.albedo_color
		color.a = float(copy.alpha) * lerpf(1.0, WALL_ALPHA, blend)
		material.albedo_color = color
		mesh.set_surface_override_material(surface, material)

func _restore_grid(map: GridMap, state: Dictionary) -> void:
	if state.active:
		map.visible = bool(state.visible)
		state.active = false
	if is_instance_valid(state.visuals):
		state.visuals.visible = false

func restore() -> void:
	for map in _grids:
		if is_instance_valid(map):
			var state: Dictionary = _grids[map]
			_restore_grid(map, state)
			for record: Dictionary in state.records:
				record.blend = 0.0
	for mesh in _meshes:
		if is_instance_valid(mesh):
			var entry: Dictionary = _meshes[mesh]
			entry.blend = 0.0
			_apply_alpha(mesh, entry, 0.0)

func _exit_tree() -> void:
	restore()
	for state: Dictionary in _grids.values():
		if is_instance_valid(state.visuals):
			state.visuals.queue_free()
