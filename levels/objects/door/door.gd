extends Node3D
const Conversation := preload("res://scripts/conversation.gd")
const COMING_SOON_OVERLAY := preload("res://ui/coming_soon_overlay.gd")

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
@export var coming_soon := false
@export var before_transition_timeline := ""
@export var before_transition_flag := ""

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
	if not transition_enabled:
		return
	if coming_soon:
		var overlay := COMING_SOON_OVERLAY.new()
		get_tree().current_scene.add_child(overlay)
		return
	if target_stage.is_empty():
		return
	if is_locked():
		_tell_locked()
		return
	if _sprite.animation == "opening":
		return	# already opening - a second press changes nothing
	if not before_transition_timeline.is_empty() and not before_transition_flag.is_empty() \
			and not bool(GameManager.flags.get(before_transition_flag, false)):
		var player := _get_interacting_player()
		if player == null or player.is_talking or Dialogic.current_timeline != null:
			return
		await Conversation.play(before_transition_timeline, player)
		if not is_inside_tree() or GameManager.is_changing():
			return
		GameManager.flags[before_transition_flag] = true
		GameManager.save_game()
	_sprite.play("opening")
	await _sprite.animation_finished
	GameManager.change_stage(target_stage, target_door)


func _get_interacting_player() -> Player:
	for body: Node3D in $InteractiveArea3D.get_overlapping_bodies():
		if body is Player:
			return body
	return null

func _tell_locked() -> void:
	var story := get_tree().current_scene.get_node_or_null("BasementStory")
	if unlock_flag == "b2_cleared" and story != null:
		story.play_event("b2_locked")
		return
	for body: Node3D in $InteractiveArea3D.get_overlapping_bodies():
		if body is Player:
			Conversation.play("door_locked", body)
			return
