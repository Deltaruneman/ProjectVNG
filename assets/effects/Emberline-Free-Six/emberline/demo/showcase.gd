extends Node2D

const Effect = preload("res://emberline/effects/ember_effect.gd")
const IDS = ["impact_spark", "impact_ring", "projectile_orb", "projectile_trail", "slash_arc", "area_burst"]
const NAMES = ["Impact Spark", "Impact Ring", "Projectile Orb", "Motion Trail", "Slash Arc", "Ground Burst"]
const DESCRIPTIONS = ["Crisp directional fragments", "A clean expanding shockwave", "A living, forward-facing core", "A ribbon that follows movement", "A fast, tapered attack sweep", "Grounded energy and rising sparks"]
const PALETTES = [Color("39d4f5"), Color("ff8f47"), Color("ba93ff")]
const ACCENTS = [Color("ffb95b"), Color("ffe7a3"), Color("79e4ff")]

var effects: Array[Node2D] = []
var centers: Array[Vector2] = []
var cards: Array[Panel] = []
var caption: Label
var elapsed: float = 0.0
var light_background: bool = false
var _size: float = 0.78
var _speed: float = 1.0
var _intensity: float = 1.0
var _palette: int = 0
var _shot: Node2D
var _shot_trail: Node2D
var _shot_age: float = 0.0
var _shot_timer: float = 1.0
var _cycle: float = 0.0

func _ready() -> void:
	_make_interface()
	for i in range(6):
		var c: Vector2 = Vector2(266 + (i % 3) * 450, 246 + (i / 3) * 237)
		centers.append(c)
		var effect: Node2D = _new_effect(i, c)
		effect.free_on_finish = false
		effects.append(effect)
	caption.text = "Six original effects. One coherent combat language."
	queue_redraw()

func _style(background: Color, border: Color, radius: int = 14) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	return style

func _label(parent: Node, text: String, position_value: Vector2, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.position = position_value
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	parent.add_child(label)
	return label

func _button(parent: Node, text: String, pos: Vector2, dimensions: Vector2, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.position = pos
	button.size = dimensions
	button.add_theme_font_size_override("font_size", 16)
	button.add_theme_stylebox_override("normal", _style(Color("14283c"), Color("29435a"), 8))
	button.add_theme_stylebox_override("hover", _style(Color("22405a"), Color("55d3ed"), 8))
	button.add_theme_stylebox_override("pressed", _style(Color("2b526a"), Color("9aefff"), 8))
	button.pressed.connect(callback)
	parent.add_child(button)
	return button

func _make_interface() -> void:
	var ui := CanvasLayer.new()
	ui.layer = -1
	add_child(ui)
	var control := Control.new()
	control.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(control)
	_label(control, "EMBERLINE", Vector2(48, 31), 19, Color("63dff4"))
	_label(control, "Combat VFX / Free Six", Vector2(48, 60), 38, Color("f0f4f8"))
	caption = _label(control, "", Vector2(50, 112), 18, Color("8ea4b9"))
	_label(control, "GODOT 4.7.2  /  2D", Vector2(1120, 46), 16, Color("abc1d1"))
	_label(control, "COMPATIBILITY RENDERER", Vector2(1120, 76), 13, Color("6f8ca4"))
	for i in range(6):
		var card := Panel.new()
		card.position = Vector2(48 + (i % 3) * 450, 169 + (i / 3) * 237)
		card.size = Vector2(426, 216)
		card.add_theme_stylebox_override("panel", _style(Color("0d1c2b"), Color("223447")))
		control.add_child(card)
		cards.append(card)
		_label(card, "%02d" % (i + 1), Vector2(18, 14), 14, Color("4b718b"))
		_label(card, NAMES[i], Vector2(18, 151), 21, Color("dfeaf2"))
		_label(card, DESCRIPTIONS[i], Vector2(18, 180), 14, Color("7795ad"))
		_button(card, "Replay", Vector2(331, 153), Vector2(76, 37), func(): effects[i].play())
	var controls_y: float = 660.0
	_button(control, "Replay all", Vector2(48, controls_y), Vector2(125, 42), replay_all)
	for i in range(3):
		_button(control, ["Glacier", "Ember", "Arcane"][i], Vector2(192 + i * 100, controls_y), Vector2(92, 42), func(): set_palette(i))
	_slider(control, "Size", Vector2(527, controls_y - 5), 0.4, 0.95, _size, func(v): _size = v; _apply_settings())
	_slider(control, "Speed", Vector2(744, controls_y - 5), 0.25, 2.0, _speed, func(v): _speed = v; _apply_settings())
	_slider(control, "Intensity", Vector2(961, controls_y - 5), 0.25, 1.7, _intensity, func(v): _intensity = v; _apply_settings())
	_button(control, "Light / Dark", Vector2(1190, controls_y), Vector2(160, 42), toggle_background)
	var combat := Panel.new()
	combat.position = Vector2(48, 733)
	combat.size = Vector2(1326, 168)
	combat.add_theme_stylebox_override("panel", _style(Color("0b1926"), Color("223447")))
	control.add_child(combat)
	_label(combat, "IN CONTEXT", Vector2(20, 14), 12, Color("548096"))
	_label(combat, "Launch → trail → impact", Vector2(20, 39), 21, Color("c8dce9"))
	_label(combat, "Press SPACE or click Fire to replay the combat example.", Vector2(20, 117), 14, Color("7795ad"))
	_button(combat, "Fire  →", Vector2(1155, 111), Vector2(142, 40), fire)
	_label(control, "Editable scenes  ·  No plugins  ·  Original procedural effects  ·  AI-assisted code", Vector2(50, 923), 14, Color("5f7b93"))
	_label(control, "1–6 replay effects   /   SPACE fire", Vector2(1072, 923), 14, Color("7f9eb6"))

func _slider(parent: Node, title: String, pos: Vector2, low: float, high: float, initial: float, callback: Callable) -> void:
	var number: Label = _label(parent, title + "  " + str(snappedf(initial, 0.01)), pos, 14, Color("91aabd"))
	var slider := HSlider.new()
	slider.position = pos + Vector2(0, 26)
	slider.size = Vector2(177, 21)
	slider.min_value = low
	slider.max_value = high
	slider.step = 0.05
	slider.value = initial
	slider.value_changed.connect(func(value): number.text = title + "  " + str(snappedf(value, 0.01)); callback.call(value))
	parent.add_child(slider)

func _new_effect(kind: int, at: Vector2) -> Node2D:
	var instance: Node2D = load("res://emberline/effects/" + IDS[kind] + ".tscn").instantiate()
	instance.position = at
	instance.effect_scale = _size
	instance.playback_speed = _speed
	instance.intensity = _intensity
	instance.tint = PALETTES[_palette]
	instance.accent = ACCENTS[_palette]
	add_child(instance)
	return instance

func _apply_settings() -> void:
	for effect in effects:
		effect.effect_scale = _size
		effect.playback_speed = _speed
		effect.intensity = _intensity
		effect.tint = PALETTES[_palette]
		effect.accent = ACCENTS[_palette]
		effect.light_surface = light_background
		effect._sync_material()

func set_palette(index: int) -> void:
	_palette = index
	_apply_settings()

func toggle_background() -> void:
	light_background = not light_background
	for card in cards:
		card.add_theme_stylebox_override("panel", _style(Color("dbe5eb") if light_background else Color("0d1c2b"), Color("44667b")))
		for child in card.get_children():
			if child is Label:
				var is_title: bool = child.get_theme_font_size("font_size") == 21
				var label_color: Color = Color("243d50") if is_title else Color("476779")
				if not light_background:
					label_color = Color("dfeaf2") if is_title else Color("7795ad")
				child.add_theme_color_override("font_color", label_color)
	_apply_settings()
	queue_redraw()

func replay_all() -> void:
	for effect in effects:
		effect.play()
	_cycle = 0.0

func fire() -> void:
	if is_instance_valid(_shot):
		_shot.queue_free()
	if is_instance_valid(_shot_trail):
		_shot_trail.stop()
	_shot_age = 0.0
	_shot_trail = _new_effect(3, Vector2(492, 813))
	_shot_trail.effect_scale = 0.8
	_shot = _new_effect(2, Vector2(492, 813))
	_shot.effect_scale = 0.68
	_shot_timer = 3.0

func _process(delta: float) -> void:
	elapsed += delta
	_cycle += delta * _speed
	_shot_timer -= delta
	if _cycle > 1.45:
		replay_all()
	if effects.size() == 6:
		var trail: Node2D = effects[3]
		trail.position = centers[3] + Vector2(sin(elapsed * 2.7) * 94.0, sin(elapsed * 5.4) * 28.0)
	if _shot_timer <= 0:
		fire()
	if is_instance_valid(_shot):
		_shot_age += delta * _speed
		var distance_value: float = minf(_shot_age / 0.85, 1.0)
		_shot.position = Vector2(492 + 690 * distance_value, 813)
		if is_instance_valid(_shot_trail):
			_shot_trail.position = _shot.position
		if distance_value >= 1.0:
			_shot.queue_free()
			_shot = null
			_shot_trail.stop()
			_new_effect(0, Vector2(1182, 813))
			var impact: Node2D = _new_effect(1, Vector2(1182, 813))
			impact.effect_scale = 0.7

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode >= KEY_1 and event.keycode <= KEY_6:
			effects[event.keycode - KEY_1].play()
			get_viewport().set_input_as_handled()
		elif event.keycode == KEY_SPACE:
			fire()
			get_viewport().set_input_as_handled()

func _draw() -> void:
	# Minimal target markers belong to the demo, not to the reusable effects.
	draw_line(Vector2(460, 846), Vector2(1226, 846), Color("23394b"), 1.0, true)
	draw_circle(Vector2(1182, 813), 26.0, Color("294358"), false, 1.5, true)
	draw_line(Vector2(1182, 778), Vector2(1182, 848), Color("345269"), 1.0, true)
	draw_line(Vector2(1147, 813), Vector2(1217, 813), Color("345269"), 1.0, true)
