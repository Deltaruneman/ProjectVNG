extends Area3D
class_name SkillPointPickup

## A persistent, one point collectible. Give every placed instance a unique id in the Inspector.
@export var pickup_id := ""
@export var points := 1

var _collected := false

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	if pickup_id != "" and GameManager.collected_skill_points.has(pickup_id):
		queue_free()


func _on_area_entered(area: Area3D) -> void:
	var actor: Node = area
	while actor != null and not actor.is_in_group("player"):
		actor = actor.get_parent()
	if _collected or actor == null:
		return
	_collected = true
	for index in points:
		GameManager.award_skill_point("%s:%d" % [pickup_id, index] if pickup_id != "" else "")
	queue_free()
