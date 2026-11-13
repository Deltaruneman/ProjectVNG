class_name BattleVFX
extends RefCounted

const SLASH: PackedScene = preload("res://assets/effects/BattleFXFree/BattleFXFree/assets/BinbunVFX_Vol2/BattleFX/effects/slash/vfx_blank_slash.tscn")
const SHIELD: PackedScene = preload("res://assets/effects/BattleFXFree/BattleFXFree/assets/BinbunVFX_Vol2/BattleFX/effects/shield/vfx_blank_shield_01.tscn")
const EMBER_SLASH: PackedScene = preload("res://emberline/effects/slash_arc.tscn")
const EMBER_RING: PackedScene = preload("res://emberline/effects/impact_ring.tscn")
const PIXELFX_ROOT := "res://assets/effects/pixelfx/"
const PVFX_ROOT := "res://assets/effects/pvfx-foundry-thirteen-spritesheets/effects/"
const WORLD_VFX_ANCHOR = preload("res://scenes/player/world_vfx_anchor.gd")
const ATTACK_FX_AXIS_OFFSET := -PI / 2.0
const SKILL_VFX_SPEED_SCALE := 1.2
const SOUND_ROOT := "res://assets/sfx/Free Fantasy SFX Pack By TomMusic/OGG Files/SFX/"
static var _pixel_frames_cache: Dictionary = {}
static var _pvfx_frames_cache: Dictionary = {}

static func horizontal_lightning(parent: Node3D, start: Vector3, finish: Vector3) -> Node3D:
	var frames := _load_pixelfx_frames("lightning/horizontal-beam")
	if frames == null or start.distance_to(finish) < 0.01:
		return null
	var beam := preload("res://scenes/player/horizontal_lightning.gd").new()
	beam.name = "HorizontalLightning"
	beam.start = start
	beam.finish = finish
	var sprite := AnimatedSprite3D.new()
	sprite.sprite_frames = frames
	# The authored beam starts at (41,60) and ends 168 px to its right.
	sprite.offset = Vector2(91, 10)
	sprite.pixel_size = start.distance_to(finish) / 168.0
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sprite.shaded = false
	beam.visual = sprite
	parent.get_tree().current_scene.add_child(beam)
	beam.add_child(sprite)
	sprite.play("default")
	beam._process(0.0)
	return beam


static func slash(parent: Node3D, position: Vector3, form: String, direction: Vector3, scale: float = 0.42) -> Node3D:
	return _spawn(SLASH, parent, position, form, direction, scale, true, 0.42, ATTACK_FX_AXIS_OFFSET)


static func swing(parent: Node3D, position: Vector3, form: String, direction: Vector3, scale: float = 0.65) -> Node2D:
	return _spawn_pixelfx(parent, "melee/spear-sweep", position, form, direction, scale)


static func elemental_orb(projectile: Node3D, form: String, _direction: Vector3) -> AnimatedSprite3D:
	var palette := form if form in ["fire", "ice", "lightning"] else "white"
	var effect_id := "projectiles/orb-" + palette
	var frames := _load_pixelfx_frames(effect_id)
	if frames == null:
		return null
	var metadata: Dictionary = _pixel_frames_cache[effect_id + ":metadata"]
	var frame_size: Array = metadata["frameSize"]
	var pivot: Array = metadata["pivot"]
	var sprite := AnimatedSprite3D.new()
	sprite.name = "OrbVisual"
	sprite.sprite_frames = frames
	sprite.pixel_size = 3.6 / float(frame_size[0])
	sprite.offset = Vector2(float(frame_size[0]) * 0.5 - float(pivot[0]), float(pivot[1]) - float(frame_size[1]) * 0.5)
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sprite.shaded = false
	sprite.no_depth_test = false
	sprite.top_level = true
	sprite.speed_scale = SKILL_VFX_SPEED_SCALE
	projectile.add_child(sprite)
	sprite.global_position = projectile.global_position
	sprite.play("default")
	return sprite


static func claw(parent: Node3D, position: Vector3, form: String, direction: Vector3, scale: float = 0.6) -> Node2D:
	var effect_id := "ice/ice-shatter" if form == "ice" else "melee/claw-swipe"
	return _spawn_pixelfx(parent, effect_id, position, form, direction, scale)


static func impact(parent: Node3D, position: Vector3, form: String, direction: Vector3, scale: float = 0.28, process_while_paused: bool = false) -> Node2D:
	return _spawn_pixelfx(parent, "impacts/hit-spark", position, form, direction, scale, 0.0, process_while_paused)


static func ultimate_impact_frame(parent: Node3D, position: Vector3, form: String) -> Node2D:
	return _spawn_pixelfx(parent, "impacts/impact-frame", position, form, Vector3.ZERO, 10.5, 0.0, true)


static func parry_success(player: Node3D, attacker: Node3D = null) -> Node2D:
	var direction_node := player.get_node("Direction") as Node3D
	var contact_direction := direction_node.global_basis.z
	if is_instance_valid(attacker):
		contact_direction = attacker.global_position - player.global_position
	contact_direction.y = 0.0
	if contact_direction.length_squared() < 0.001:
		contact_direction = direction_node.global_basis.z
	contact_direction = contact_direction.normalized()
	var contact := player.global_position + Vector3.UP * 0.9 + contact_direction * 0.65
	# Keep the spark fan upright: the source draws contact 30 pixels above its ground pivot.
	var effect := _spawn_pixelfx(player, "impacts/parry", contact, "", Vector3.ZERO, 2.4)
	if effect != null:
		var sprite := effect.get_child(0) as AnimatedSprite2D
		sprite.position.y = 30.0
		sprite.speed_scale = 1.5
	play_skill_sound(player, "parry_success")
	return effect


static func play_pvfx(parent: Node3D, effect_id: String, position: Vector3, world_half_extent: float, tint: Color = Color.WHITE, direction: Vector3 = Vector3.ZERO, loop_duration: float = 0.0) -> Node2D:
	return _spawn_pvfx(parent, effect_id, position, world_half_extent, tint, direction, loop_duration)


static func ultimate_impact(parent: Node3D, effect_id: String, position: Vector3, world_half_extent: float, tint: Color = Color.WHITE, direction: Vector3 = Vector3.ZERO, loop_duration: float = 0.0) -> Node2D:
	return play_pvfx(parent, effect_id, position, world_half_extent, tint, direction, loop_duration)


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
	return play_pvfx(parent, "fire/meteor-strike", position, radius, Color("fff4e4"), direction)


static func lightning_strike(parent: Node3D, position: Vector3, scale: float = 2.0) -> Node2D:
	return _spawn_pixelfx(parent, "lightning/thunderclap", position, "lightning", Vector3.ZERO, scale, 0.9)


static func enemy_status(target: Node3D, status_id: String, duration: float) -> void:
	if not is_instance_valid(target):
		return
	match status_id:
		"burning":
			_attach_status_fx(target, "BattleStatusBurning", "pvfx", "status/burning-aura", duration, 0.48, 0.76, Vector3.UP * 0.9)
		"slowed":
			_attach_status_fx(target, "BattleStatusIceSlow", "pvfx", "status/frozen-chill", duration, 0.52, 0.76, Vector3.UP * 0.9)
			_attach_status_fx(target, "BattleStatusSlowClock", "pixelfx", "status/slowed", duration, 0.2, 0.96, Vector3.UP * 1.7)
		"frozen":
			_attach_status_one_shot(target, "BattleStatusFreezeHit", "ice/freeze-encase", 0.48, Vector3.UP * 0.9)
		"electrified":
			# The Pixelfx character pivot is near its feet; lift its centered frame to align that pivot with the enemy origin.
			_attach_status_fx(target, "BattleStatusElectrified", "pixelfx", "lightning/electrified", duration, 0.4, 0.92, Vector3.UP * 0.75)


static func dash_trail_start(player: Node3D, direction: Vector3) -> void:
	if not is_instance_valid(player):
		return
	dash_trail_afterimage(player, direction)
	_spawn_dash_dust(player, direction)


static func dash_trail_afterimage(player: Node3D, direction: Vector3) -> void:
	if not is_instance_valid(player):
		return
	var source := player.get_node_or_null("Sprite3D") as Sprite3D
	var stage := player.get_tree().current_scene as Node3D
	if source == null or stage == null:
		return
	var afterimage := source.duplicate() as Sprite3D
	if afterimage == null:
		return
	afterimage.name = "DashAfterimage"
	afterimage.top_level = true
	afterimage.alpha_cut = SpriteBase3D.ALPHA_CUT_DISABLED
	afterimage.modulate = Color(0.55, 0.84, 1.0, 0.62)
	stage.add_child(afterimage)
	afterimage.global_transform = source.global_transform
	if direction.length_squared() > 0.001:
		afterimage.global_position -= direction.normalized() * 0.06
	var fade := afterimage.create_tween()
	fade.tween_property(afterimage, "modulate", Color(0.55, 0.84, 1.0, 0.0), 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	fade.tween_callback(afterimage.queue_free)


static func _spawn_dash_dust(player: Node3D, direction: Vector3) -> void:
	var stage := player.get_tree().current_scene as Node3D
	if stage == null:
		return
	var frames := _load_pvfx_frames("smoke/dash-dust")
	if frames == null:
		return
	var dust := _make_status_sprite("DashDust", frames, 0.3, 0.9, Vector3.ZERO)
	dust.top_level = true
	stage.add_child(dust)
	dust.global_position = player.global_position + Vector3.UP * 0.08
	var camera := player.get_viewport().get_camera_3d()
	if camera != null and direction.length_squared() > 0.001:
		var screen_start := camera.unproject_position(dust.global_position)
		var screen_direction := camera.unproject_position(dust.global_position + direction.normalized()) - screen_start
		if screen_direction.length_squared() > 0.001:
			dust.rotation.z = screen_direction.angle()
	dust.animation_finished.connect(dust.queue_free, CONNECT_ONE_SHOT)
	dust.play("default")


static func emberline_slash(parent: Node3D, position: Vector3, form: String, direction: Vector3, half_extent: float = 1.15) -> Node2D:
	return _spawn_emberline(EMBER_SLASH, parent, position, form, direction, half_extent)


static func emberline_ring(parent: Node3D, position: Vector3, form: String, direction: Vector3, half_extent: float = 1.2) -> Node2D:
	return _spawn_emberline(EMBER_RING, parent, position, form, direction, half_extent)


static func play_skill_sound(parent: Node3D, skill_id: String) -> void:
	var relative_path := ""
	var pitch_scale := 1.0
	var volume_db := -5.0
	match skill_id:
		"orb_white": relative_path = "Spells/Spell Impact 1.ogg"
		"parry_success":
			relative_path = "Attacks/Sword Attacks Hits and Blocks/Sword Parry 1.ogg"
			volume_db = -2.0
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
		"active_lightning_1":
			relative_path = "Spells/Spell Impact 3.ogg"
			pitch_scale = 1.32
			volume_db = -4.0
		"active_lightning_2":
			relative_path = "Spells/Spell Impact 2.ogg"
			pitch_scale = 0.92
			volume_db = -4.5
		"active_lightning_3":
			relative_path = "Spells/Spell Impact 1.ogg"
			pitch_scale = 1.16
			volume_db = -3.5
		"active_lightning_4":
			relative_path = "Spells/Spell Impact 3.ogg"
			pitch_scale = 0.72
			volume_db = -3.0
		"ultimate_lightning_1":
			relative_path = "Spells/Spell Impact 2.ogg"
			pitch_scale = 0.68
			volume_db = -1.5
		"ultimate_lightning_2":
			relative_path = "Spells/Spell Impact 1.ogg"
			pitch_scale = 0.78
			volume_db = -0.5
		"lightning_hit":
			relative_path = "Spells/Spell Impact 3.ogg"
			pitch_scale = 1.55
			volume_db = -8.0
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
	audio.volume_db = volume_db
	audio.pitch_scale = pitch_scale
	audio.bus = "SFX" if AudioServer.get_bus_index("SFX") >= 0 else "Master"
	parent.add_child(audio)
	audio.finished.connect(audio.queue_free, CONNECT_ONE_SHOT)
	audio.play()


static func shield(parent: Node3D, position: Vector3, form: String, duration: float = 8.0, scale: float = 1.0) -> Node3D:
	return _spawn(SHIELD, parent, position, form, Vector3.FORWARD, scale, true, duration, 0.0)


static func _spawn_pixelfx(parent: Node3D, effect_id: String, position: Vector3, form: String, direction: Vector3, world_half_extent: float, loop_duration: float = 0.0, process_while_paused: bool = false) -> Node2D:
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
	var overlay: CanvasLayer
	if process_while_paused:
		overlay = CanvasLayer.new()
		overlay.name = "PausedPixelFXOverlay"
		overlay.layer = 21
		overlay.process_mode = Node.PROCESS_MODE_ALWAYS
		stage.add_child(overlay)
	else:
		overlay = stage.get_node_or_null("PixelFXOverlay") as CanvasLayer
		if overlay == null:
			overlay = CanvasLayer.new()
			overlay.name = "PixelFXOverlay"
			overlay.layer = 0
			stage.add_child(overlay)
	var screen_position: Vector2 = camera.unproject_position(position)
	var projected_half_width := (camera.unproject_position(position + camera.global_transform.basis.x * world_half_extent) - screen_position).length()
	var effect: Node2D = Node2D.new() if process_while_paused else WORLD_VFX_ANCHOR.new()
	effect.name = effect_id.replace("/", "_")
	if process_while_paused:
		effect.process_mode = Node.PROCESS_MODE_ALWAYS
	effect.position = screen_position
	effect.scale = Vector2.ONE * maxf(projected_half_width / (frame_width * 0.5), 0.01)
	effect.z_index = 10
	overlay.add_child(effect)
	var sprite := AnimatedSprite2D.new()
	if process_while_paused:
		sprite.process_mode = Node.PROCESS_MODE_ALWAYS
	sprite.sprite_frames = frames
	sprite.speed_scale = SKILL_VFX_SPEED_SCALE
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
	if not process_while_paused:
		effect.call("configure", camera, position, direction, world_half_extent, frame_width * 0.5, sprite)
	if process_while_paused:
		effect.tree_exited.connect(overlay.queue_free, CONNECT_ONE_SHOT)
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


static func _spawn_pvfx(parent: Node3D, effect_id: String, position: Vector3, world_half_extent: float, tint: Color, direction: Vector3 = Vector3.ZERO, loop_duration: float = 0.0) -> Node2D:
	if not is_instance_valid(parent):
		return null
	var camera := parent.get_viewport().get_camera_3d()
	if camera == null or camera.is_position_behind(position):
		return null
	var stage := parent.get_tree().current_scene
	if stage == null:
		return null
	var frames := _load_pvfx_frames(effect_id)
	if frames == null:
		return null
	var cache_key := "pvfx:" + effect_id
	var metadata: Dictionary = _pvfx_frames_cache.get(cache_key + ":metadata", {})
	var frame_size: Array = metadata.get("source_size", [96, 96])
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
	var effect: Node2D = WORLD_VFX_ANCHOR.new()
	effect.name = effect_id.replace("/", "_")
	effect.position = screen_position
	effect.scale = Vector2.ONE * maxf(projected_half_width / (frame_width * 0.5), 0.01)
	effect.z_index = 12
	overlay.add_child(effect)
	var sprite := AnimatedSprite2D.new()
	sprite.sprite_frames = frames
	sprite.speed_scale = SKILL_VFX_SPEED_SCALE
	sprite.centered = false
	sprite.offset = -Vector2(float(pivot[0]), float(pivot[1]))
	sprite.animation = "default"
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.modulate = tint
	if direction.length_squared() > 0.001:
		var screen_direction := camera.unproject_position(position + direction.normalized()) - screen_position
		if screen_direction.length_squared() > 0.001:
			sprite.rotation = screen_direction.angle()
	effect.add_child(sprite)
	effect.call("configure", camera, position, direction, world_half_extent, frame_width * 0.5, sprite)
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


static func _attach_status_fx(target: Node3D, node_name: String, source: String, effect_id: String, duration: float, effect_scale: float, alpha: float, local_position: Vector3) -> AnimatedSprite3D:
	if duration <= 0.0:
		return null
	var existing := target.get_node_or_null(node_name) as AnimatedSprite3D
	if existing != null:
		var existing_timer := existing.get_node_or_null("Duration") as Timer
		if existing_timer != null:
			existing_timer.start(duration)
		return existing
	var frames := _load_status_frames(source, effect_id)
	if frames == null:
		return null
	var sprite := _make_status_sprite(node_name, frames, effect_scale, alpha, local_position)
	target.add_child(sprite)
	sprite.play("default")
	var timer := Timer.new()
	timer.name = "Duration"
	timer.one_shot = true
	timer.wait_time = duration
	timer.timeout.connect(sprite.queue_free, CONNECT_ONE_SHOT)
	sprite.add_child(timer)
	timer.start()
	return sprite


static func _attach_status_one_shot(target: Node3D, node_name: String, effect_id: String, effect_scale: float, local_position: Vector3) -> AnimatedSprite3D:
	var existing := target.get_node_or_null(node_name) as AnimatedSprite3D
	if existing != null:
		existing.stop()
		existing.frame = 0
		existing.play("default")
		return existing
	var frames := _load_pvfx_frames(effect_id)
	if frames == null:
		return null
	var sprite := _make_status_sprite(node_name, frames, effect_scale, 0.9, local_position)
	target.add_child(sprite)
	sprite.animation_finished.connect(sprite.queue_free, CONNECT_ONE_SHOT)
	sprite.play("default")
	return sprite


static func _make_status_sprite(node_name: String, frames: SpriteFrames, effect_scale: float, alpha: float, local_position: Vector3) -> AnimatedSprite3D:
	var sprite := AnimatedSprite3D.new()
	sprite.name = node_name
	sprite.sprite_frames = frames
	sprite.animation = "default"
	sprite.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	sprite.shaded = false
	sprite.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	sprite.pixel_size = 0.0625
	sprite.scale = Vector3.ONE * effect_scale
	sprite.position = local_position + Vector3(0.0, 0.0, 0.04)
	sprite.modulate = Color(1.0, 1.0, 1.0, alpha)
	sprite.centered = true
	sprite.render_priority = 1
	return sprite


static func _load_status_frames(source: String, effect_id: String) -> SpriteFrames:
	if source == "pixelfx":
		return _load_pixelfx_frames(effect_id)
	return _load_pvfx_frames(effect_id)


static func _load_pvfx_frames(effect_id: String) -> SpriteFrames:
	var cache_key := "pvfx:" + effect_id
	if _pvfx_frames_cache.has(cache_key):
		return _pvfx_frames_cache[cache_key] as SpriteFrames
	var root := PVFX_ROOT + effect_id + "/lit/grid/"
	var sheet := load(root + "sprite-sheet.png") as Texture2D
	var manifest_file := FileAccess.open(root + "manifest.json", FileAccess.READ)
	if sheet == null or manifest_file == null:
		push_warning("PVFX: missing sheet or manifest for %s" % effect_id)
		return null
	var document: Variant = JSON.parse_string(manifest_file.get_as_text())
	if not document is Dictionary or not document.has("frames"):
		push_warning("PVFX: invalid manifest for %s" % effect_id)
		return null
	var sprite_frames := SpriteFrames.new()
	if sprite_frames.has_animation("default"):
		sprite_frames.clear("default")
	else:
		sprite_frames.add_animation("default")
	var fps := 30.0
	sprite_frames.set_animation_speed("default", fps)
	sprite_frames.set_animation_loop("default", str(document.get("loop_mode", "none")) == "loop")
	for frame_data: Dictionary in document.frames:
		var rect: Dictionary = frame_data.get("sheet", {})
		var atlas := AtlasTexture.new()
		atlas.atlas = sheet
		atlas.region = Rect2(float(rect.get("x", 0)), float(rect.get("y", 0)), float(rect.get("width", 1)), float(rect.get("height", 1)))
		var timing: Dictionary = frame_data.get("duration", {})
		var denominator := maxf(float(timing.get("denominator", 1.0)), 0.001)
		var duration_seconds := maxf(float(timing.get("numerator_ms", 100.0)) / denominator / 1000.0, 0.001)
		sprite_frames.add_frame("default", atlas, duration_seconds * fps)
	_pvfx_frames_cache[cache_key] = sprite_frames
	_pvfx_frames_cache[cache_key + ":metadata"] = document
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
