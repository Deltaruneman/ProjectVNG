extends PlayerState

const SLASH_FX := preload("res://assets/effects/slash/slash.tscn")
const SlashFX := preload("res://assets/effects/slash/slash.gd")

var _previous_speed := 1.0
var _previous_shape_scale := Vector3.ONE
var _previous_shape_position := Vector3.ZERO

func _enter() -> void:
	obj.change_animation("attack")
	obj.stop_horizontal()
	obj.suppress_blade(true) # Ẩn blade khi tấn công
	obj.get_node("Direction/HitArea3D").damage = obj.roll_weapon_damage(obj.attack_damage)
	_previous_speed = obj.anim_player.speed_scale
	var equipment: Dictionary = GameManager.inventory.definition_for_slot("main")
	obj.anim_player.speed_scale *= float(equipment.get("tempo", 1.0))
	_previous_shape_scale = _hit_shape().scale
	_previous_shape_position = _hit_shape().position
	var reach := float(equipment.get("reach", 1.0)) * (1.0 + 0.1 * GameManager.inventory.enchant_rank("main", "reach"))
	_hit_shape().scale = _previous_shape_scale * Vector3(float(equipment.get("width", 1.0)), 1.0, reach)
	_hit_shape().position.z = _previous_shape_position.z * reach
	timer = obj.anim_player.get_animation("attack_%s" % obj.direction).length / maxf(0.01, obj.anim_player.speed_scale)
	_hit_shape().disabled = false
	match GameManager.weapon_form:
		"wind": _spawn_fx(SlashFX.Type.WIND)
		"fire": _spawn_fx(SlashFX.Type.FIRE)
		"ice": _spawn_fx(SlashFX.Type.ICE)
		"lightning": _spawn_fx(SlashFX.Type.WIND)

func _exit() -> void:
	_hit_shape().disabled = true
	_hit_shape().scale = _previous_shape_scale
	_hit_shape().position = _previous_shape_position
	obj.anim_player.speed_scale = _previous_speed
	obj.suppress_blade(false) # Hiện lại blade (nếu còn has_weapon)

func _update(_delta: float) -> void:
	if update_timer(_delta):
		change_state(fsm.previous_state)


func _spawn_fx(type: SlashFX.Type) -> void:
	var fx := SLASH_FX.instantiate()
	obj.get_node("Direction").add_child(fx)
	fx.position = Vector3.UP * 0.2
	fx.play_slash(type)

func _hit_shape() -> CollisionShape3D:
	return obj.get_node("Direction/HitArea3D/CollisionShape3D")
