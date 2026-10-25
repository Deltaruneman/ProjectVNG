extends Node3D

enum Type { WIND, FIRE, ICE }

const SPRITE_NODES := {
	Type.WIND: "Wind",
	Type.FIRE: "Fire",
	Type.ICE: "Ice",
}

const ANIM_NAMES := {
	Type.WIND: "wind_slash",
	Type.FIRE: "fire_slash",
	Type.ICE: "ice_slash",
}

@onready var anim: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	# Không truyền tham số thì ẩn hết và không chạy animation nào
	_hide_all()


func play_slash(type: Type) -> void:
	_hide_all()

	var sprite := get_node_or_null(SPRITE_NODES[type]) as Node3D
	if sprite:
		sprite.visible = true

	var anim_name: String = ANIM_NAMES[type]
	if not anim.has_animation(anim_name):
		push_warning("SlashFX: không có animation '%s'" % anim_name)
		queue_free()
		return

	anim.get_animation(anim_name).loop_mode = Animation.LOOP_NONE
	anim.animation_finished.connect(func(_n: StringName) -> void: queue_free(), CONNECT_ONE_SHOT)
	anim.play(anim_name)


func _hide_all() -> void:
	for t in SPRITE_NODES:
		var s := get_node_or_null(SPRITE_NODES[t]) as Node3D
		if s:
			s.visible = false
