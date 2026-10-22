class_name Player
extends BaseCharacter

## Turned on throughout the Hurt state so one hit doesn't drain health every single frame in a row.
var is_invulnerable: bool = false


func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Idle, true)
	super._ready()


## Every state of the fox can take damage, so this calls straight into the current state; whichever
## state doesn't want to lose health (Dead) overrides take_damage().
func _on_hurt_area_3d_hurt(_direction: Vector3, damage: float) -> void:
	print("Nhan sat thuong")
	if is_invulnerable:
		return
	fsm.current_state.take_damage(int(damage))
