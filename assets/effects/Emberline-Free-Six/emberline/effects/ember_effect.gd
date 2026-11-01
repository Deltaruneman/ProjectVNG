class_name EmberEffect2D
extends Node2D
## Original procedural combat effect. Local +X is the forward direction.
## Every instance owns its material; no texture import or plugin is required.

signal finished

enum Kind { IMPACT_SPARK, IMPACT_RING, PROJECTILE_ORB, PROJECTILE_TRAIL, SLASH_ARC, AREA_BURST }

@export var effect_kind: Kind = Kind.IMPACT_SPARK
@export_range(0.05, 5.0, 0.01) var duration: float = 0.70
@export_range(0.1, 4.0, 0.05) var playback_speed: float = 1.0
@export_range(0.1, 3.0, 0.05) var effect_scale: float = 1.0
@export var tint: Color = Color("39d4f5")
@export var accent: Color = Color("ffb95b")
@export var light_surface: bool = false
@export_range(0.0, 2.0, 0.05) var intensity: float = 1.0
@export var autoplay: bool = true
@export var looping: bool = false
@export var free_on_finish: bool = true
@export_range(2.0, 48.0, 0.5) var trail_width: float = 13.0
@export_range(0.05, 2.0, 0.01) var trail_lifetime: float = 0.32

const FX_SHADER = preload("res://emberline/effects/emberline.gdshader")
var elapsed: float = 0.0
var playing: bool = false
var preview_paused: bool = false
var _stopping: bool = false
var _stop_age: float = 0.0
var _quad: ColorRect
var _material: ShaderMaterial
var _points: Array[Vector2] = []
var _ages: Array[float] = []
var _ribbons: Array[ArrayMesh] = [ArrayMesh.new(), ArrayMesh.new(), ArrayMesh.new()]

func _ready() -> void:
	if effect_kind != Kind.PROJECTILE_TRAIL:
		_material = ShaderMaterial.new()
		_material.shader = FX_SHADER
		_quad = ColorRect.new()
		_quad.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_quad.size = Vector2(256, 256)
		_quad.position = Vector2(-128, -166.4) if effect_kind == Kind.AREA_BURST else Vector2(-128, -128)
		_quad.material = _material
		add_child(_quad)
	if autoplay:
		play()
	else:
		visible = false
	_sync_material()

func play() -> void:
	elapsed = 0.0
	_stop_age = 0.0
	_stopping = false
	preview_paused = false
	_points.clear()
	_ages.clear()
	playing = true
	visible = true
	set_process(true)
	_sync_material()

func stop(fade_out: bool = true) -> void:
	if not playing or _stopping:
		return
	if fade_out:
		_stopping = true
		_stop_age = 0.0
	else:
		_complete()

func _process(delta: float) -> void:
	advance(delta)

func advance(delta: float) -> void:
	if not playing or preview_paused:
		return
	var dt: float = maxf(0.0, delta) * maxf(playback_speed, 0.01)
	elapsed += dt
	if _stopping:
		_stop_age += dt
	if effect_kind == Kind.PROJECTILE_TRAIL:
		for i in range(_ages.size()):
			_ages[i] += dt
		while not _ages.is_empty() and _ages[0] >= trail_lifetime:
			_ages.pop_front()
			_points.pop_front()
		if not _stopping:
			record_position(global_position)
		queue_redraw()
	if _stopping and _stop_age >= maxf(trail_lifetime, 0.18):
		_complete()
	elif not looping and elapsed >= duration:
		_complete()
	_sync_material()

func record_position(world_position: Vector2) -> void:
	## World-space samples remain behind the moving emitter.
	if _points.is_empty() or _points[-1].distance_squared_to(world_position) >= 1.0:
		_points.append(world_position)
		_ages.append(0.0)
		if _points.size() > 128:
			_points.pop_front()
			_ages.pop_front()

func set_preview_progress(value: float) -> void:
	## Scrub a still frame for documentation or an editor preview.
	preview_paused = true
	visible = true
	elapsed = clampf(value, 0.0, 1.0) * duration
	_sync_material()
	queue_redraw()

func _sync_material() -> void:
	if _material == null:
		queue_redraw()
		return
	var p: float = fposmod(elapsed / duration, 1.0) if looping else clampf(elapsed / duration, 0.0, 1.0)
	_material.set_shader_parameter("effect_kind", effect_kind)
	_material.set_shader_parameter("phase", p)
	_material.set_shader_parameter("clock_time", elapsed)
	_material.set_shader_parameter("tint", tint)
	_material.set_shader_parameter("accent", accent)
	_material.set_shader_parameter("light_surface", light_surface)
	_material.set_shader_parameter("intensity", intensity)
	_material.set_shader_parameter("opacity", 1.0 - clampf(_stop_age / maxf(trail_lifetime, 0.18), 0.0, 1.0) if _stopping else 1.0)
	_quad.scale = Vector2.ONE * effect_scale
	_quad.position = (Vector2(-128, -166.4) if effect_kind == Kind.AREA_BURST else Vector2(-128, -128)) * effect_scale

func _complete() -> void:
	playing = false
	visible = false
	_points.clear()
	_ages.clear()
	set_process(false)
	finished.emit()
	if free_on_finish:
		queue_free()

func _draw() -> void:
	if effect_kind != Kind.PROJECTILE_TRAIL or _points.size() < 2:
		return
	# The three ribbons share the same sampled path: soft halo, body, hot core.
	for layer in range(3):
		var width_factor: float = [2.5, 1.0, 0.27][layer]
		var color: Color = tint if layer < 2 else Color("fff6d9")
		if light_surface:
			color = Color(tint.r * 0.50, tint.g * 0.50, tint.b * 0.50, tint.a)
		color.a = tint.a
		var brightness: float = lerpf(0.75, 1.18, clampf(intensity * 0.5, 0.0, 1.0))
		color.r *= brightness
		color.g *= brightness
		color.b *= brightness
		color.a *= [0.13, 0.76, 0.94][layer] * minf(intensity, 1.0)
		var vertices: PackedVector3Array = []
		var colors: PackedColorArray = []
		var indices: PackedInt32Array = []
		for i in range(_points.size()):
			var prev: Vector2 = _points[maxi(0, i - 1)]
			var next: Vector2 = _points[mini(_points.size() - 1, i + 1)]
			var tangent: Vector2 = (next - prev).normalized()
			if tangent.is_zero_approx():
				tangent = (_points[i] - prev).normalized()
			if tangent.is_zero_approx():
				tangent = Vector2.RIGHT
			var normal: Vector2 = Vector2(-tangent.y, tangent.x)
			var life: float = clampf(1.0 - _ages[i] / trail_lifetime, 0.0, 1.0)
			var width: float = trail_width * effect_scale * width_factor * pow(life, 0.7) * 0.5
			var c: Color = color
			c.a *= life
			var left: Vector2 = to_local(_points[i] + normal * width)
			var right: Vector2 = to_local(_points[i] - normal * width)
			vertices.append(Vector3(left.x, left.y, 0.0))
			colors.append(c)
			vertices.append(Vector3(right.x, right.y, 0.0))
			colors.append(c)
			if i > 0:
				var n: int = i * 2
				indices.append_array(PackedInt32Array([n - 2, n - 1, n, n, n - 1, n + 1]))
		var arrays: Array = []
		arrays.resize(Mesh.ARRAY_MAX)
		arrays[Mesh.ARRAY_VERTEX] = vertices
		arrays[Mesh.ARRAY_COLOR] = colors
		arrays[Mesh.ARRAY_INDEX] = indices
		_ribbons[layer].clear_surfaces()
		_ribbons[layer].add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
		draw_mesh(_ribbons[layer], null)
