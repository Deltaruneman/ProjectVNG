extends PlayerState

const SLASH_FX := preload("res://effects/slash.tscn")
const SlashFX := preload("res://effects/slash.gd")

var slash_type: SlashFX.Type = SlashFX.Type.FIRE

func _enter() -> void:
	obj.change_animation("attack")
	obj.stop_horizontal()
	obj.suppress_blade(true) # Ẩn blade khi tấn công
	timer = obj.anim_player.get_animation("attack_%s" % obj.direction).length
	_hit_shape().disabled = false
	_spawn_fx(slash_type)

func _exit() -> void:
	_hit_shape().disabled = true
	obj.suppress_blade(false) # Hiện lại blade (nếu còn has_weapon)

func _update(_delta: float) -> void:
	if update_timer(_delta):
		change_state(fsm.previous_state)

func _spawn_fx(t: SlashFX.Type) -> void:
	var fx := SLASH_FX.instantiate()
	_hit_shape().get_parent().add_child(fx)
	fx.position = Vector3.ZERO
	fx.play_slash(t)

func _hit_shape() -> CollisionShape3D:
	return obj.get_node("Direction/HitArea3D/CollisionShape3D")
