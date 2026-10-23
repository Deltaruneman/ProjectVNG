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

@export var type: Type = Type.WIND

@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	var anim_name := _pick_animation()
	for t in SPRITE_NODES:
		var s := get_node_or_null(SPRITE_NODES[t]) as Node3D
		if s:
			s.visible = (t == type)
			print(
			"Node: ", s.name,
			" | visible: ", s.visible,
			" | visible_in_tree: ", s.is_visible_in_tree(),
			" | position: ", s.position,
			" | scale: ", s.scale
		)



	print("SlashFX nhận type: ", type)
	print("Animation được chọn: ", anim_name)
	print("Animation có sẵn: ", anim.get_animation_list())
	if anim_name == &"":
		push_warning("SlashFX: không tìm được animation cho dạng %s" % SPRITE_NODES[type])
		queue_free()
		return

	var a := anim.get_animation(anim_name)
	a.loop_mode = Animation.LOOP_NONE
	anim.animation_finished.connect(func(_n: StringName) -> void: queue_free())
	anim.play(anim_name)

	get_tree().create_timer(a.length + 0.2).timeout.connect(queue_free)
	anim.play(anim_name)
	print("Animation đang phát: ", anim.current_animation)

func _pick_animation() -> StringName:
	var wanted: String = ANIM_NAMES[type]
	if anim.has_animation(wanted):
		return StringName(wanted)

	var key: String = String(SPRITE_NODES[type]).to_lower()
	for n in anim.get_animation_list():
		if key in String(n).to_lower():
			return StringName(n)
	return &""
