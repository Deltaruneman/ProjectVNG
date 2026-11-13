extends Node3D

## This door's name as a spawn point. A door in another stage leads here
## with target_door = id.
@export var id := ""
@export_file("*.tscn") var target_stage := ""
@export var target_door := ""
@export var transition_enabled := true
## A locked door opens only once GameManager has the flag `unlock_flag`
## (see unlock_door()).
@export var locked := false
@export var unlock_flag := ""

@onready var _sprite: AnimatedSprite3D = $AnimatedSprite3D

func _ready() -> void:
	add_to_group("spawn_points")
	if not transition_enabled:
		# Keep the gate and its solid collision, remove only the unusable interaction.
		$InteractiveArea3D.queue_free()
		_sprite.play("idle")
		return
	$InteractiveArea3D.interacted.connect(_on_interacted)
	var arriving := id != "" and GameManager.pending_spawn == id
	_sprite.play("closing" if arriving else "idle")

func is_locked() -> bool:
	return locked and not GameManager.is_door_unlocked(unlock_flag)

func _on_interacted() -> void:
	if not transition_enabled or target_stage.is_empty():
		return
	if is_locked():
		_tell_locked()
		return
	if _sprite.animation == "opening":
		return	# already opening - a second press changes nothing
	_sprite.play("opening")
	await _sprite.animation_finished
	GameManager.change_stage(target_stage, target_door)

func _tell_locked() -> void:
	for body: Node3D in $InteractiveArea3D.get_overlapping_bodies():
		if body is Player:
			Conversation.play("door_locked", body)
			return
