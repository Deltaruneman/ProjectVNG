extends Node

const Conversation := preload("res://scripts/conversation.gd")
const CASTLE_ARRIVAL_TIMELINE := "res://dialog/timelines/castle_arrival.dtl"
const EXECUTIONER_TIMELINE := "res://dialog/timelines/undead_executioner_intro.dtl"
const NECROMANCER_TIMELINE := "res://dialog/timelines/necromancer_intro.dtl"
const EXECUTIONER_CLEAR_FLAG := "castle_executioner_defeated"
const NECROMANCER_CLEAR_FLAG := "castle_necromancer_defeated"
const STORY_FLAGS := {
	"UndeadExecutioner": "story_castle_executioner_intro_seen",
	"Necromancer": "story_castle_necromancer_intro_seen",
}

@onready var _player: Player = get_node_or_null("../Player") as Player
var _intro_active := false


func _ready() -> void:
	_start_castle_story.call_deferred()


func _start_castle_story() -> void:
	if not bool(GameManager.flags.get("story_castle_first_arrival_seen", false)):
		if not is_instance_valid(_player) or Dialogic.current_timeline != null:
			return
		await Conversation.play(CASTLE_ARRIVAL_TIMELINE, _player)
		if not is_inside_tree():
			return
		GameManager.flags["story_castle_first_arrival_seen"] = true
		GameManager.save_game()
	_install_boss_trigger("UndeadExecutioner", EXECUTIONER_TIMELINE, STORY_FLAGS["UndeadExecutioner"], EXECUTIONER_CLEAR_FLAG)
	_install_boss_trigger("Necromancer", NECROMANCER_TIMELINE, STORY_FLAGS["Necromancer"], NECROMANCER_CLEAR_FLAG)


func _install_boss_trigger(boss_name: String, timeline: String, story_flag: String, clear_flag: String) -> void:
	if bool(GameManager.flags.get(story_flag, false)) or bool(GameManager.flags.get(clear_flag, false)):
		return
	var boss := get_node_or_null("../%s/%s" % [boss_name + "Encounter", boss_name]) as EnemyCharacter
	if boss == null:
		return
	var trigger := Area3D.new()
	trigger.name = "%sIntroTrigger" % boss_name
	trigger.collision_layer = 0
	trigger.collision_mask = 2
	var shape := CollisionShape3D.new()
	var radius := SphereShape3D.new()
	radius.radius = 6.5
	shape.shape = radius
	trigger.add_child(shape)
	boss.add_child(trigger)
	trigger.body_entered.connect(_on_boss_triggered.bind(boss, timeline, story_flag))


func _on_boss_triggered(body: Node3D, boss: EnemyCharacter, timeline: String, story_flag: String) -> void:
	if not body is Player or _intro_active or not is_instance_valid(boss):
		return
	var player := body as Player
	if player.is_talking or Dialogic.current_timeline != null or bool(GameManager.flags.get(story_flag, false)):
		return
	_intro_active = true
	GameManager.flags[story_flag] = true
	GameManager.save_game()
	var previous_process_mode: Node.ProcessMode = boss.process_mode
	boss.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)
	await Conversation.play(timeline, player, boss)
	if is_instance_valid(boss):
		boss.set_deferred("process_mode", previous_process_mode)
	_intro_active = false
