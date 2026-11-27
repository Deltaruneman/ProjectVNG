extends Node3D

## Tầng F2 của castle: khi mọi EnemyZone (có clear_kills > 0) trong EnemyZones đều đã dọn xong thì
## mở khóa cờ `clear_flag` — Door_to_next có unlock_flag trùng tên sẽ mở được.
## Cùng cách làm với basement_b2_progress.gd.

@export var clear_flag := "castle_f2_cleared"

@onready var _zones: Node3D = $EnemyZones
var _clear_zones: Array[EnemyZone] = []


func _ready() -> void:
	if GameManager.is_door_unlocked(clear_flag):
		for child: Node in _zones.get_children():
			var zone := child as EnemyZone
			if zone != null and zone.enemy_scene != null:
				_stop_zone_timer(zone)
		return

	for child: Node in _zones.get_children():
		var zone := child as EnemyZone
		if zone == null or zone.enemy_scene == null:
			continue
		_clear_zones.append(zone)

	if _clear_zones.is_empty():
		push_warning("Castle F2 has no configured enemy zones; the exit stays locked.")
		return
	for zone: EnemyZone in _clear_zones:
		if zone.clear_kills <= 0:
			push_warning("Castle F2 needs a finite clear_kills value on %s." % zone.name)
			_clear_zones.clear()
			return
		zone.cleared.connect(_check_all_zones_cleared)
	_check_all_zones_cleared()


func _check_all_zones_cleared() -> void:
	for zone: EnemyZone in _clear_zones:
		if not is_instance_valid(zone) or not zone.is_cleared():
			return
	GameManager.unlock_door(clear_flag)


func _stop_zone_timer(zone: EnemyZone) -> void:
	var timer := zone.get_node_or_null("Timer") as Timer
	if timer != null:
		timer.stop()
