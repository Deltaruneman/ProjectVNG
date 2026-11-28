extends Node

const Conversation := preload("res://scripts/conversation.gd")
const ARRIVAL_TIMELINE := "res://dialog/timelines/garden_arrival.dtl"
const ARRIVAL_FLAG := "story_garden_first_arrival_seen"

@onready var _player: Player = get_node_or_null("../Player") as Player
@onready var _camera_rig: CameraRig = get_node_or_null("../CameraRig") as CameraRig
@onready var _gardener: Node3D = get_node_or_null("../Farm/SeedMerchant") as Node3D
var _camera_tween: Tween


func _ready() -> void:
	if not bool(GameManager.flags.get(ARRIVAL_FLAG, false)):
		_play_arrival.call_deferred()


func _play_arrival() -> void:
	if not is_instance_valid(_player) or Dialogic.current_timeline != null:
		return
	Dialogic.signal_event.connect(_on_dialogic_signal)
	await Conversation.play(ARRIVAL_TIMELINE, _player)
	if Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.disconnect(_on_dialogic_signal)
	_restore_camera()
	if not is_inside_tree():
		return
	GameManager.flags[ARRIVAL_FLAG] = true
	GameManager.save_game()


func _on_dialogic_signal(argument: Variant) -> void:
	if argument == "focus_gardener":
		_focus_gardener()


func _focus_gardener() -> void:
	if not is_instance_valid(_camera_rig) or not is_instance_valid(_gardener):
		return
	_camera_rig.target = _gardener
	_camera_rig.snap_to_target()
	_camera_rig.camera.fov = 35.0
	_camera_tween = create_tween()
	_camera_tween.tween_property(_camera_rig.camera, "fov", 23.0, 0.7) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _restore_camera() -> void:
	if is_instance_valid(_camera_tween) and _camera_tween.is_running():
		_camera_tween.kill()
	if is_instance_valid(_camera_rig) and is_instance_valid(_player):
		_camera_rig.target = _player
		_camera_rig.camera.fov = 35.0
		_camera_rig.snap_to_target()


func _exit_tree() -> void:
	if Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.disconnect(_on_dialogic_signal)
	_restore_camera()
