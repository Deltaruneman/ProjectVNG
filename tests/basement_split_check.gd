extends SceneTree

## Kiểm tra 3 scene tầng hầm tách từ basement_full.tscn (headless):
##   godot --headless --path . --fixed-fps 60 --script res://tests/basement_split_check.gd
## Mỗi scene: root tên "Stage" và là Stage, có đủ node bắt buộc, player rơi xuống đứng trên sàn,
## mọi điểm spawn (cửa, checkpoint) đều đứng được, cửa trỏ tới scene/cửa có thật.
## Cuối cùng đi thử chuỗi cửa qua GameManager.change_stage: B1 → B2 → B3 → B2 → B1.

const SCENES := {
	"b1": "res://levels/level_1/basement_b1.tscn",
	"b2": "res://levels/level_1/basement_b2.tscn",
	"b3": "res://levels/level_1/basement_b3.tscn",
}
## Cửa mong đợi trong từng scene: id → [scene đích, cửa đích]. "" = chưa nối (cố ý).
const DOORS := {
	"b1": {"b1_up": ["b2", "b2_down"]},
	"b2": {"b2_down": ["b1", "b1_up"], "b2_up": ["b3", "b3_down"]},
	"b3": {"b3_down": ["b2", "b2_up"], "b3_exit": ["", ""]},
}
const CHECKPOINTS := {"b1": "b1_start", "b2": "b2_start", "b3": "b3_start"}
const REQUIRED := ["WorldEnvironment", "Player", "CameraRig", "Bullets", "Hud", "Spawn"]
## Chuỗi đi thử: [cửa bấm, scene phải tới, cửa phải xuất hiện ở đó].
const CHAIN := [["b1_up", "b2", "b2_down"], ["b2_up", "b3", "b3_down"], ["b3_down", "b2", "b2_up"],
	["b2_down", "b1", "b1_up"]]
## Mặt sàn mọi tầng (sau khi hạ B2/B3 về y = 0).
const FLOOR_Y := 1.0
## Hết giờ: thoát với lỗi thay vì treo.
const TIMEOUT_FRAMES := 60 * 120

var _fails := 0
var _frames := 0


func _initialize() -> void:
	physics_frame.connect(func() -> void:
		_frames += 1
		if _frames > TIMEOUT_FRAMES:
			print("KET QUA: TRUOT (hết giờ)")
			quit(2))
	for key: String in SCENES:
		await _check_scene(key)
	await _check_chain()
	print("KET QUA: %s (%d lỗi)" % ["QUA" if _fails == 0 else "TRUOT", _fails])
	quit(1 if _fails > 0 else 0)


func _check_scene(key: String) -> void:
	print("== %s" % SCENES[key])
	var packed := load(SCENES[key]) as PackedScene
	_check(packed != null, "load được")
	if packed == null:
		return
	var stage := packed.instantiate() as Node3D
	_check(stage.name == "Stage", "root tên \"Stage\" (Node3DFactory tìm bằng find_parent)")
	_check(_is_stage(stage), "root là Stage (script kế thừa levels/stage.gd)")
	for path: String in REQUIRED:
		_check(stage.has_node(path), "có node %s" % path)
	var camera: Node = stage.get_node_or_null("CameraRig")
	_check(camera != null and camera.target == stage.get_node_or_null("Player"),
		"CameraRig.target = Player")
	_set_scene(stage)
	var player: CharacterBody3D = stage.get_node("Player")
	await _settle(player)
	_check(player.is_on_floor() and absf(player.global_position.y - FLOOR_Y) < 0.3,
		"player đứng trên sàn lúc vào scene: %s on_floor=%s" % [_fmt(player.global_position),
		player.is_on_floor()])
	if key == "b1":
		# B1 giữ nguyên Player/Spawn của basement_full (Player vốn không đứng đúng Spawn).
		print("  [--] Player B1 ở %s, Spawn ở %s (giữ như basement_full)" % [
			_fmt(player.global_position), _fmt(stage.get_node("Spawn").global_position)])
	else:
		_check(stage.get_node("Spawn").global_position.distance_to(player.global_position) < 0.6,
			"player ở gần Spawn")
	# Pathfinder dựng đồ thị không lỗi; tầng lát bằng basement_library phải có ô đi được.
	for finder: Node in stage.find_children("Pathfinder", "", true, false):
		var count: int = finder.point_count()
		var floor_name := String(finder.get_parent().name)
		if floor_name == "B1":
			# Sàn thật của B1 nằm ở World/Floor (MVP_library), không phải floor_map World.
			print("  [--] B1/Pathfinder: %d ô đi được (sàn B1 lát bằng MVP_library)" % count)
		else:
			_check(count > 0, "%s/Pathfinder: %d ô đi được" % [floor_name, count])

	var doors := _points(stage, "door")
	var expected: Dictionary = DOORS[key]
	_check(doors.size() == expected.size() and expected.keys().all(func(id: String) -> bool:
		return doors.has(id)), "đủ cửa %s (có: %s)" % [expected.keys(), doors.keys()])
	for id: String in expected:
		if not doors.has(id):
			continue
		var door: Node = doors[id]
		var want: Array = expected[id]
		if want[0] == "":
			_check(door.target_stage == "", "cửa %s chưa nối (cố ý, chờ chọn scene mặt đất)" % id)
		else:
			_check(ResourceUID.ensure_path(door.target_stage) == SCENES[want[0]]
				and door.target_door == want[1],
				"cửa %s → %s / %s" % [id, ResourceUID.ensure_path(door.target_stage), door.target_door])
			_check(_scene_has_door(SCENES[want[0]], want[1]),
				"scene đích có cửa \"%s\"" % want[1])
	var checkpoints := _points(stage, "checkpoint")
	_check(checkpoints.has(CHECKPOINTS[key]), "có checkpoint %s" % CHECKPOINTS[key])
	if checkpoints.has(CHECKPOINTS[key]):
		var spawn_pos: Vector3 = stage.get_node("Spawn").global_position
		var cp_pos: Vector3 = checkpoints[CHECKPOINTS[key]].global_position
		_check(Vector2(cp_pos.x - spawn_pos.x, cp_pos.z - spawn_pos.z).length() < 8.0,
			"checkpoint gần chỗ vào tầng (%.1f m)" % Vector2(cp_pos.x - spawn_pos.x,
			cp_pos.z - spawn_pos.z).length())

	# Đứng được ở mọi điểm spawn (Spawn của từng cửa/checkpoint).
	var all_points := doors.duplicate()
	all_points.merge(checkpoints)
	for id: String in all_points:
		var spawn: Vector3 = all_points[id].get_node("Spawn").global_position
		player.global_position = spawn
		player.velocity = Vector3.ZERO
		await _settle(player)
		var moved := Vector2(player.global_position.x - spawn.x, player.global_position.z - spawn.z)
		_check(player.is_on_floor() and absf(player.global_position.y - FLOOR_Y) < 0.3
			and moved.length() < 0.3, "đứng được ở Spawn của %s: %s" % [id,
			_fmt(player.global_position)])

	if key == "b1":
		# Phòng bí mật B1_5 vẫn ẩn/hiện theo basement_floor_visibility.gd.
		var cases := [[Vector3(20, 1.2, 12), false], [Vector3(46, 1.2, 14), true]]
		for c: Array in cases:
			player.global_position = c[0]
			player.velocity = Vector3.ZERO
			await process_frame
			await process_frame
			_check(stage.get_node("B1_5").visible == c[1], "B1_5 visible = %s khi đứng ở %s"
				% [c[1], _fmt(c[0])])
	else:
		for child: Node in stage.get_children():
			if child.has_meta("floor_level"):
				_check((child as Node3D).visible, "%s hiện (stage.gd không ẩn tầng)" % child.name)
	stage.queue_free()
	await process_frame


## Đi thử qua cửa bằng đúng đường của game: GameManager.change_stage.
func _check_chain() -> void:
	print("== chuỗi cửa B1 → B2 → B3 → B2 → B1")
	# Autoload không dùng được bằng tên trong script --script (biên dịch trước khi có autoload).
	var game_manager := root.get_node("GameManager")
	game_manager.reset()
	var b1 := (load(SCENES["b1"]) as PackedScene).instantiate()
	_set_scene(b1)
	await process_frame
	for step: Array in CHAIN:
		var stage: Node = current_scene
		var door: Node = _points(stage, "door").get(step[0])
		if door == null:
			_check(false, "không thấy cửa %s" % step[0])
			return
		game_manager.change_stage(door.target_stage, door.target_door)
		for i in 10:
			await process_frame
			if _is_stage(current_scene) and current_scene != stage and current_scene.is_node_ready():
				break
		var now: Node = current_scene if _is_stage(current_scene) else null
		_check(now != null and now.scene_file_path == SCENES[step[1]],
			"%s → %s" % [step[0], now.scene_file_path if now != null else "?"])
		if now == null:
			return
		var player: CharacterBody3D = now.get_node("Player")
		await _settle(player)
		var arrive: Node = _points(now, "door").get(step[2])
		var spawn: Vector3 = arrive.get_node("Spawn").global_position
		var moved := Vector2(player.global_position.x - spawn.x, player.global_position.z - spawn.z)
		_check(moved.length() < 0.3 and player.is_on_floor(),
			"   xuất hiện trước cửa %s, trên sàn: %s" % [step[2], _fmt(player.global_position)])


## Không viết `is Stage`: nhắc tên lớp Stage ở đây sẽ biên dịch stage.gd trước khi có autoload
## GameManager (script --script được biên dịch trước autoload) → lỗi "Identifier not found".
func _is_stage(node: Node) -> bool:
	var script := node.get_script() as Script if node != null else null
	while script != null:
		if script.resource_path == "res://levels/stage.gd":
			return true
		script = script.get_base_script()
	return false


func _set_scene(stage: Node) -> void:
	root.add_child(stage)
	current_scene = stage


func _settle(player: CharacterBody3D) -> void:
	for i in 40:
		await physics_frame


## id → node, cho các cửa ("door") hoặc checkpoint ("checkpoint") nằm trong `stage`.
func _points(stage: Node, kind: String) -> Dictionary:
	var out := {}
	for node: Node in stage.find_children("*", "", true, false):
		var script := node.get_script() as Script
		if script != null and script.resource_path.get_file() == kind + ".gd":
			out[node.id] = node
	return out


func _scene_has_door(path: String, door_id: String) -> bool:
	var state := (load(path) as PackedScene).get_state()
	for i in state.get_node_count():
		for p in state.get_node_property_count(i):
			if state.get_node_property_name(i, p) == "id" and state.get_node_property_value(i, p) == door_id:
				return true
	return false


func _check(ok: bool, what: String) -> void:
	print("  [%s] %s" % ["OK" if ok else "LỖI", what])
	if not ok:
		_fails += 1


func _fmt(v: Vector3) -> String:
	return "(%.2f, %.2f, %.2f)" % [v.x, v.y, v.z]
