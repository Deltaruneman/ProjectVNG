extends Area3D
class_name SkillPointPickup

## Give placed or unique rewards a stable id so their points can only be collected once.
@export var pickup_id := ""
@export var points := 1

var _collected := false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	if pickup_id != "" and GameManager.collected_skill_points.has(_source_id(points - 1)):
		queue_free()


func _on_area_entered(area: Area3D) -> void:
	var actor: Node = area
	while actor != null and not actor.is_in_group("player"):
		actor = actor.get_parent()
	var player := actor as BaseCharacter
	if _collected or player == null or player.health <= 0:
		return
	_collected = true
	for index in points:
		GameManager.award_skill_point(_source_id(index))
	queue_free()


func _source_id(index: int) -> String:
	return "%s:%d" % [pickup_id, index] if pickup_id != "" else ""
