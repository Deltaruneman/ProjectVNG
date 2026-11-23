extends Control
## Projects actual combat grip/tip paths into a stable first-person weapon space.
## Original Blade strikes use the original four sprite animation regions, not a sine-wave sway.
var rig: Node3D
var weapon: Sprite2D
var presentation: Dictionary = {}
var projected_grip := Vector2.ZERO
var projected_tip := Vector2.ZERO
var _legacy_frames: Dictionary = {}
const REST_GRIP := Vector3(0.34, 1.05, 0.24)
const REST_TIP := Vector3(-0.25, 0.95, 0.15)
const LEGACY_REGIONS := [Rect2(42, 31, 6, 15), Rect2(40, 43, 16, 13), Rect2(40, 45, 15, 11), Rect2(40, 45, 15, 11)]

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	process_priority = 110
	weapon = Sprite2D.new()
	weapon.centered = false
	weapon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(weapon)
	hide()

func project_weapon_point(point: Vector3) -> Vector2:
	# A fixed virtual eye leaves room for the full cut, including its preparation.
	var depth := maxf(1.1, 1.8 + point.z)
	return size * 0.5 + Vector2(point.x + 0.5, 1.25 - point.y) * (size.y * 0.9 / depth)

func _process(_delta: float) -> void:
	presentation = {}
	if is_instance_valid(rig) and rig.is_first_person() and rig._can_control() and rig.target.has_method("get_first_person_weapon"):
		presentation = rig.target.get_first_person_weapon()
	visible = not presentation.is_empty()
	if not visible:
		return
	var phase: String = presentation.get("phase", "idle")
	var grip: Vector3 = presentation.get("grip", REST_GRIP)
	var tip: Vector3 = presentation.get("tip", REST_TIP)
	if phase == "recover":
		var recovery := smoothstep(0.0, 1.0, float(presentation.progress))
		grip = grip.lerp(REST_GRIP, recovery)
		tip = tip.slerp(REST_TIP.normalized(), recovery)
	var legacy := bool(presentation.get("legacy", false))
	var source: Texture2D = presentation.texture
	var source_size := source.get_size()
	var source_grip := source_size * (Vector2(0.5, 0.85) if legacy else Vector2(0.75, 0.75))
	var source_axis := Vector2(0.0, -source_size.y * 0.65) if legacy else -source_size * 0.5
	if presentation.has("legacy_frame"):
		var frame := int(presentation.legacy_frame)
		var region: Rect2 = LEGACY_REGIONS[frame]
		if not _legacy_frames.has(frame):
			var atlas := AtlasTexture.new()
			atlas.atlas = presentation.legacy_sheet
			atlas.region = Rect2(region.position + Vector2(64, (11 + frame) * 64), region.size)
			_legacy_frames[frame] = atlas
		source = _legacy_frames[frame]
		source_grip = presentation.legacy_grip_pixel - region.position
		source_axis = presentation.legacy_tip_pixel - presentation.legacy_grip_pixel
	var extent := 1.6 if presentation.get("kind", "") == "spear" else (0.75 if presentation.get("kind", "") == "dagger" else 1.15)
	projected_grip = project_weapon_point(grip)
	projected_tip = project_weapon_point(grip + tip.normalized() * extent)
	var projected_axis := projected_tip - projected_grip
	weapon.texture = source
	weapon.offset = -source_grip
	weapon.position = projected_grip
	weapon.rotation = projected_axis.angle() - source_axis.angle()
	# Keep forward-pointing cuts legible when a flat sprite would collapse edge-on.
	var visible_length := clampf(projected_axis.length(), size.y * (0.28 if legacy else 0.2), size.y * 0.62)
	weapon.scale = Vector2.ONE * (visible_length / maxf(source_axis.length(), 1.0))
