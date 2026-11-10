extends Node

signal finished(kind: StringName)
signal aborted(kind: StringName)

const BattleVFX := preload("res://scenes/player/battle_vfx.gd")

const INTRO := &"intro"
const DEFEAT := &"defeat"
const INTRO_ZOOM_DURATION := 0.42
const INTRO_TITLE_DURATION := 0.62
const INTRO_REVEAL_DURATION := 0.46
const DEFEAT_BLACKOUT_DURATION := 0.24
const DEFEAT_SLASH_DURATION := 0.12
const DEFEAT_SPLIT_DURATION := 0.38
const DEFEAT_HOLD_DURATION := 0.22
const DEFEAT_FADE_DURATION := 0.34
const ZOOM_RATIO := 0.72

enum IntroPhase { ZOOM_IN, TITLE, REVEAL }
enum DefeatPhase { BLACKOUT, SLASH, SPLIT, HOLD, FADE_OUT }

var _boss: Node3D
var _camera: Camera3D
var _tree: SceneTree
var _kind: StringName
var _phase := 0
var _elapsed := 0.0
var _resolved := false
var _keep_defeated_boss_hidden := false
var _was_paused := false
var _saved_camera_transform := Transform3D.IDENTITY
var _saved_camera_fov := 30.0
var _focused_camera_position := Vector3.ZERO
var _boss_sprite: Sprite3D
var _saved_sprite_visible := true
var _boss_hud: CanvasLayer
var _saved_hud_visible := true

var _backdrop: ColorRect
var _impact_flash: ColorRect
var _impact_flash_color := Color.WHITE
var _impact_flash_alpha := 0.0
var _impact_flash_decay := 5.0
var _overlay: CanvasLayer
var _foreground: CanvasLayer
var _impact_band_top: Polygon2D
var _impact_band_bottom: Polygon2D
var _impact_band_accent_top: Polygon2D
var _impact_band_accent_bottom: Polygon2D
var _title_layer: CanvasLayer
var _boss_title: Label
var _subtitle: Label
var _slash_outline: Polygon2D
var _slash_core: Polygon2D
var _slash_accent: Polygon2D
var _left_half: Sprite2D
var _right_half: Sprite2D
var _halves_center := Vector2.ZERO
var _half_screen_size := Vector2.ZERO
var _left_start := Vector2.ZERO
var _right_start := Vector2.ZERO


func begin(boss: Node3D, player: Node3D, camera: Camera3D, kind: StringName) -> bool:
	if not is_instance_valid(boss) or not is_instance_valid(camera):
		_resolved = true
		return false
	if kind != INTRO and kind != DEFEAT:
		_resolved = true
		return false
	if kind == INTRO and not is_instance_valid(player):
		_resolved = true
		return false
	_boss = boss
	_camera = camera
	_tree = boss.get_tree()
	if _tree == null or _tree.paused:
		_resolved = true
		return false
	_kind = kind
	_was_paused = _tree.paused
	_saved_camera_transform = camera.global_transform
	_saved_camera_fov = camera.fov
	_boss_sprite = boss.get_node_or_null("Sprite3D") as Sprite3D
	_focused_camera_position = _calculate_focused_camera_position()
	_boss_hud = boss.get_node_or_null("BossHUD") as CanvasLayer
	if is_instance_valid(_boss_sprite):
		_saved_sprite_visible = _boss_sprite.visible
	if is_instance_valid(_boss_hud):
		_saved_hud_visible = _boss_hud.visible
	_create_overlay()
	if kind == INTRO:
		_phase = IntroPhase.ZOOM_IN
		_set_boss_hud_visible(false)
	else:
		_phase = DefeatPhase.BLACKOUT
		_set_boss_hud_visible(false)
	_tree.paused = true
	return true


func _process(delta: float) -> void:
	if _resolved:
		return
	_update_fullscreen_impact(delta)
	if not is_instance_valid(_boss) or not is_instance_valid(_camera):
		_abort()
		return
	_elapsed += delta
	if _kind == INTRO:
		_process_intro()
	else:
		_process_defeat()


func _process_intro() -> void:
	match _phase:
		IntroPhase.ZOOM_IN:
			var progress := clampf(_elapsed / INTRO_ZOOM_DURATION, 0.0, 1.0)
			var eased := _ease_in_out(progress)
			var zoom_fov := maxf(_saved_camera_fov * ZOOM_RATIO, 12.0)
			_apply_camera_pose(_saved_camera_transform.origin.lerp(_focused_camera_position, eased), lerpf(_saved_camera_fov, zoom_fov, eased))
			_backdrop.color = Color(0.012, 0.01, 0.026, 0.56 * eased)
			if progress >= 1.0:
				_phase = IntroPhase.TITLE
				_elapsed = 0.0
				_title_layer.visible = true
				_boss_title.modulate.a = 1.0
				_subtitle.modulate.a = 1.0
				_update_title_layout()
				_trigger_fullscreen_impact(Color(0.82, 0.72, 1.0), 0.82, 0.42)
				var impact_position := _boss.global_position + Vector3.UP * 1.1
				if is_instance_valid(_boss_sprite):
					impact_position = _boss_sprite.global_position
				BattleVFX.ultimate_impact_frame(_boss, impact_position, "wind")
		IntroPhase.TITLE:
			_apply_camera_pose(_focused_camera_position, maxf(_saved_camera_fov * ZOOM_RATIO, 12.0))
			_backdrop.color = Color(0.012, 0.01, 0.026, 0.56)
			if _elapsed >= INTRO_TITLE_DURATION:
				_set_boss_hud_visible(true)
				_phase = IntroPhase.REVEAL
				_elapsed = 0.0
		IntroPhase.REVEAL:
			var progress := clampf(_elapsed / INTRO_REVEAL_DURATION, 0.0, 1.0)
			var eased := _ease_in_out(progress)
			var zoom_fov := maxf(_saved_camera_fov * ZOOM_RATIO, 12.0)
			_apply_camera_pose(_focused_camera_position.lerp(_saved_camera_transform.origin, eased), lerpf(zoom_fov, _saved_camera_fov, eased))
			_backdrop.color = Color(0.012, 0.01, 0.026, 0.56 * (1.0 - eased))
			_boss_title.modulate.a = 1.0 - eased
			_subtitle.modulate.a = 1.0 - eased
			if progress >= 1.0:
				_finish()


func _process_defeat() -> void:
	match _phase:
		DefeatPhase.BLACKOUT:
			var progress := clampf(_elapsed / DEFEAT_BLACKOUT_DURATION, 0.0, 1.0)
			var eased := _ease_in_out(progress)
			_apply_camera_pose(_saved_camera_transform.origin.lerp(_focused_camera_position, eased), lerpf(_saved_camera_fov, maxf(_saved_camera_fov * ZOOM_RATIO, 12.0), eased))
			_backdrop.color = Color(0.0, 0.0, 0.0, eased)
			if progress >= 1.0:
				if not _create_split_halves():
					_abort()
					return
				_phase = DefeatPhase.SLASH
				_elapsed = 0.0
				_set_slash(1.0)
				_trigger_fullscreen_impact(Color(0.88, 0.78, 1.0), 0.96, 0.16)
		DefeatPhase.SLASH:
			_set_slash(1.0)
			if _elapsed >= DEFEAT_SLASH_DURATION:
				_phase = DefeatPhase.SPLIT
				_elapsed = 0.0
		DefeatPhase.SPLIT:
			var progress := clampf(_elapsed / DEFEAT_SPLIT_DURATION, 0.0, 1.0)
			var eased := _ease_out(progress)
			var travel := maxf(_half_screen_size.x * 0.58, 24.0)
			_left_half.position = _left_start - Vector2(travel * eased, 0.0)
			_right_half.position = _right_start + Vector2(travel * eased, 0.0)
			_set_slash(1.0 - progress)
			if progress >= 1.0:
				_phase = DefeatPhase.HOLD
				_elapsed = 0.0
				_set_slash(0.0)
		DefeatPhase.HOLD:
			if _elapsed >= DEFEAT_HOLD_DURATION:
				_phase = DefeatPhase.FADE_OUT
				_elapsed = 0.0
		DefeatPhase.FADE_OUT:
			var progress := clampf(_elapsed / DEFEAT_FADE_DURATION, 0.0, 1.0)
			var eased := _ease_in_out(progress)
			_apply_camera_pose(_focused_camera_position.lerp(_saved_camera_transform.origin, eased), lerpf(maxf(_saved_camera_fov * ZOOM_RATIO, 12.0), _saved_camera_fov, eased))
			_backdrop.color = Color(0.0, 0.0, 0.0, 1.0 - eased)
			if is_instance_valid(_left_half):
				_left_half.modulate.a = 1.0 - eased
			if is_instance_valid(_right_half):
				_right_half.modulate.a = 1.0 - eased
			if progress >= 1.0:
				_keep_defeated_boss_hidden = true
				_finish()


func _create_overlay() -> void:
	_overlay = CanvasLayer.new()
	_overlay.name = "DarkFairyCinematicBackdrop"
	_overlay.layer = 20
	_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_overlay)
	_backdrop = ColorRect.new()
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_backdrop.color = Color(0.012, 0.01, 0.026, 0.0)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(_backdrop)
	_impact_flash = ColorRect.new()
	_impact_flash.name = "FullScreenImpactFlash"
	_impact_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_impact_flash.color = Color(1.0, 1.0, 1.0, 0.0)
	_impact_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(_impact_flash)

	_foreground = CanvasLayer.new()
	_foreground.name = "DarkFairyCinematicForeground"
	_foreground.layer = 22
	_foreground.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_foreground)
	_impact_band_top = Polygon2D.new()
	_impact_band_top.color = Color(0.008, 0.006, 0.016, 0.0)
	_impact_band_top.z_index = 1
	_foreground.add_child(_impact_band_top)
	_impact_band_bottom = Polygon2D.new()
	_impact_band_bottom.color = Color(0.008, 0.006, 0.016, 0.0)
	_impact_band_bottom.z_index = 1
	_foreground.add_child(_impact_band_bottom)
	_impact_band_accent_top = Polygon2D.new()
	_impact_band_accent_top.color = Color(0.82, 0.72, 1.0, 0.0)
	_impact_band_accent_top.z_index = 2
	_foreground.add_child(_impact_band_accent_top)
	_impact_band_accent_bottom = Polygon2D.new()
	_impact_band_accent_bottom.color = Color(0.82, 0.72, 1.0, 0.0)
	_impact_band_accent_bottom.z_index = 2
	_foreground.add_child(_impact_band_accent_bottom)
	_layout_impact_bands()
	_slash_outline = Polygon2D.new()
	_slash_outline.color = Color(0.015, 0.01, 0.025, 0.98)
	_slash_outline.z_index = 10
	_foreground.add_child(_slash_outline)
	_slash_core = Polygon2D.new()
	_slash_core.color = Color(0.96, 0.97, 1.0, 1.0)
	_slash_core.z_index = 11
	_foreground.add_child(_slash_core)
	_slash_accent = Polygon2D.new()
	_slash_accent.color = Color(0.78, 0.69, 1.0, 1.0)
	_slash_accent.z_index = 12
	_foreground.add_child(_slash_accent)

	_title_layer = CanvasLayer.new()
	_title_layer.name = "DarkFairyCinematicTitle"
	_title_layer.layer = 23
	_title_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	_title_layer.visible = false
	add_child(_title_layer)
	_subtitle = Label.new()
	_subtitle.text = "BOSS ENCOUNTER"
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_subtitle.add_theme_color_override("font_color", Color(0.78, 0.69, 1.0))
	_subtitle.add_theme_font_size_override("font_size", 11)
	_subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_layer.add_child(_subtitle)
	_boss_title = Label.new()
	_boss_title.text = "DARK FAIRY"
	_boss_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_boss_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_boss_title.add_theme_color_override("font_color", Color("11121a"))
	_boss_title.add_theme_font_size_override("font_size", 26)
	_boss_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_layer.add_child(_boss_title)
	_update_title_layout()


func _calculate_focused_camera_position() -> Vector3:
	var target_position := _boss.global_position + Vector3.UP * 1.1
	if is_instance_valid(_boss_sprite):
		target_position = _boss_sprite.global_position
	if _camera.is_position_behind(target_position):
		return _saved_camera_transform.origin
	var camera_basis := _saved_camera_transform.basis
	var to_target := target_position - _saved_camera_transform.origin
	var depth := -to_target.dot(camera_basis.z.normalized())
	if depth <= 0.01:
		return _saved_camera_transform.origin
	var camera_right := camera_basis.x.normalized()
	var camera_up := camera_basis.y.normalized()
	var horizontal_shift := to_target.dot(camera_right)
	var vertical_shift := to_target.dot(camera_up)
	return _saved_camera_transform.origin + camera_right * horizontal_shift + camera_up * vertical_shift


func _apply_camera_pose(camera_position: Vector3, camera_fov: float) -> void:
	if not is_instance_valid(_camera):
		return
	var camera_transform := _saved_camera_transform
	camera_transform.origin = camera_position
	_camera.global_transform = camera_transform
	_camera.fov = camera_fov


func _layout_impact_bands() -> void:
	if _impact_band_top == null or _impact_band_bottom == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var width := viewport_size.x
	var height := viewport_size.y
	_impact_band_top.polygon = PackedVector2Array([
		Vector2.ZERO,
		Vector2(width, 0.0),
		Vector2(width, height * 0.16),
		Vector2(0.0, height * 0.24),
	])
	_impact_band_bottom.polygon = PackedVector2Array([
		Vector2(0.0, height * 0.76),
		Vector2(width, height * 0.84),
		Vector2(width, height),
		Vector2(0.0, height),
	])
	_impact_band_accent_top.polygon = PackedVector2Array([
		Vector2(0.0, height * 0.24),
		Vector2(width, height * 0.16),
		Vector2(width, height * 0.175),
		Vector2(0.0, height * 0.255),
	])
	_impact_band_accent_bottom.polygon = PackedVector2Array([
		Vector2(0.0, height * 0.745),
		Vector2(width, height * 0.825),
		Vector2(width, height * 0.84),
		Vector2(0.0, height * 0.76),
	])


func _trigger_fullscreen_impact(color: Color, strength: float, fade_duration: float) -> void:
	_impact_flash_color = color
	_impact_flash_alpha = clampf(strength, 0.0, 1.0)
	_impact_flash_decay = _impact_flash_alpha / maxf(fade_duration, 0.01)
	if is_instance_valid(_impact_flash):
		_impact_flash.visible = true
	if is_instance_valid(_impact_band_top):
		_impact_band_top.visible = true
		_impact_band_bottom.visible = true
		_impact_band_accent_top.visible = true
		_impact_band_accent_bottom.visible = true
	_update_fullscreen_impact(0.0)


func _update_fullscreen_impact(delta: float) -> void:
	if _impact_flash_alpha <= 0.0:
		return
	_impact_flash_alpha = move_toward(_impact_flash_alpha, 0.0, _impact_flash_decay * delta)
	if is_instance_valid(_impact_flash):
		_impact_flash.color = Color(_impact_flash_color.r, _impact_flash_color.g, _impact_flash_color.b, _impact_flash_alpha)
		_impact_flash.visible = _impact_flash_alpha > 0.01
	if is_instance_valid(_impact_band_top):
		_impact_band_top.color = Color(0.008, 0.006, 0.016, _impact_flash_alpha * 0.9)
		_impact_band_bottom.color = _impact_band_top.color
		_impact_band_accent_top.color = Color(_impact_flash_color.r, _impact_flash_color.g, _impact_flash_color.b, _impact_flash_alpha)
		_impact_band_accent_bottom.color = _impact_band_accent_top.color
		var bands_visible := _impact_flash_alpha > 0.01
		_impact_band_top.visible = bands_visible
		_impact_band_bottom.visible = bands_visible
		_impact_band_accent_top.visible = bands_visible
		_impact_band_accent_bottom.visible = bands_visible


func _create_split_halves() -> bool:
	if not is_instance_valid(_boss_sprite) or _boss_sprite.texture == null:
		return false
	if _camera.is_position_behind(_boss_sprite.global_position):
		return false
	var hframes := maxi(_boss_sprite.hframes, 1)
	var vframes := maxi(_boss_sprite.vframes, 1)
	var texture_size := _boss_sprite.texture.get_size()
	var frame_size := Vector2(float(texture_size.x), float(texture_size.y)) / Vector2(hframes, vframes)
	if frame_size.x < 2.0 or frame_size.y < 1.0:
		return false
	var frame := clampi(_boss_sprite.frame, 0, hframes * vframes - 1)
	var frame_origin := Vector2(frame % hframes, floori(float(frame) / float(hframes))) * frame_size
	var left_width := floorf(frame_size.x * 0.5)
	var right_width := frame_size.x - left_width
	var left_region := Rect2(frame_origin, Vector2(left_width, frame_size.y))
	var right_region := Rect2(frame_origin + Vector2(left_width, 0.0), Vector2(right_width, frame_size.y))

	var frame_world_width := frame_size.x * _boss_sprite.pixel_size
	var frame_world_height := frame_size.y * _boss_sprite.pixel_size
	var camera_right := _camera.global_transform.basis.x.normalized()
	var camera_up := _camera.global_transform.basis.y.normalized()
	var sprite_center := _boss_sprite.global_position
	var screen_left := _camera.unproject_position(sprite_center - camera_right * frame_world_width * 0.5)
	var screen_right := _camera.unproject_position(sprite_center + camera_right * frame_world_width * 0.5)
	var screen_top := _camera.unproject_position(sprite_center + camera_up * frame_world_height * 0.5)
	var screen_bottom := _camera.unproject_position(sprite_center - camera_up * frame_world_height * 0.5)
	var full_width := absf(screen_right.x - screen_left.x)
	var full_height := absf(screen_bottom.y - screen_top.y)
	if full_width <= 1.0 or full_height <= 1.0:
		return false

	_halves_center = _camera.unproject_position(sprite_center)
	_half_screen_size = Vector2(full_width * 0.5, full_height)
	_left_start = _halves_center - Vector2(full_width * 0.25, 0.0)
	_right_start = _halves_center + Vector2(full_width * 0.25, 0.0)
	var displayed_left_region := right_region if _boss_sprite.flip_h else left_region
	var displayed_right_region := left_region if _boss_sprite.flip_h else right_region
	var half_scale := Vector2(full_width / frame_size.x, full_height / frame_size.y)
	_left_half = _make_split_half(displayed_left_region, _left_start, half_scale)
	_right_half = _make_split_half(displayed_right_region, _right_start, half_scale)
	if _left_half == null or _right_half == null:
		return false
	_boss_sprite.visible = false
	return true


func _make_split_half(region: Rect2, screen_position: Vector2, half_scale: Vector2) -> Sprite2D:
	var atlas := AtlasTexture.new()
	atlas.atlas = _boss_sprite.texture
	atlas.region = region
	var half := Sprite2D.new()
	half.texture = atlas
	half.centered = true
	half.flip_h = _boss_sprite.flip_h
	half.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	half.modulate = _boss_sprite.modulate
	half.position = screen_position
	half.scale = half_scale
	_foreground.add_child(half)
	return half


func _set_slash(strength: float) -> void:
	var amount := clampf(strength, 0.0, 1.0)
	var viewport_size := get_viewport().get_visible_rect().size
	var length := maxf(viewport_size.length() * 2.0, 96.0) * amount
	var outline_width := maxf(viewport_size.y * 0.035, 14.0) * amount
	var core_width := maxf(viewport_size.y * 0.014, 6.0) * amount
	var accent_width := maxf(viewport_size.y * 0.004, 2.0) * amount
	var angle := deg_to_rad(-38.0)
	var center := _halves_center
	_slash_outline.polygon = _rotated_rect(center, Vector2(length, outline_width), angle)
	_slash_core.polygon = _rotated_rect(center, Vector2(length * 0.98, core_width), angle)
	_slash_accent.polygon = _rotated_rect(center + Vector2(0.0, 4.0 * amount), Vector2(length * 0.92, accent_width), angle)
	_slash_outline.visible = amount > 0.01
	_slash_core.visible = amount > 0.01
	_slash_accent.visible = amount > 0.01


func _rotated_rect(center: Vector2, rect_size: Vector2, angle: float) -> PackedVector2Array:
	var direction := Vector2.RIGHT.rotated(angle)
	var normal := Vector2(-direction.y, direction.x)
	var along := direction * rect_size.x * 0.5
	var across := normal * rect_size.y * 0.5
	return PackedVector2Array([
		center - along - across,
		center + along - across,
		center + along + across,
		center - along + across,
	])


func _update_title_layout() -> void:
	if _title_layer == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	var center_y := viewport_size.y * 0.68
	_boss_title.size = Vector2(viewport_size.x - 32.0, 42.0)
	_boss_title.position = Vector2(16.0, center_y - 20.0)
	_boss_title.pivot_offset = _boss_title.size * 0.5
	_subtitle.size = Vector2(viewport_size.x - 32.0, 20.0)
	_subtitle.position = Vector2(16.0, center_y - 47.0)


func _set_boss_hud_visible(show_hud: bool) -> void:
	if is_instance_valid(_boss_hud):
		_boss_hud.visible = show_hud


func _ease_in_out(value: float) -> float:
	return value * value * (3.0 - 2.0 * value)


func _ease_out(value: float) -> float:
	return 1.0 - pow(1.0 - value, 3.0)


func _finish() -> void:
	if _resolved:
		return
	_resolved = true
	_restore_game_state(_kind != DEFEAT or not _keep_defeated_boss_hidden)
	finished.emit(_kind)
	queue_free()


func _abort() -> void:
	if _resolved:
		return
	_resolved = true
	_restore_game_state(true)
	aborted.emit(_kind)
	queue_free()


func _restore_game_state(restore_boss_appearance: bool) -> void:
	if is_instance_valid(_overlay):
		_overlay.visible = false
	if is_instance_valid(_foreground):
		_foreground.visible = false
	if is_instance_valid(_title_layer):
		_title_layer.visible = false
	if restore_boss_appearance:
		if is_instance_valid(_boss_sprite):
			_boss_sprite.visible = _saved_sprite_visible
		if is_instance_valid(_boss_hud):
			_boss_hud.visible = _saved_hud_visible
	if is_instance_valid(_camera):
		_camera.global_transform = _saved_camera_transform
		_camera.fov = _saved_camera_fov
	if _tree != null:
		_tree.paused = _was_paused


func _exit_tree() -> void:
	if _resolved:
		return
	_resolved = true
	_restore_game_state(true)
	aborted.emit(_kind)
