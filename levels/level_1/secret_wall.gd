extends Node3D
## The authored GridMap remains the solid wall until repeated player hits break it.
const OPEN_FLAG := "b1_secret_wall_broken"
@export var hits_required := 5
var hits := 0
var _cooldown := 0.0
var _broken := false
@onready var _hurt: HurtArea3D = $HurtArea3D

func _ready() -> void:
	_hurt.hurt.connect(_on_hurt)
	if GameManager.flags.get(OPEN_FLAG, false):
		_break_wall()

func _physics_process(delta: float) -> void:
	_cooldown = maxf(0.0, _cooldown - delta)

func _on_hurt(_direction: Vector3, damage: float) -> void:
	if _broken or _cooldown > 0.0 or damage <= 0 or not _hurt.attacker is Player:
		return
	_cooldown = 0.18
	hits += 1
	if hits >= hits_required:
		GameManager.flags[OPEN_FLAG] = true
		GameManager.save_game()
		_break_wall.call_deferred()
	else:
		var wall := get_node_or_null("B1_5Side") as Node3D
		if wall != null:
			var tween := create_tween()
			tween.tween_property(wall, "position:x", 0.06, 0.05)
			tween.tween_property(wall, "position:x", 0.0, 0.08)

func _break_wall() -> void:
	if _broken:
		return
	_broken = true
	var wall := get_node_or_null("B1_5Side") as GridMap
	if wall != null:
		# Clear actual cells, keeping the referenced GridMap valid for existing pathfinders.
		wall.clear()
	_hurt.set_deferred("collision_layer", 0)
	for finder: Node in get_tree().get_nodes_in_group("pathfinder"):
		if get_parent().get_parent().is_ancestor_of(finder):
			finder._astar.clear()
			finder._ids.clear()
			finder._built = false
