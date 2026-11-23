extends Node3D

@export var id := ""
@export_file("*.tscn") var target_stage := ""
@export var target_spawn := ""
@export var clear_flag := ""
@export var required_unlock := ""
@export var encounters: Node3D
@export var clear_reward: Marker3D
@export var return_door: Node3D

const B1_CHEST := preload("res://levels/objects/experience_point/floor_clear_chest.tscn")

var _remaining: Array[EnemyCharacter] = []

@onready var _interaction := get_node_or_null("InteractiveArea3D") as InteractiveArea3D


func _ready() -> void:
	if id != "":
		add_to_group("spawn_points")
	if return_door != null and GameManager.is_door_unlocked("b2_split_cleared"):
		return_door.target_stage = "res://levels/level_1/basement_b2.tscn"
	for child in encounters.get_children():
		if child is EnemyCharacter:
			_remaining.append(child)
	if _interaction != null:
		_interaction.interacted.connect(_travel)
	if GameManager.is_door_unlocked(clear_flag):
		for enemy in _remaining:
			enemy.queue_free()
		_remaining.clear()
		_open()
		return
	if _remaining.is_empty():
		push_error("%s has no encounters configured." % get_path())
		return
	for enemy in _remaining:
		enemy.tree_exiting.connect(_on_enemy_exiting.bind(enemy))


func _on_enemy_exiting(enemy: EnemyCharacter) -> void:
	if not enemy.is_queued_for_deletion() or enemy.health > 0:
		return
	_remaining.erase(enemy)
	if not _remaining.is_empty():
		return
	if required_unlock != "" and not GameManager.is_door_unlocked(required_unlock):
		GameManager.unlock_door(required_unlock)
	GameManager.unlock_door(clear_flag)
	_open()


func _open() -> void:
	if clear_reward != null:
		clear_reward.add_child.call_deferred(B1_CHEST.instantiate())
	if _interaction != null:
		show()
		_interaction.set_deferred("monitoring", true)


func _travel() -> void:
	if visible:
		GameManager.change_stage(target_stage, target_spawn)
