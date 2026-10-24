extends PlayerState

const SLASH_FX := preload("res://effects/slash.tscn")
const SlashFX := preload("res://effects/slash.gd")

func _enter() -> void:
	obj.change_animation("attack")
	obj.stop_horizontal()
	timer = obj.anim_player.get_animation("attack_%s" % obj.direction).length
	_hit_shape().disabled = false
	_spawn_fx()

func _exit() -> void:
	_hit_shape().disabled = true

func _update(_delta: float) -> void:
	if update_timer(_delta):
		change_state(fsm.previous_state)

func _spawn_fx() -> void:
	var t := _fx_type()
	if t < 0:
		return   # chưa có nguyên tố nào, đánh thường không FX
	var fx := SLASH_FX.instantiate()
	fx.type = t
	_hit_shape().get_parent().add_child(fx)
	fx.position = Vector3.ZERO

func _fx_type() -> int:
	match PlayerProgress.equipped_element:
		&"wind": return SlashFX.Type.WIND
		&"fire": return SlashFX.Type.FIRE
		&"ice": return SlashFX.Type.ICE
	return -1

func _hit_shape() -> CollisionShape3D:
	return obj.get_node("Direction/HitArea3D/CollisionShape3D")
