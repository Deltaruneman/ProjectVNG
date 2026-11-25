extends ExpPointPickup
## One persisted chest reward. Claim state and inventory/EXP are saved together.
const CATALOG := preload("res://scripts/item_catalog.gd")
var reward_key := ""
var reward_index := 0
var item_id := ""
var burst := Vector3.ZERO

func _ready() -> void:
	super._ready()
	add_to_group("chest_drops")
	attraction_delay = 0.65 + float(reward_index) * 0.025
	if not item_id.is_empty():
		var icon := Sprite3D.new()
		icon.texture = CATALOG.texture(item_id)
		if icon.texture == null:
			icon.queue_free()
			return
		if _orb != null:
			_orb.hide()
		icon.billboard = BaseMaterial3D.BILLBOARD_ENABLED
		icon.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
		icon.pixel_size = 0.022 if icon.texture.get_width() <= 64 else 0.006
		icon.position.y = 0.6
		add_child(icon)

func _physics_process(delta: float) -> void:
	if _age < attraction_delay:
		position += burst * delta
		burst = burst.move_toward(Vector3.ZERO, 7.0 * delta)
	super._physics_process(delta)

func _on_area_entered(_area: Area3D) -> void:
	pass # Allow the burst to finish before homing, even when opened under Player.

func _collect(player: BaseCharacter) -> void:
	if _collected or player == null or player.health <= 0 or GameManager.is_changing():
		return
	var state: Dictionary = GameManager.flags.get(reward_key, {})
	var claimed: Array = state.get("claimed", [])
	if claimed.has(str(reward_index)):
		queue_free()
		return
	_collected = true
	claimed.append(str(reward_index))
	state["claimed"] = claimed
	GameManager.flags[reward_key] = state
	if item_id.is_empty():
		GameManager.award_experience(GameManager.PROGRESSION.EXP_PER_POINT, "%s:%d" % [reward_key, reward_index])
	else:
		GameManager.grant_item(item_id)
	queue_free()
