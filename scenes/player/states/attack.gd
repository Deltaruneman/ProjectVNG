extends PlayerState

const SLASH_FX := preload("res://effects/slash.tscn")
const SlashFX := preload("res://effects/slash.gd")

var combo_index := 0

func _enter() -> void:
	obj.change_animation("attack")
	obj.stop_horizontal()
	timer = obj.anim_player.get_animation("attack_%s" % obj.direction).length
	_hit_shape().disabled = false

	var t: SlashFX.Type = combo_index as SlashFX.Type
	print("Attack combo_index: ", combo_index, " | type: ", t)

	_spawn_fx(t)
	combo_index = (combo_index + 1) % SlashFX.Type.size()
func _exit() -> void:
	_hit_shape().disabled = true

func _update(_delta: float) -> void:
	if update_timer(_delta):
		change_state(fsm.previous_state)

func _spawn_fx(t: SlashFX.Type) -> void:
	var fx := SLASH_FX.instantiate()
	fx.type = t
	_hit_shape().get_parent().add_child(fx)
	fx.position = Vector3.ZERO

func _hit_shape() -> CollisionShape3D:
	return obj.get_node("Direction/HitArea3D/CollisionShape3D")
