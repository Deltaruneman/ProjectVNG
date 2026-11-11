extends Node3D

const B2_CLEARED_FLAG := "b2_cleared"

@onready var _zones: Node3D = $EnemyZones
var _clear_zones: Array[EnemyZone] = []


func _ready() -> void:
	if GameManager.is_door_unlocked(B2_CLEARED_FLAG):
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
		push_warning("B2 clear gate has no configured enemy zones; the exit stays locked.")
		return
	for zone: EnemyZone in _clear_zones:
		if zone.clear_kills <= 0:
			push_warning("B2 clear gate requires a finite clear_kills value on %s." % zone.name)
			_clear_zones.clear()
			return
		zone.cleared.connect(_on_zone_cleared)
	_check_all_zones_cleared()


func _on_zone_cleared() -> void:
	_check_all_zones_cleared()


func _check_all_zones_cleared() -> void:
	for zone: EnemyZone in _clear_zones:
		if not is_instance_valid(zone) or not zone.is_cleared():
			return
	GameManager.unlock_door(B2_CLEARED_FLAG)


func _stop_zone_timer(zone: EnemyZone) -> void:
	var timer := zone.get_node_or_null("Timer") as Timer
	if timer != null:
		timer.stop()
