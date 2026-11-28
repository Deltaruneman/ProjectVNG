extends Node
func _ready() -> void:
	call_deferred("_run")
func _run() -> void:
	var scene := load("res://scenes/map/torches/torch.tscn") as PackedScene
	if scene == null:
		push_error("Torch PackedScene failed to load")
		get_tree().quit(1)
		return
	var torch := scene.instantiate()
	add_child(torch)
	var flame := torch.get_node_or_null("Flame") as MeshInstance3D
	if flame == null:
		var meshes := torch.find_children("*", "MeshInstance3D", true, false)
		if not meshes.is_empty(): flame = meshes[0] as MeshInstance3D
	if flame == null or flame.mesh == null:
		push_error("Torch Flame mesh did not load")
		get_tree().quit(1)
		return
	print("TORCH_MESH_SURFACES ",flame.mesh.get_surface_count())
	var stage_scene := load("res://levels/level_1/basement_full.tscn") as PackedScene
	if stage_scene == null:
		push_error("Basementfull failed to load")
		get_tree().quit(1)
		return
	var stage := stage_scene.instantiate()
	add_child(stage)
	var placed := stage.get_node_or_null("B1/Torches/Torch")
	if placed == null:
		push_error("Basementfull torch instance missing")
		get_tree().quit(1)
		return
	await get_tree().process_frame
	await get_tree().process_frame
	print("TORCH_RESOURCE_RESULT PASS")
	get_tree().quit(0)
