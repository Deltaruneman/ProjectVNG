extends InteractiveArea3D

## This checkpoint's name - unique within its stage. The save file stores
## this, not coordinates.
@export var id := ""

@onready var _sprite: AnimatedSprite3D = $AnimatedSprite3D
var _stage: Stage
var _feedback: Label3D
var _feedback_seconds := 0.0

func _ready() -> void:
	add_to_group("spawn_points")
	var ancestor := get_parent()
	while ancestor != null and not ancestor is Stage:
		ancestor = ancestor.get_parent()
	_stage = ancestor as Stage
	super._ready()
	interacted.connect(_activate)
	_prompt.text = "Chạm / F: Lưu"
	_prompt.font_size = 32
	_sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	_feedback = _create_prompt()
	_feedback.name = "ActivationFeedback"
	_feedback.position.y = 2.8
	_feedback.font_size = 32
	add_child(_feedback)
	_refresh_marker()

func _on_body_entered(body: Node3D) -> void:
	if not (body is Player) or _is_current():
		return
	# Contact activation is independent of temporary interaction locks (for example, stairs).
	_activate_from_contact.call_deferred()


func _activate_from_contact() -> void:
	if id.is_empty() or _is_current() or not _can_activate_from_contact():
		return
	_save_checkpoint()


func _can_activate_from_contact() -> bool:
	return not id.is_empty() and is_instance_valid(_stage) and GameManager.current_stage == _stage \
		and not GameManager.is_changing() and not GameManager.has_checkpoint_conflict() \
		and not get_tree().paused \
		and is_instance_valid(_stage.player) and _stage.player.health > 0.0 \
		and overlaps_body(_stage.player)


func _someone_can_interact() -> bool:
	return is_instance_valid(_stage) and GameManager.current_stage == _stage \
		and not GameManager.is_changing() and _stage.player.can_interact() \
		and overlaps_body(_stage.player)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_echo():
		super._unhandled_input(event)


func _activate() -> void:
	if not _someone_can_interact() or id.is_empty():
		return
	_save_checkpoint()


func _save_checkpoint() -> void:
	if id.is_empty():
		return
	GameManager.set_checkpoint(_stage.scene_file_path, id)
	_feedback.text = "Đã lưu checkpoint" if _is_current() else "Chưa thể lưu checkpoint"
	_feedback_seconds = 2.0
	_refresh_marker()


func _process(delta: float) -> void:
	# If contact happened during a brief lock, retry while the player remains in the trigger.
	if not _is_current() and _can_activate_from_contact():
		_activate_from_contact()
	var eligible := _someone_can_interact()
	set_process_unhandled_input(eligible)
	_prompt.visible = eligible
	_feedback_seconds = maxf(0.0, _feedback_seconds - delta)
	_feedback.visible = _feedback_seconds > 0.0
	_refresh_marker()


func _refresh_marker() -> void:
	var active := _is_current()
	_sprite.modulate = Color(0.45, 1.0, 0.65) if active else Color.WHITE
	_sprite.play("turn" if active else "idle")

## `owner` is the root of the scene this checkpoint was saved in - the stage.
func _is_current() -> bool:
	if not is_instance_valid(_stage) or GameManager.checkpoint_id != id:
		return false
	if GameManager.checkpoint_stage == _stage.scene_file_path:
		return true
	return GameManager.is_basement_reference(GameManager.checkpoint_stage) \
		and GameManager.LEGACY_BASEMENT_CHECKPOINTS.get(_stage.scene_file_path, "") == id
