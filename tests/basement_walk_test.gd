extends SceneTree

## Cho player tự đi trong B1 của basement_full.tscn bằng input giả lập (headless, nhanh):
##   godot --headless --path . --fixed-fps 60 --script res://tests/basement_walk_test.gd
## Mỗi chặng: giữ phím hướng về điểm đích (đi chéo khi cần). "KẸT" = 0.5 s không nhích được 5 cm.
## Chặng "ĐẨY" đẩy vào vách 2 s rồi kiểm tra player không lọt ra ngoài.

const SCENE := "res://levels/level_1/basement_full.tscn"

## [tên, điểm đích (x, z) theo mét, loại]. Loại "walk": phải tới nơi; "push": đẩy vào vách.
const LEGS := [
	["ra khỏi hầm", Vector2(3, 14), "walk"],
	["dọc lối đi chính sang phải", Vector2(33, 14), "walk"],
	["chéo về trước-trái", Vector2(13, 25), "walk"],
	["chéo lên sau-phải", Vector2(30, 3), "walk"],
	["tới chỗ đặt thang (x=8, sát vách sau)", Vector2(17, 2), "walk"],
	["chéo xuống chân bậc High Ground", Vector2(6, 12), "walk"],
	["leo bậc lên High Ground", Vector2(6, 4), "walk"],
	["đi trên High Ground", Vector2(1.5, 1.5), "walk"],
	["xuống bậc", Vector2(7, 13), "walk"],
	["đẩy vào vách trước", Vector2(20, 40), "push"],
	["đẩy vào vách chung x=18 (chỗ cửa ẩn)", Vector2(60, 14), "push"],
	["đẩy vào vách chung x=18 (z=4)", Vector2(60, 8), "push"],
	["về hầm", Vector2(-3, 14), "walk"],
	["đẩy vào cuối hầm", Vector2(-20, 14), "push"],
]

var _fails := 0


func _initialize() -> void:
	var stage: Node3D = (load(SCENE) as PackedScene).instantiate()
	root.add_child.call_deferred(stage)
	await process_frame
	current_scene = stage
	var player: CharacterBody3D = stage.get_node("Player")
	for i in 30:
		await physics_frame
	print("spawn: %s  on_floor=%s  tầng=%d" % [_fmt(player.global_position), player.is_on_floor(),
		stage.current_level()])
	_check(player.global_position.distance_to(stage.get_node("Spawn").global_position) < 0.6,
		"player xuất hiện ở Spawn (trong hầm bên trái B1)")
	var max_y := -INF
	var min_y := INF
	for leg in LEGS:
		var target: Vector2 = leg[1]
		var result := await _drive(player, target, leg[2] == "push")
		var pos := player.global_position
		max_y = maxf(max_y, pos.y)
		min_y = minf(min_y, pos.y)
		if leg[2] == "walk":
			_check(result == "ok", "%s → %s (y=%.2f)" % [leg[0], result, pos.y])
		else:
			# Mặt vách: cuối hầm x = −7, vách chung x = 37, vách trước z = 29 (tâm ô vành).
			var inside := pos.x > -7.0 and pos.x < 37.0 and pos.z > -1.0 and pos.z < 29.0
			_check(inside, "%s: dừng ở %s" % [leg[0], _fmt(pos)])
	_check(min_y > 0.5, "không rơi khỏi sàn (y thấp nhất %.2f)" % min_y)
	# Ẩn tầng (basement_floor_visibility.gd): dịch player sang từng tầng rồi đọc visible.
	var cases := [["B1", Vector3(20, 1.2, 12), {"B1": true, "B1_5": false, "B2": false, "B3": false}],
		["B1 trên High Ground", Vector3(5, 3.2, 4), {"B1": true, "B2": false}],
		["B1.5", Vector3(46, 1.2, 14), {"B1": true, "B1_5": true, "B2": false}],
		["B2", Vector3(30, 7.2, 14), {"B1": true, "B1_5": false, "B2": true, "B3": false}],
		["B3", Vector3(38, 13.2, 14), {"B2": true, "B3": true, "GroundExit": false}]]
	for c in cases:
		player.global_position = c[1]
		player.velocity = Vector3.ZERO
		await process_frame
		await process_frame
		var wrong := []
		for floor_name in c[2]:
			if stage.get_node(floor_name).visible != c[2][floor_name]:
				wrong.append(floor_name)
		_check(wrong.is_empty(), "ẩn tầng khi đứng ở %s%s" % [c[0], "" if wrong.is_empty() else " — sai: %s" % [wrong]])
	print("KET QUA: %s (%d lỗi)" % ["QUA" if _fails == 0 else "TRUOT", _fails])
	quit(1 if _fails > 0 else 0)


func _drive(player: CharacterBody3D, target: Vector2, push: bool) -> String:
	var last := Vector2(player.global_position.x, player.global_position.z)
	var still := 0
	var frames := 360 if push else 900
	var result := "hết giờ"
	for f in frames:
		var here := Vector2(player.global_position.x, player.global_position.z)
		var to := target - here
		if not push and to.length() < 0.35:
			result = "ok"
			break
		_press(to.normalized())
		await physics_frame
		if f % 30 == 29:
			if here.distance_to(last) < 0.05 and not push:
				still += 1
				if still >= 1:
					result = "KẸT tại %s" % _fmt(player.global_position)
					break
			else:
				still = 0
			last = here
	_press(Vector2.ZERO)
	for i in 10:
		await physics_frame
	return result


func _press(dir: Vector2) -> void:
	for pair in [["left", -dir.x], ["right", dir.x], ["up", -dir.y], ["down", dir.y]]:
		if pair[1] > 0.01:
			Input.action_press(pair[0], pair[1])
		else:
			Input.action_release(pair[0])


func _fmt(v: Vector3) -> String:
	return "(%.2f, %.2f, %.2f)" % [v.x, v.y, v.z]


func _check(ok: bool, label: String) -> void:
	print(("  [OK]   " if ok else "  [LỖI] ") + label)
	if not ok:
		_fails += 1
