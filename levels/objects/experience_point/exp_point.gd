extends Area3D
class_name ExpPointPickup

## Existing point/drop exports are reward units; each now contains 20 EXP.
@export var pickup_id := ""
@export var points := 1
@export var attraction_delay := 0.2
@export var flight_speed := 5.0
@export var acceleration := 22.0

var _collected := false
var _age := 0.0
var _speed := 0.0
var _target: BaseCharacter
var _orb: Node3D


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	_orb = get_node_or_null("Orb") as Node3D
	if pickup_id != "" and GameManager.collected_exp_points.has(_source_id(points - 1)):
		queue_free()


func _physics_process(delta: float) -> void:
	if _collected:
		return
	_age += delta
	if _orb != null:
		_orb.position = Vector3(0.0, 0.8 + sin(_age * 5.0) * 0.07, 0.0)
	if not is_instance_valid(_target) or not _target.is_inside_tree():
		_target = get_tree().get_first_node_in_group("player") as BaseCharacter
	if _target == null or _target.health <= 0 or GameManager.is_changing() or _age < attraction_delay:
		return
	# No world collision: EXP flies back from enemies across stairs and scenery.
	_speed = minf(30.0, maxf(flight_speed, _speed) + acceleration * delta)
	global_position = global_position.move_toward(_target.global_position, _speed * delta)
	if global_position.distance_to(_target.global_position) <= 0.45:
		_collect(_target)


func _on_area_entered(area: Area3D) -> void:
	var actor: Node = area
	while actor != null and not actor.is_in_group("player"):
		actor = actor.get_parent()
	_collect(actor as BaseCharacter)


func _collect(player: BaseCharacter) -> void:
	if _collected or player == null or player.health <= 0 or GameManager.is_changing():
		return
	_collected = true
	for index in points:
		GameManager.award_experience(GameManager.PROGRESSION.EXP_PER_POINT, _source_id(index))
	queue_free()


func _source_id(index: int) -> String:
	return "%s:%d" % [pickup_id, index] if pickup_id != "" else ""
