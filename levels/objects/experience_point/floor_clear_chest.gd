extends Node3D

const REWARD_ID := "floor_clear:basement_b1" # Preserve old opened chests.
const CATALOG := preload("res://scripts/item_catalog.gd")
const DROP := preload("res://levels/objects/experience_point/chest_pickup.tscn")
const OFFSCREEN_INDICATOR := preload("res://ui/chest_offscreen_indicator.gd")
const OPEN_TEXTURE := preload("res://assets/sprites/object/chest/chest_gold_open_05.png")
const OPEN_FRAMES := [
	preload("res://assets/sprites/object/chest/chest_gold_open_01.png"),
	preload("res://assets/sprites/object/chest/chest_gold_open_02.png"),
	preload("res://assets/sprites/object/chest/chest_gold_open_03.png"),
	preload("res://assets/sprites/object/chest/chest_gold_open_04.png"),
	OPEN_TEXTURE,
]
@export var chest_id := "basement_b1_clear"
@export var guaranteed_weapon := true
@export var offscreen_indicator_enabled := true
var _opening := false
@onready var _interaction: InteractiveArea3D = $InteractiveArea3D
var _indicator_layer: CanvasLayer
var _indicator: Control

func _ready() -> void:
	if _is_open():
		_show_open()
		_remove_open_chest.call_deferred()
	else:
		_create_offscreen_indicator()
		_interaction.interacted.connect(_open)

func _key() -> String:
	return "chest_loot:" + chest_id

func _create_offscreen_indicator() -> void:
	if not offscreen_indicator_enabled:
		return
	_indicator_layer = CanvasLayer.new()
	_indicator_layer.layer = 25
	add_child(_indicator_layer)
	_indicator = OFFSCREEN_INDICATOR.new() as Control
	_indicator.set("target", self)
	_indicator_layer.add_child(_indicator)

func _has_unclaimed_rewards() -> bool:
	if not GameManager.flags.has(_key()):
		return not _is_open()
	var state: Variant = GameManager.flags[_key()]
	if not state is Dictionary:
		return false
	var items: Variant = state.get("items", [])
	var claimed: Variant = state.get("claimed", [])
	if not items is Array or not claimed is Array:
		return false
	for index in items.size() + 10:
		if not claimed.has(str(index)):
			return true
	return false

func _process(_delta: float) -> void:
	if _indicator != null:
		_indicator.set("active", _has_unclaimed_rewards())

func _remove_open_chest() -> void:
	restore_pending(get_tree().current_scene)
	queue_free()

func _is_open() -> bool:
	return GameManager.flags.has(_key()) or (chest_id == "basement_b1_clear" and GameManager.collected_exp_points.has(REWARD_ID))

func _open() -> void:
	if _opening or _is_open() or GameManager.is_changing():
		return
	_opening = true
	# Roll and save before animation: a transition during opening cannot reroll loot.
	var pool: Array[String] = []
	var weapons: Array[String] = []
	for id: String in CATALOG.definitions():
		pool.append(id)
		if CATALOG.item(id).get("slot", "") == "main" and id != "starter_blade":
			weapons.append(id)
	var items: Array[String] = []
	for index in randi_range(1, 2):
		var choices := weapons if guaranteed_weapon and index == 0 else pool
		items.append(choices.pick_random())
	GameManager.flags[_key()] = {"items": items, "claimed": []}
	GameManager.save_game()
	_interaction.set_process_unhandled_input(false)
	_interaction.get_node("Prompt").hide()
	for frame in OPEN_FRAMES:
		$Sprite3D.texture = frame
		await get_tree().create_timer(0.09, false).timeout
	_show_open()
	restore_pending(get_tree().current_scene, global_position + Vector3.UP * 0.8, _key())
	queue_free()

func _show_open() -> void:
	$Sprite3D.texture = OPEN_TEXTURE
	if is_instance_valid(_interaction):
		_interaction.queue_free()

static func restore_pending(stage: Node, origin: Vector3 = Vector3.INF, only_key: String = "") -> void:
	if not is_instance_valid(stage) or not stage.is_inside_tree():
		return
	var player := stage.get_node_or_null("Player") as Player
	if player == null:
		return
	for raw_key: Variant in GameManager.flags:
		var key := str(raw_key)
		if not key.begins_with("chest_loot:") or (only_key != "" and only_key != key):
			continue
		var state: Dictionary = GameManager.flags[key]
		var items: Array = state.get("items", [])
		var claimed: Array = state.get("claimed", [])
		for index in items.size() + 10:
			if claimed.has(str(index)):
				continue
			var exists := false
			for drop: Node in stage.get_tree().get_nodes_in_group("chest_drops"):
				if stage.is_ancestor_of(drop) and drop.reward_key == key and drop.reward_index == index:
					exists = true
					break
			if exists:
				continue
			var pickup = DROP.instantiate()
			pickup.reward_key = key
			pickup.reward_index = index
			pickup.item_id = str(items[index]) if index < items.size() else ""
			var angle := TAU * float(index) / float(items.size() + 10)
			pickup.burst = Vector3(cos(angle) * 3.0, 1.4, sin(angle) * 3.0)
			stage.add_child(pickup)
			pickup.global_position = player.global_position + Vector3.UP if origin == Vector3.INF else origin
