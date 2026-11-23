extends Node

signal finished(skill_id: String)
signal aborted

const IMPACT_FRAME_SHEET: Texture2D = preload("res://assets/effects/pixelfx/impacts/impact-frame/impact-frame.png")
const IMPACT_FRAME_MANIFEST := "res://assets/effects/pixelfx/impacts/impact-frame/impact-frame.json"

const ZOOM_IN_DURATION := 0.95
const IMPACT_HOLD_DURATION := 0.58
const ZOOM_OUT_DURATION := 0.48
const ZOOM_FOV_RATIO := 0.68

enum Phase { ZOOM_IN, IMPACT_HOLD, ZOOM_OUT }

var _player: Node3D
var _camera: Camera3D
var _tree: SceneTree
var _skill_id := ""
var _element := "wind"
var _accent := Color("9dfff2")
var _saved_player_pose: Dictionary = {}
var _phase := Phase.ZOOM_IN
var _elapsed := 0.0
var _resolved := false
var _was_paused := false
var _saved_camera_transform := Transform3D.IDENTITY
var _saved_fov := 30.0

var _overlay: CanvasLayer
var _title_layer: CanvasLayer
var _backdrop: ColorRect
var _flash: ColorRect
var _black_band: Polygon2D
var _white_band: Polygon2D
var _accent_band: Polygon2D
var _impact_frame_sprite: AnimatedSprite2D
var _impact_frame_size := Vector2(320.0, 180.0)
var _title: Label
var _subtitle: Label


func begin(player: Node3D, skill_id: String, camera: Camera3D) -> void:
	if player == null or camera == null or not is_instance_valid(player) or not is_instance_valid(camera):
		_abort()
		return
	_player = player
	_camera = camera
	_tree = get_tree()
	_skill_id = skill_id
	_element = skill_id.get_slice("_", 1)
	_accent = _element_color(_element)
	if player.has_method("begin_ultimate_cinematic_pose"):
		var saved_pose: Variant = player.call("begin_ultimate_cinematic_pose")
		if saved_pose is Dictionary:
			_saved_player_pose = saved_pose
	_was_paused = _tree.paused
	_saved_camera_transform = camera.global_transform
	_saved_fov = camera.fov
	_create_overlay()
	_tree.paused = true
	_camera.fov = _saved_fov


func _process(delta: float) -> void:
	if _resolved:
		return
	if not is_instance_valid(_player) or not is_instance_valid(_camera):
		_abort()
		return
	_elapsed += delta
	match _phase:
		Phase.ZOOM_IN:
			var progress := clampf(_elapsed / ZOOM_IN_DURATION, 0.0, 1.0)
			_update_zoom_in(progress)
			if progress >= 1.0:
				_play_impact()
				_phase = Phase.IMPACT_HOLD
				_elapsed = 0.0
		Phase.IMPACT_HOLD:
			var appear := smoothstep(0.0, 0.12, _elapsed)
			_set_impact_frame(appear)
			_flash.color = Color(1.0, 1.0, 1.0, maxf(0.0, 0.55 - _elapsed * 7.0))
			if _elapsed >= IMPACT_HOLD_DURATION:
				_phase = Phase.ZOOM_OUT
				_elapsed = 0.0
		Phase.ZOOM_OUT:
			var progress := clampf(_elapsed / ZOOM_OUT_DURATION, 0.0, 1.0)
			_update_zoom_out(progress)
			_set_impact_frame(1.0 - smoothstep(0.0, 1.0, progress))
			_flash.color = Color(1.0, 1.0, 1.0, 0.0)
			if progress >= 1.0:
				_finish()


func _update_zoom_in(progress: float) -> void:
	var eased := _ease_in_out(progress)
	_camera.fov = lerpf(_saved_fov, maxf(_saved_fov * ZOOM_FOV_RATIO, 12.0), eased)


func _update_zoom_out(progress: float) -> void:
	var eased := _ease_in_out(progress)
	_camera.fov = lerpf(maxf(_saved_fov * ZOOM_FOV_RATIO, 12.0), _saved_fov, eased)


func _play_impact() -> void:
	_set_impact_frame(0.0)
	_flash.color = Color(1.0, 1.0, 1.0, 0.55)
	_play_fullscreen_impact_frame()


func _play_fullscreen_impact_frame() -> void:
	var sprite_frames := _load_impact_frame_animation()
	if sprite_frames == null:
		return
	_impact_frame_sprite = AnimatedSprite2D.new()
	_impact_frame_sprite.name = "UltimateFullscreenImpactFrame"
	_impact_frame_sprite.sprite_frames = sprite_frames
	_impact_frame_sprite.animation = "default"
	_impact_frame_sprite.centered = true
	_impact_frame_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_impact_frame_sprite.z_index = 1
	_impact_frame_sprite.animation_finished.connect(_on_impact_frame_finished, CONNECT_ONE_SHOT)
	_overlay.add_child(_impact_frame_sprite)
	get_viewport().size_changed.connect(_fit_impact_frame_sprite)
	_fit_impact_frame_sprite()
	_impact_frame_sprite.play()


func _load_impact_frame_animation() -> SpriteFrames:
	var manifest_file := FileAccess.open(IMPACT_FRAME_MANIFEST, FileAccess.READ)
	if manifest_file == null:
		push_warning("Ultimate cinematic: missing PixelFX impact-frame manifest")
		return null
	var document: Variant = JSON.parse_string(manifest_file.get_as_text())
	if not document is Dictionary or not document.has("frames") or not document.has("meta"):
		push_warning("Ultimate cinematic: invalid PixelFX impact-frame manifest")
		return null
	var metadata: Dictionary = document.meta.get("pixelfx", {})
	var frame_size: Array = metadata.get("frameSize", [320, 180])
	if frame_size.size() < 2:
		return null
	_impact_frame_size = Vector2(float(frame_size[0]), float(frame_size[1]))
	if _impact_frame_size.x <= 0.0 or _impact_frame_size.y <= 0.0:
		return null
	var fps := maxf(float(metadata.get("fps", 30.0)), 1.0)
	var sprite_frames := SpriteFrames.new()
	if not sprite_frames.has_animation("default"):
		sprite_frames.add_animation("default")
	sprite_frames.set_animation_speed("default", fps)
	sprite_frames.set_animation_loop("default", false)
	for frame_data: Dictionary in document.frames:
		var rect: Dictionary = frame_data.get("frame", {})
		var atlas := AtlasTexture.new()
		atlas.atlas = IMPACT_FRAME_SHEET
		atlas.region = Rect2(float(rect.get("x", 0)), float(rect.get("y", 0)), float(rect.get("w", 1)), float(rect.get("h", 1)))
		var frame_duration := maxf(float(frame_data.get("duration", 1000.0 / fps)), 1.0)
		sprite_frames.add_frame("default", atlas, frame_duration / (1000.0 / fps))
	return sprite_frames


func _fit_impact_frame_sprite() -> void:
	if not is_instance_valid(_impact_frame_sprite):
		return
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var cover_scale := maxf(viewport_size.x / _impact_frame_size.x, viewport_size.y / _impact_frame_size.y)
	_impact_frame_sprite.position = viewport_size * 0.5
	_impact_frame_sprite.scale = Vector2.ONE * cover_scale


func _on_impact_frame_finished() -> void:
	if is_instance_valid(_impact_frame_sprite):
		_impact_frame_sprite.queue_free()
	_impact_frame_sprite = null


func _create_overlay() -> void:
	_overlay = CanvasLayer.new()
	_overlay.name = "UltimateCinematicOverlay"
	_overlay.layer = 20
	_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_overlay)
	_title_layer = CanvasLayer.new()
	_title_layer.name = "UltimateCinematicTitle"
	_title_layer.layer = 22
	_title_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_title_layer)

	_backdrop = ColorRect.new()
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_backdrop.color = Color(0.01, 0.015, 0.025, 0.0)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(_backdrop)

	_black_band = Polygon2D.new()
	_black_band.color = Color(0.008, 0.01, 0.016, 0.98)
	_overlay.add_child(_black_band)
	_white_band = Polygon2D.new()
	_white_band.color = Color(0.96, 0.97, 0.95, 1.0)
	_overlay.add_child(_white_band)
	_accent_band = Polygon2D.new()
	_accent_band.color = _accent
	_overlay.add_child(_accent_band)

	_subtitle = Label.new()
	_subtitle.text = _element_title(_element)
	_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_subtitle.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_subtitle.add_theme_color_override("font_color", _accent)
	_subtitle.add_theme_font_size_override("font_size", 11)
	_subtitle.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_layer.add_child(_subtitle)

	_title = Label.new()
	_title.text = _ultimate_title(_skill_id)
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_title.add_theme_color_override("font_color", Color("11151a"))
	_title.add_theme_font_size_override("font_size", 24)
	_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_title_layer.add_child(_title)

	_flash = ColorRect.new()
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash.color = Color(1.0, 1.0, 1.0, 0.0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.add_child(_flash)
	_set_impact_frame(0.0)


func _set_impact_frame(strength: float) -> void:
	if _overlay == null:
		return
	var amount := clampf(strength, 0.0, 1.0)
	var viewport_size := get_viewport().get_visible_rect().size
	var center := Vector2(viewport_size.x * 0.5, viewport_size.y * 0.69)
	var scale_factor := 0.82 + amount * 0.18
	var angle := deg_to_rad(-6.0)
	var center_size := Vector2(viewport_size.x * 1.5 * scale_factor, 94.0 * amount)
	_black_band.polygon = _rotated_rect(center, center_size, angle)
	_white_band.polygon = _rotated_rect(center, Vector2(center_size.x - 16.0 * amount, 68.0 * amount), angle)
	_accent_band.polygon = _rotated_rect(center + Vector2(0.0, 31.0 * amount), Vector2(center_size.x * 0.92, 4.0 * amount), angle)
	_backdrop.color = Color(0.008, 0.012, 0.022, 0.86 * amount)
	_black_band.visible = amount > 0.01
	_white_band.visible = amount > 0.01
	_accent_band.visible = amount > 0.01
	_title.visible = amount > 0.01
	_subtitle.visible = amount > 0.01
	_title.modulate.a = amount
	_subtitle.modulate.a = amount
	_title.size = Vector2(viewport_size.x - 28.0, 38.0)
	_title.position = Vector2(14.0, center.y - 20.0)
	_subtitle.size = Vector2(viewport_size.x - 28.0, 20.0)
	_subtitle.position = Vector2(14.0, center.y - 47.0)
	_title.pivot_offset = _title.size * 0.5
	_title.scale = Vector2.ONE * (0.86 + amount * 0.14)


func _rotated_rect(center: Vector2, rect_size: Vector2, angle: float) -> PackedVector2Array:
	var direction := Vector2.RIGHT.rotated(angle)
	var normal := Vector2(-direction.y, direction.x)
	var along := direction * rect_size.x * 0.5
	var across := normal * rect_size.y * 0.5
	return PackedVector2Array([center - along - across, center + along - across, center + along + across, center - along + across])


func _element_color(element: String) -> Color:
	match element:
		"fire": return Color("ff7958")
		"ice": return Color("72d8ff")
		"lightning": return Color("ffe56a")
		_: return Color("78f0cf")


func _element_title(element: String) -> String:
	match element:
		"fire": return "HỎA · TUYỆT KỸ"
		"ice": return "BĂNG · TUYỆT KỸ"
		"lightning": return "LÔI · TUYỆT KỸ"
		_: return "PHONG · TUYỆT KỸ"


func _ultimate_title(skill_id: String) -> String:
	var names := {
		"ultimate_wind_1": "Cái Chết Tựa Cơn Gió",
		"ultimate_wind_2": "Trăng Tối",
		"ultimate_fire_1": "Hỏa Kiếm",
		"ultimate_fire_2": "Hỏa Thần Giáng Lâm",
		"ultimate_ice_1": "Chân Băng",
		"ultimate_ice_2": "Kỷ Băng Hà",
		"ultimate_lightning_1": "Tâm Bão",
		"ultimate_lightning_2": "Thiên Lôi",
	}
	return str(names.get(skill_id, skill_id.replace("_", " ")))


func _ease_in_out(value: float) -> float:
	return value * value * (3.0 - 2.0 * value)


func _finish() -> void:
	if _resolved:
		return
	_resolved = true
	_restore_game_state()
	finished.emit(_skill_id)
	queue_free()


func _abort() -> void:
	if _resolved:
		return
	_resolved = true
	_restore_game_state()
	aborted.emit()
	queue_free()


func _restore_game_state() -> void:
	if is_instance_valid(_impact_frame_sprite):
		_impact_frame_sprite.queue_free()
	_impact_frame_sprite = null
	if _overlay != null and is_instance_valid(_overlay):
		_overlay.visible = false
	if _title_layer != null and is_instance_valid(_title_layer):
		_title_layer.visible = false
	if is_instance_valid(_player) and not _saved_player_pose.is_empty() and _player.has_method("restore_ultimate_cinematic_pose"):
		_player.call("restore_ultimate_cinematic_pose", _saved_player_pose)
		_saved_player_pose.clear()
	if is_instance_valid(_camera):
		_camera.global_transform = _saved_camera_transform
		_camera.fov = _saved_fov
	if _tree != null:
		_tree.paused = _was_paused


func _exit_tree() -> void:
	if not _resolved:
		_restore_game_state()
		_resolved = true
		aborted.emit()
