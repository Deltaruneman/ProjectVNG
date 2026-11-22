extends InteractiveArea3D

## Basement-only explicit interaction: the stock contact checkpoint stays unchanged.
@export var id := ""
const ACTIVE_TINT := Color(0.45, 1.0, 0.65)
var _feedback_seconds := 0.0
@onready var _sprite: AnimatedSprite3D = $AnimatedSprite3D
@onready var _feedback: Label3D = $ActivationFeedback


func _ready() -> void:
	add_to_group("spawn_points")
	super._ready()
	interacted.connect(_activate)
	_refresh_marker()


func _process(delta: float) -> void:
	var eligible := _someone_can_interact()
	set_process_unhandled_input(eligible)
	_prompt.visible = eligible
	_feedback_seconds = maxf(0.0, _feedback_seconds - delta)
	_feedback.visible = _feedback_seconds > 0.0 and _is_current()
	_refresh_marker()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	super._unhandled_input(event)


func _someone_can_interact() -> bool:
	if not owner is Stage or GameManager.current_stage != owner or GameManager.is_changing():
		return false
	var dialogic := get_node_or_null("/root/Dialogic")
	if dialogic != null and dialogic.current_timeline != null:
		return false
	for body: Node3D in get_overlapping_bodies():
		if body is Player and body == owner.player and body.health > 0:
			return true
	return false


func _activate() -> void:
	# Recheck eligibility at dispatch; do not rely on the helper's can_interact fallback.
	if not _someone_can_interact():
		return
	var result := GameManager.activate_basement_checkpoint(owner.scene_file_path, id)
	if result == "accepted":
		_feedback.text = "Checkpoint activated."
		_feedback_seconds = 2.0
		_feedback.visible = true
		_refresh_marker()
	elif result == "rejected":
		_feedback_seconds = 0.0
		_feedback.visible = false


func _is_current() -> bool:
	return owner is Stage and GameManager.is_basement_reference(owner.scene_file_path) \
		and GameManager.is_basement_reference(GameManager.checkpoint_stage) \
		and GameManager.checkpoint_id == id


func _refresh_marker() -> void:
	_sprite.modulate = ACTIVE_TINT if _is_current() else Color.WHITE
	_sprite.play("turn" if _is_current() else "idle")
