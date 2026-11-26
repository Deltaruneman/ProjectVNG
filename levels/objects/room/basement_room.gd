class_name BasementRoom
extends Node3D

## Một phòng chiến đấu của tầng hầm.
##  - Lúc đầu: rào ở lối RA đóng, rào ở lối VÀO mở.
##  - Người chơi bước hẳn vào phòng (vùng Trigger) mà phòng chưa clear: đóng luôn rào lối vào.
##  - Diệt hết quái trong `enemies`: mở mọi rào, lưu cờ `clear_flag`, rơi rương nếu có.
## Quái nào đã chết thì không hồi lại sau khi chết/checkpoint (giống ClearPortal).
## Phòng chưa có quái nào được coi là đã clear (để thử đường đi khi chưa đặt quái).

signal entered
signal cleared

## Tên cờ duy nhất của phòng, ví dụ "bsm1_room2". Không đổi sau khi đã có save.
@export var clear_flag := ""
## Node chứa quái của phòng. Mọi con EnemyCharacter bên trong phải chết thì phòng mới clear.
@export var enemies: Node3D
@export var entry_gates: Array[RoomGate] = []
@export var exit_gates: Array[RoomGate] = []
## Cờ bật thêm khi clear (ví dụ cờ cốt truyện của cả tầng).
@export var extra_clear_flags: PackedStringArray = []
## Nơi rơi rương khi clear (để trống = không có rương).
@export var clear_reward: Marker3D
@export var clear_reward_chest_id := ""

const CHEST := preload("res://levels/objects/experience_point/floor_clear_chest.tscn")

var is_cleared := false
var _remaining: Array[EnemyCharacter] = []
var _had_enemies := false
var _locked_in := false


func _ready() -> void:
	if clear_flag.is_empty():
		push_error("%s thiếu clear_flag." % get_path())
	var trigger := get_node_or_null("Trigger") as Area3D
	if trigger != null:
		trigger.body_entered.connect(_on_body_entered)
	var restored := not clear_flag.is_empty() and GameManager.is_door_unlocked(clear_flag)
	if enemies != null:
		for child in enemies.get_children():
			if not child is EnemyCharacter:
				continue
			_had_enemies = true
			if restored or GameManager.is_door_unlocked(_defeat_key(child)):
				child.hide()
				child.process_mode = Node.PROCESS_MODE_DISABLED
				child.queue_free()
				continue
			_remaining.append(child)
			if child.has_signal("defeated"):
				child.connect("defeated", _record_defeat.bind(child))
			else:
				child.health_changed.connect(_on_health_changed.bind(child))
			child.tree_exiting.connect(_on_enemy_exiting.bind(child))
	if restored or _remaining.is_empty():
		_complete(false)
		return
	for gate in entry_gates:
		gate.open(false)
	for gate in exit_gates:
		gate.close(false)


func _on_body_entered(body: Node3D) -> void:
	if not body is Player:
		return
	entered.emit()
	if is_cleared or _locked_in:
		return
	_locked_in = true
	for gate in entry_gates:
		gate.close()


func _defeat_key(enemy: Node) -> String:
	return "encounter_defeated:%s:%s" % [clear_flag, enemies.get_path_to(enemy)]


func _on_health_changed(current: int, _maximum: int, enemy: EnemyCharacter) -> void:
	if current <= 0:
		_record_defeat(enemy)


func _on_enemy_exiting(enemy: EnemyCharacter) -> void:
	# Scene bị dỡ khi quái còn sống thì không tính là giết.
	if not enemy.is_queued_for_deletion() or enemy.health > 0:
		return
	_record_defeat(enemy)


func _record_defeat(enemy: EnemyCharacter) -> void:
	if enemy not in _remaining or enemy.health > 0:
		return
	GameManager.flags[_defeat_key(enemy)] = true
	_remaining.erase(enemy)
	if _remaining.is_empty():
		_complete(true)
	else:
		GameManager.save_game()


func _complete(animated: bool) -> void:
	if is_cleared:
		return
	is_cleared = true
	# Phòng trống (chưa đặt quái) chỉ mở rào, KHÔNG ghi cờ vào save: nếu ghi, quái đặt sau này
	# sẽ bị coi như đã chết sẵn.
	if _had_enemies and not GameManager.is_door_unlocked(clear_flag):
		if not clear_flag.is_empty():
			GameManager.flags[clear_flag] = true
		for flag in extra_clear_flags:
			GameManager.flags[flag] = true
		GameManager.save_game()
	for gate in entry_gates + exit_gates:
		gate.open(animated)
	# Rương chỉ rơi ở phòng thật sự có quái; floor_clear_chest tự nhớ đã nhặt hay chưa.
	if clear_reward != null and _had_enemies:
		var chest := CHEST.instantiate()
		if not clear_reward_chest_id.is_empty():
			chest.set("chest_id", clear_reward_chest_id)
		clear_reward.add_child.call_deferred(chest)
	cleared.emit()
