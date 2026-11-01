class_name BattleVFX
extends RefCounted

const SLASH: PackedScene = preload("res://assets/effects/BattleFXFree/BattleFXFree/assets/BinbunVFX_Vol2/BattleFX/effects/slash/vfx_blank_slash.tscn")
const SHIELD: PackedScene = preload("res://assets/effects/BattleFXFree/BattleFXFree/assets/BinbunVFX_Vol2/BattleFX/effects/shield/vfx_blank_shield_01.tscn")
const EMBER_SLASH: PackedScene = preload("res://emberline/effects/slash_arc.tscn")
const EMBER_RING: PackedScene = preload("res://emberline/effects/impact_ring.tscn")
const PIXELFX_ROOT := "res://assets/effects/pixelfx/"
const ATTACK_FX_AXIS_OFFSET := -PI / 2.0
const SOUND_ROOT := "res://assets/sfx/Free Fantasy SFX Pack By TomMusic/OGG Files/SFX/"
static var _pixel_frames_cache: Dictionary = {}


static func slash(parent: Node3D, position: Vector3, form: String, direction: Vector3, scale: float = 0.42) -> Node3D:
	return _spawn(SLASH, parent, position, form, direction, scale, true, 0.42, ATTACK_FX_AXIS_OFFSET)


static func swing(parent: Node3D, position: Vector3, form: String, direction: Vector3, scale: float = 0.65) -> Node2D:
	return _spawn_pixelfx(parent, "melee/spear-sweep", position, form, direction, scale)


static func claw(parent: Node3D, position: Vector3, form: String, direction: Vector3, scale: float = 0.6) -> Node2D:
	var effect_id := "ice/ice-shatter" if form == "ice" else "melee/claw-swipe"
	return _spawn_pixelfx(parent, effect_id, position, form, direction, scale)


static func impact(parent: Node3D, position: Vector3, form: String, direction: Vector3, scale: float = 0.28) -> Node2D:
	return _spawn_pixelfx(parent, "impacts/hit-spark", position, form, direction, scale)


static func charge(parent: Node3D, position: Vector3, form: String, scale: float = 0.9) -> Node2D:
	return _spawn_pixelfx(parent, "arcane/spell-charge", position, form, Vector3.FORWARD, scale, 1.6)


static func circle_burst(parent: Node3D, position: Vector3, form: String, radius: float) -> Node2D:
	var effect_id := "nature/leaf-storm"
	var duration := 2.4
	match form:
		"fire": effect_id = "fire/fire-ring"
		"ice": effect_id = "ice/frost-nova"
		"lightning": effect_id = "lightning/thunderclap"
		_: duration = clampf(0.8 + radius * 0.08, 1.0, 2.4)
	return _spawn_pixelfx(parent, effect_id, position, form, Vector3.ZERO, radius, duration)


static func tornado(parent: Node3D, position: Vector3, radius: float, duration: float = 2.0) -> Node2D:
	return _spawn_pixelfx(parent, "nature/leaf-storm", position, "wind", Vector3.ZERO, radius, duration)


static func meteor(parent: Node3D, position: Vector3, direction: Vector3, radius: float) -> Node2D:
	charge(parent, position + Vector3.UP * 1.5, "fire", 1.4)
	return _spawn_pixelfx(parent, "fire/fire-ring", position, "fire", direction, radius, 1.0)


static func lightning_strike(parent: Node3D, position: Vector3, scale: float = 2.0) -> Node2D:
	return _spawn_pixelfx(parent, "lightning/thunderclap", position, "lightning", Vector3.ZERO, scale, 0.9)


static func emberline_slash(parent: Node3D, position: Vector3, form: String, direction: Vector3, half_extent: float = 1.15) -> Node2D:
	return _spawn_emberline(EMBER_SLASH, parent, position, form, direction, half_extent)


static func emberline_ring(parent: Node3D, position: Vector3, form: String, direction: Vector3, half_extent: float = 1.2) -> Node2D:
	return _spawn_emberline(EMBER_RING, parent, position, form, direction, half_extent)


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
		"active_lightning_1", "active_lightning_2", "active_lightning_3", "active_lightning_4", "ultimate_lightning_1", "ultimate_lightning_2": relative_path = "Spells/Spell Impact 3.ogg"
		"lightning_hit": relative_path = "Spells/Spell Impact 3.ogg"
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


static func _spawn_pixelfx(parent: Node3D, effect_id: String, position: Vector3, form: String, direction: Vector3, world_half_extent: float, loop_duration: float = 0.0) -> Node2D:
	if not is_instance_valid(parent):
		return null
	var camera := parent.get_viewport().get_camera_3d()
	if camera == null or camera.is_position_behind(position):
		return null
	var stage := parent.get_tree().current_scene
	if stage == null:
		return null
	var frames := _load_pixelfx_frames(effect_id)
	if frames == null:
		return null
	var metadata: Dictionary = _pixel_frames_cache[effect_id + ":metadata"]
	var frame_size: Array = metadata.get("frameSize", [128, 128])
	var frame_width := maxf(float(frame_size[0]), 1.0)
	var pivot: Array = metadata.get("pivot", [frame_width * 0.5, float(frame_size[1]) * 0.5])
	var overlay := stage.get_node_or_null("PixelFXOverlay") as CanvasLayer
	if overlay == null:
		overlay = CanvasLayer.new()
		overlay.name = "PixelFXOverlay"
		overlay.layer = 0
		stage.add_child(overlay)
	var screen_position: Vector2 = camera.unproject_position(position)
	var projected_half_width := (camera.unproject_position(position + camera.global_transform.basis.x * world_half_extent) - screen_position).length()
	var effect := Node2D.new()
	effect.name = effect_id.replace("/", "_")
	effect.position = screen_position
	effect.scale = Vector2.ONE * maxf(projected_half_width / (frame_width * 0.5), 0.01)
	effect.z_index = 10
	overlay.add_child(effect)
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.centered = false
	sprite.offset = -Vector2(float(pivot[0]), float(pivot[1]))
	sprite.animation = "default"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.modulate = _pixelfx_tint(effect_id, form)
	if direction.length_squared() > 0.001:
		var screen_direction := camera.unproject_position(position + direction.normalized()) - screen_position
		if screen_direction.length_squared() > 0.001:
			sprite.rotation = screen_direction.angle()
	effect.add_child(sprite)
	if frames.get_animation_loop("default"):
		var lifetime := loop_duration if loop_duration > 0.0 else 2.4
		var timer := Timer.new()
		timer.one_shot = true
		timer.wait_time = lifetime
		effect.add_child(timer)
		timer.timeout.connect(func() -> void:
			if is_instance_valid(effect):
				var fade := effect.create_tween()
				fade.tween_property(effect, "modulate:a", 0.0, 0.15)
				fade.tween_callback(effect.queue_free))
		timer.start()
	else:
		sprite.animation_finished.connect(effect.queue_free, CONNECT_ONE_SHOT)
	sprite.play()
	return effect


static func _load_pixelfx_frames(effect_id: String) -> SpriteFrames:
	if _pixel_frames_cache.has(effect_id):
		return _pixel_frames_cache[effect_id] as SpriteFrames
	var effect_name := effect_id.get_slice("/", 1)
	var root := PIXELFX_ROOT + effect_id + "/" + effect_name
	var sheet := load(root + ".png") as Texture2D
	var json_file := FileAccess.open(root + ".json", FileAccess.READ)
	if sheet == null or json_file == null:
		push_warning("PixelFX: missing exported sheet or metadata for %s" % effect_id)
		return null
	var document: Variant = JSON.parse_string(json_file.get_as_text())
	if not document is Dictionary or not document.has("frames") or not document.has("meta"):
		push_warning("PixelFX: invalid metadata for %s" % effect_id)
		return null
	var meta: Dictionary = document.meta.get("pixelfx", {})
	var fps := maxf(float(meta.get("fps", 30)), 1.0)
	var sprite_frames := SpriteFrames.new()
	if sprite_frames.has_animation("default"):
		sprite_frames.clear("default")
	else:
		sprite_frames.add_animation("default")
	sprite_frames.set_animation_speed("default", fps)
	sprite_frames.set_animation_loop("default", bool(meta.get("loop", false)))
	for frame_data: Dictionary in document.frames:
		var rect: Dictionary = frame_data.get("frame", {})
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(float(rect.get("x", 0)), float(rect.get("y", 0)), float(rect.get("w", 1)), float(rect.get("h", 1)))
		var frame_duration := maxf(float(frame_data.get("duration", 1000.0 / fps)), 1.0)
		sprite_frames.add_frame("default", atlas, frame_duration / (1000.0 / fps))
	_pixel_frames_cache[effect_id] = sprite_frames
	_pixel_frames_cache[effect_id + ":metadata"] = meta
	return sprite_frames


static func _pixelfx_tint(effect_id: String, form: String) -> Color:
	if effect_id == "impacts/hit-spark":
		match form:
			"wind": return Color("9dfff2")
			"ice": return Color("b5eaff")
			"fire": return Color("ffd080")
			"lightning": return Color("fff39a")
	if effect_id == "nature/leaf-storm" and form == "wind":
		return Color("a7fff0")
	return Color.WHITE


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
		"lightning":
			primary = Color("fff6a6")
			secondary = Color("f4c832")
			tertiary = Color("8f5fc7")
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
