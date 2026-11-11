extends Node3D

const REWARD_ID := "floor_clear:basement_b1"
const OPEN_TEXTURE := preload("res://assets/sprites/object/chest/chest_gold_open_05.png")

@onready var _interaction: InteractiveArea3D = $InteractiveArea3D


func _ready() -> void:
	if GameManager.collected_skill_points.has(REWARD_ID):
		_show_open()
	else:
		_interaction.interacted.connect(_open, CONNECT_ONE_SHOT)


func _open() -> void:
	GameManager.reward_floor_clear("basement_b1")
	_show_open()


func _show_open() -> void:
	$Sprite3D.texture = OPEN_TEXTURE
	_interaction.queue_free()
