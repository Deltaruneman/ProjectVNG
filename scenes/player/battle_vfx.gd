class_name BattleVFX
extends RefCounted

const SLASH: PackedScene = preload("res://assets/effects/BattleFXFree/BattleFXFree/assets/BinbunVFX_Vol2/BattleFX/effects/slash/vfx_blank_slash.tscn")
const SWING: PackedScene = preload("res://assets/effects/BattleFXFree/BattleFXFree/assets/BinbunVFX_Vol2/BattleFX/effects/swing/vfx_blank_swing.tscn")
const CLAW: PackedScene = preload("res://assets/effects/BattleFXFree/BattleFXFree/assets/BinbunVFX_Vol2/BattleFX/effects/claw/vfx_blank_claw.tscn")
const CHARGE: PackedScene = preload("res://assets/effects/BattleFXFree/BattleFXFree/assets/BinbunVFX_Vol2/BattleFX/effects/charge/vfx_blank_charge.tscn")
const SHIELD: PackedScene = preload("res://assets/effects/BattleFXFree/BattleFXFree/assets/BinbunVFX_Vol2/BattleFX/effects/shield/vfx_blank_shield_01.tscn")
const EMBER_SLASH: PackedScene = preload("res://emberline/effects/slash_arc.tscn")
const EMBER_SPARK: PackedScene = preload("res://emberline/effects/impact_spark.tscn")
const EMBER_RING: PackedScene = preload("res://emberline/effects/impact_ring.tscn")
const EMBER_BURST: PackedScene = preload("res://emberline/effects/area_burst.tscn")
const ATTACK_FX_AXIS_OFFSET := -PI / 2.0
const SOUND_ROOT := "res://assets/sfx/Free Fantasy SFX Pack By TomMusic/OGG Files/SFX/"


static func slash(parent: Node3D, position: Vector3, form: String, direction: Vector3, scale: float = 0.42) -> Node3D:
	return _spawn(SLASH, parent, position, form, direction, scale, true, 0.42, ATTACK_FX_AXIS_OFFSET)


static func swing(parent: Node3D, position: Vector3, form: String, direction: Vector3, scale: float = 0.65) -> Node3D:
	return _spawn(SWING, parent, position, form, direction, scale, false, 0.5, ATTACK_FX_AXIS_OFFSET)


static func claw(parent: Node3D, position: Vector3, form: String, direction: Vector3, scale: float = 0.6) -> Node3D:
	return _spawn(CLAW, parent, position, form, direction, scale, false, 0.6, ATTACK_FX_AXIS_OFFSET)


static func impact(parent: Node3D, position: Vector3, form: String, direction: Vector3, scale: float = 0.28) -> Node3D:
	# Layer two short, directional bursts so each confirmed hit reads clearly without lingering.
	_spawn(CLAW, parent, position, form, direction, scale * 0.9, false, 0.28, ATTACK_FX_AXIS_OFFSET)
	return _spawn(SLASH, parent, position, form, direction, scale, true, 0.32, ATTACK_FX_AXIS_OFFSET)


static func charge(parent: Node3D, position: Vector3, form: String, scale: float = 0.9) -> Node3D:
	return _spawn(CHARGE, parent, position, form, Vector3.FORWARD, scale, false, 1.0, 0.0)


static func circle_burst(parent: Node3D, position: Vector3, form: String, radius: float) -> Node3D:
	# The charge scene emits from a 1.5 m sphere, so this scale makes its radius match the hit area.
	return charge(parent, position, form, radius / 1.5)


static func emberline_slash(parent: Node3D, position: Vector3, form: String, direction: Vector3, half_extent: float = 1.15) -> Node2D:
	return _spawn_emberline(EMBER_SLASH, parent, position, form, direction, half_extent)


static func emberline_impact(parent: Node3D, position: Vector3, form: String, direction: Vector3, half_extent: float = 0.42) -> Node2D:
	return _spawn_emberline(EMBER_SPARK, parent, position, form, direction, half_extent)


static func emberline_ring(parent: Node3D, position: Vector3, form: String, direction: Vector3, half_extent: float = 1.2) -> Node2D:
	return _spawn_emberline(EMBER_RING, parent, position, form, direction, half_extent)


static func emberline_burst(parent: Node3D, position: Vector3, form: String, direction: Vector3, half_extent: float = 1.6) -> Node2D:
	return _spawn_emberline(EMBER_BURST, parent, position, form, direction, half_extent)


static func play_skill_sound(parent: Node3D, skill_id: String) -> void:
	var relative_path := ""
	match skill_id:
		"", "dagger", "active_wind_1": relative_path = "Attacks/Sword Attacks Hits and Blocks/Sword Attack 1.ogg"
		"active_wind_2": relative_path = "Attacks/Sword Attacks Hits and Blocks/Sword Attack 2.ogg"
		"active_wind_3", "ultimate_wind_1", "ultimate_wind_2": relative_path = "Attacks/Sword Attacks Hits and Blocks/Sword Attack 3.ogg"
		"active_fire_1", "active_fire_2": relative_path = "Spells/Fireball 1.ogg"
		"active_fire_3", "ultimate_fire_1": relative_path = "Spells/Firespray 1.ogg"
		"ultimate_fire_2", "fire_impact": relative_path = "Spells/Fireball 3.ogg"
		"fire_hit": relative_path = "Spells/Spell Impact 1.ogg"
		"active_ice_1": relative_path = "Spells/Ice Throw 1.ogg"
		"active_ice_2", "ultimate_ice_2": relative_path = "Spells/Ice Freeze 1.ogg"
		"active_ice_3", "ultimate_ice_1": relative_path = "Spells/Ice Wall 1.ogg"
		"ice_hit": relative_path = "Spells/Spell Impact 2.ogg"
		"wind_hit": relative_path = "Attacks/Sword Attacks Hits and Blocks/Sword Impact Hit 1.ogg"
		_: return
	var sound_path := SOUND_ROOT + relative_path
	if not FileAccess.file_exists(sound_path):
		return
	var stream: AudioStream = load(sound_path) as AudioStream
	if stream == null:
		return
	var audio := AudioStreamPlayer.new()
	audio.stream = stream
	audio.volume_db = -5.0
	audio.bus = "Master"
	parent.add_child(audio)
	audio.finished.connect(audio.queue_free, CONNECT_ONE_SHOT)
	audio.play()


static func shield(parent: Node3D, position: Vector3, form: String, duration: float = 8.0, scale: float = 1.0) -> Node3D:
	return _spawn(SHIELD, parent, position, form, Vector3.FORWARD, scale, true, duration, 0.0)


static func _spawn(scene: PackedScene, parent: Node3D, position: Vector3, form: String, direction: Vector3, effect_scale: float, emitter: bool, duration: float, axis_offset: float) -> Node3D:
	if not is_instance_valid(parent):
		return null
	var effect := scene.instantiate() as Node3D
	if effect == null:
		return null
	_make_materials_local(effect)
	parent.add_child(effect)
	effect.global_position = position
	if direction.length_squared() > 0.001:
		# The attack assets are authored facing local +X, while gameplay uses +Z as forward/down.
		effect.global_rotation.y = atan2(direction.x, direction.z) + axis_offset
	effect.scale = Vector3.ONE * effect_scale
	_apply_palette(effect, form)
	if emitter:
		effect.set("emitting", true)
		_fade_emitter(effect, duration)
	else:
		effect.set("one_shot", true)
		effect.connect("finished", Callable(effect, "queue_free"), CONNECT_ONE_SHOT)
		effect.call_deferred("play")
		_free_after(effect, duration + 0.2)
	return effect


static func _spawn_emberline(scene: PackedScene, parent: Node3D, position: Vector3, form: String, direction: Vector3, world_half_extent: float) -> Node2D:
	if not is_instance_valid(parent):
		return null
	var camera := parent.get_viewport().get_camera_3d()
	if camera == null or camera.is_position_behind(position):
		return null
	var stage := parent.get_tree().current_scene
	if stage == null:
		return null
	var overlay := stage.get_node_or_null("EmberlineVFXOverlay") as CanvasLayer
	if overlay == null:
		overlay = CanvasLayer.new()
		overlay.name = "EmberlineVFXOverlay"
		overlay.layer = 0
		stage.add_child(overlay)
	var screen_position: Vector2 = camera.unproject_position(position)
	var screen_right: Vector2 = camera.unproject_position(position + camera.global_transform.basis.x * world_half_extent) - screen_position
	var projected_extent := screen_right.length()
	var effect_scale := clampf(projected_extent / 128.0, 0.12, 2.5)
	var screen_direction := camera.unproject_position(position + direction.normalized()) - screen_position
	if direction.length_squared() < 0.001 or screen_direction.length_squared() < 0.001:
		screen_direction = Vector2.RIGHT
	var tint := Color("65dfff")
	var accent := Color("f4ffff")
	match form:
		"fire":
			tint = Color("ff7138")
			accent = Color("ffe77b")
		"ice":
			tint = Color("71cfff")
			accent = Color("efffff")
	var effect := scene.instantiate() as Node2D
	if effect == null:
		return null
	effect.set("autoplay", false)
	effect.set("tint", tint)
	effect.set("accent", accent)
	effect.set("effect_scale", effect_scale)
	overlay.add_child(effect)
	effect.global_position = screen_position
	effect.global_rotation = screen_direction.angle()
	effect.call_deferred("play")
	return effect


static func _make_materials_local(effect: Node3D) -> void:
	for child in effect.get_children():
		if child is MeshInstance3D and child.material_override != null:
			child.material_override = child.material_override.duplicate()
		elif child is GPUParticles3D and child.material_override != null:
			child.material_override = child.material_override.duplicate()


static func _apply_palette(effect: Node3D, form: String) -> void:
	var primary := Color("55e8dd")
	var secondary := Color("198ba7")
	var tertiary := Color("073c61")
	match form:
		"fire":
			primary = Color("fff07a")
			secondary = Color("ff6a24")
			tertiary = Color("a52023")
		"ice":
			primary = Color("e4ffff")
			secondary = Color("67ceff")
			tertiary = Color("2853b9")
	effect.set("primary_color", primary)
	effect.set("secondary_color", secondary)
	effect.set("tertiary_color", tertiary)
	effect.set("emission", 2.6)


static func _fade_emitter(effect: Node3D, duration: float) -> void:
	var tween: Tween = effect.create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(Callable(effect, "set").bind("emitting", false))
	tween.tween_interval(0.65)
	tween.tween_callback(Callable(effect, "queue_free"))


static func _free_after(effect: Node3D, duration: float) -> void:
	var tween: Tween = effect.create_tween()
	tween.tween_interval(duration)
	tween.tween_callback(func() -> void:
		if is_instance_valid(effect):
			effect.queue_free())
