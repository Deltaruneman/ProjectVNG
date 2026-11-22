extends SceneTree

## Chụp ảnh basement_full.tscn (cần GPU/OpenGL, không chạy với --headless):
##   godot --path . --rendering-driver opengl3 --resolution 1600x900 --script res://tests/basement_screenshots.gd
## Ảnh lưu vào user://basement_shots/ (in đường dẫn ra Output).

const SCENE := "res://levels/level_1/basement_full.tscn"
const FLOORS := ["B1", "B1_5", "B2", "B3", "GroundExit"]

var _stage: Node3D
var _cam: Camera3D
var _dir := "user://basement_shots"


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(_dir)
	_stage = (load(SCENE) as PackedScene).instantiate()
	root.add_child.call_deferred(_stage)
	await process_frame
	current_scene = _stage
	_stage.set_process(false)    # tự bật/tắt tầng ở đây
	_stage.get_node("CameraRig").set_process(false)
	_cam = Camera3D.new()
	root.add_child(_cam)
	_cam.make_current()

	# 1. Nhìn từ trên xuống từng tầng (chỉ hiện tầng đó), ánh sáng thật và bản sáng để đọc bố cục.
	for bright in [false, true]:
		_set_bright(bright)
		for name in FLOORS:
			_show_only([name, "B1"] if name == "B1_5" else [name])
			var level: int = _stage.get_node(name).get_meta("floor_level")
			_top_down(Vector3(26, level * 6 + 1, 14), 66.0 if name != "GroundExit" else 20.0)
			await _shot("top_%s%s" % [name, "_bright" if bright else ""])

	# 2. Mặt cắt ngang cả khu: camera trực giao nhìn chéo xuống 25° từ phía trước; near plane cắt bỏ
	#    phần trước mặt phẳng cắt (qua z = cut ở độ cao giữa khu) để thấy các tầng chồng nhau.
	_set_bright(true)
	_show_only(FLOORS)
	for cut in [14.0, 5.0]:
		_cam.projection = Camera3D.PROJECTION_ORTHOGONAL
		_cam.size = 44.0
		_cam.far = 300.0
		var pitch := deg_to_rad(-25.0)
		var basis := Basis(Vector3.RIGHT, pitch)
		var pivot := Vector3(25, 9, cut)
		var back := 60.0
		_cam.global_transform = Transform3D(basis, pivot + basis.z * back)
		_cam.near = back
		await _shot("section_z%d" % int(cut))

	# 3. Góc camera trong game, ánh sáng thật.
	_set_bright(false)
	var spots := {"game_B1_spawn": [Vector3(4, 1.2, 14), ["B1"]],
		"game_B1_center": [Vector3(20, 1.2, 12), ["B1"]],
		"game_B2": [Vector3(20, 7.2, 10), ["B1", "B2"]],
		"game_B3": [Vector3(38, 13.2, 14), ["B1", "B2", "B3"]],
		"game_B1_5": [Vector3(46, 1.2, 14), ["B1", "B1_5"]]}
	for key in spots:
		_show_only(spots[key][1])
		var target: Vector3 = spots[key][0]
		_cam.projection = Camera3D.PROJECTION_PERSPECTIVE
		_cam.fov = 30.0
		_cam.near = 0.05
		_cam.global_position = target + Vector3(0, 30, 30)
		_cam.look_at(target)
		_stage.get_node("Player").global_position = target
		await _shot(key)
	print("ẢNH: ", ProjectSettings.globalize_path(_dir))
	quit()


func _top_down(center: Vector3, size: float) -> void:
	_cam.projection = Camera3D.PROJECTION_ORTHOGONAL
	_cam.size = size * 9.0 / 16.0 * 1.0
	_cam.size = size * 0.6
	_cam.near = 0.05
	_cam.far = 5.5    # chỉ thấy tầng đó và vách của nó (đỉnh vách ≈ +4 m)
	_cam.global_transform = Transform3D(Basis.IDENTITY, center + Vector3(0, 5.2, 0)) \
		.looking_at(center, Vector3(0, 0, -1))
	_cam.far = 9.0


func _show_only(names: Array) -> void:
	for name in FLOORS:
		_stage.get_node(name).visible = names.has(name)


func _set_bright(on: bool) -> void:
	var env: Environment = _stage.get_node("WorldEnvironment").environment
	env.ambient_light_energy = 1.4 if on else 0.35


func _shot(file: String) -> void:
	for i in 6:
		await process_frame
	await RenderingServer.frame_post_draw
	var image := root.get_texture().get_image()
	image.save_png("%s/%s.png" % [_dir, file])
