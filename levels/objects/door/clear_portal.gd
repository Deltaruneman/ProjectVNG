extends Node3D

@export var id := ""
@export_file("*.tscn") var target_stage := ""
@export var target_spawn := ""
@export var clear_flag := ""
@export var required_unlock := ""
@export var encounters: Node3D
@export var clear_reward: Marker3D
## Optional unique reward chest key; empty keeps the chest scene's existing default ID.
@export var clear_reward_chest_id := ""
@export var return_door: Node3D

const B1_CHEST := preload("res://levels/objects/experience_point/floor_clear_chest.tscn")
var _remaining: Array[EnemyCharacter] = []
var _opened := false
var _locked_interaction: InteractiveArea3D
@onready var _interaction := get_node_or_null("InteractiveArea3D") as InteractiveArea3D

func _ready() -> void:
	if id != "":
		add_to_group("spawn_points")
	# Authored return door points to the current integrated Basementfull scene.
	if encounters == null or clear_flag.is_empty():
		push_error("%s has no encounter container or stable clear flag." % get_path())
		return
	if _interaction != null:
		_interaction.interacted.connect(_travel)
	var restored_clear := GameManager.is_door_unlocked(clear_flag)
	if clear_flag == "b2_split_cleared" and not restored_clear:
		_setup_locked_interaction.call_deferred()
	var authored_count := 0
	for child in encounters.get_children():
		if not child is EnemyCharacter:
			continue
		authored_count += 1
		if restored_clear or GameManager.is_door_unlocked(_defeat_key(child)):
			child.hide()
			child.process_mode = Node.PROCESS_MODE_DISABLED
			child.queue_free()
			continue
		_remaining.append(child)
		# Terminal signal avoids waiting for death animation cleanup; phase changes aren't defeats.
		if child.has_signal("defeated"):
			child.connect("defeated", _record_defeat.bind(child))
		else:
			child.health_changed.connect(_on_enemy_health_changed.bind(child))
		child.tree_exiting.connect(_on_enemy_exiting.bind(child))
	if authored_count == 0:
		push_error("%s has no encounters configured." % get_path())
	elif _remaining.is_empty():
		_complete()

func _defeat_key(enemy: EnemyCharacter) -> String:
	return "encounter_defeated:%s:%s" % [clear_flag, encounters.get_path_to(enemy)]

func _on_enemy_health_changed(current: int, _maximum: int, enemy: EnemyCharacter) -> void:
	if current <= 0:
		_record_defeat(enemy)

func _on_enemy_exiting(enemy: EnemyCharacter) -> void:
	# Scene teardown of a living enemy must never count as a kill.
	if not enemy.is_queued_for_deletion() or enemy.health > 0:
		return
	_record_defeat(enemy)

func _record_defeat(enemy: EnemyCharacter) -> void:
	if enemy not in _remaining or enemy.health > 0:
		return
	GameManager.flags[_defeat_key(enemy)] = true
	_remaining.erase(enemy)
	if _remaining.is_empty():
		_complete()
	else:
		GameManager.save_game()

func _complete() -> void:
	if required_unlock != "":
		GameManager.flags[required_unlock] = true
	GameManager.flags[clear_flag] = true
	GameManager.save_game()
	_open()

func _open() -> void:
	if _opened:
		return
	_opened = true
	if is_instance_valid(_locked_interaction):
		_locked_interaction.queue_free()
	if clear_reward != null:
		var chest := B1_CHEST.instantiate()
		if not clear_reward_chest_id.is_empty():
			chest.set("chest_id", clear_reward_chest_id)
		clear_reward.add_child.call_deferred(chest)
	if _interaction != null:
		show()
		_interaction.set_deferred("monitoring", true)

func _travel() -> void:
	if visible:
		GameManager.change_stage(target_stage, target_spawn)

func _setup_locked_interaction() -> void:
	if _opened or not is_inside_tree():
		return
	_locked_interaction = InteractiveArea3D.new()
	_locked_interaction.position = position + Vector3.UP
	var shape := CollisionShape3D.new()
	var cylinder := CylinderShape3D.new()
	cylinder.radius = 1.45
	cylinder.height = 2.2
	shape.shape = cylinder
	_locked_interaction.add_child(shape)
	get_parent().add_child(_locked_interaction)
	_locked_interaction.interacted.connect(_tell_locked)

func _tell_locked() -> void:
	if _opened:
		return
	var story := get_tree().current_scene.get_node_or_null("BasementStory")
	if story != null:
		story.play_event("b2_locked")
