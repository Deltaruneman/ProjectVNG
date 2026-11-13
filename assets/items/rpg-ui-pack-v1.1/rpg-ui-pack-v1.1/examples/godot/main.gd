extends Control
## Builds the demo from layout.json using only the published pack metadata
## (atlas.json 9-slice margins, BMFont .fnt), then saves a 1x screenshot.
## TextureButton hover can only be shown for the button under the mouse, so
## each hover button is captured in its own frame and copied into the result.

const PACK := "res://pack/"
var atlas: Dictionary
var font: FontFile
var hover_buttons: Array[TextureButton] = []

func tex(rel: String) -> Texture2D:
	return load(PACK + rel)

func ui_file(name: String) -> String:
	return atlas["ui"][name]["file"]

func add_text(e: Dictionary) -> void:
	var l := Label.new()
	l.text = e["text"]
	l.position = Vector2(e["x"], e["y"])
	l.add_theme_font_override("font", font)
	l.add_theme_font_size_override("font_size", 9)
	l.add_theme_color_override("font_color", Color(e["color"]))
	add_child(l)

func add_nine(name: String, x: int, y: int, w: int, h: int) -> void:
	var meta: Dictionary = atlas["ui"][name]
	var ns: Dictionary = meta["nineSlice"]
	var r := NinePatchRect.new()
	r.texture = tex(meta["file"])
	# Negative control: `-- --perturb` shifts every left margin by 1px.
	r.patch_margin_left = ns["left"] + (1 if "--perturb" in OS.get_cmdline_user_args() else 0)
	r.patch_margin_top = ns["top"]
	r.patch_margin_right = ns["right"]
	r.patch_margin_bottom = ns["bottom"]
	var mode := NinePatchRect.AXIS_STRETCH_MODE_TILE if ns["edges"] == "tile" else NinePatchRect.AXIS_STRETCH_MODE_STRETCH
	r.axis_stretch_horizontal = mode
	r.axis_stretch_vertical = mode
	r.position = Vector2(x, y)
	r.size = Vector2(w, h)
	add_child(r)

func add_button(e: Dictionary) -> void:
	var base := "button_%s_%s_" % [e["variant"], e["style"]]
	var b := TextureButton.new()
	b.texture_normal = tex(ui_file(base + "normal"))
	b.texture_hover = tex(ui_file(base + "hover"))
	b.texture_pressed = tex(ui_file(base + "pressed"))
	b.texture_disabled = tex(ui_file(base + "disabled"))
	b.position = Vector2(e["x"], e["y"])
	match e["state"]:
		"disabled": b.disabled = true
		"pressed":
			b.toggle_mode = true
			b.button_pressed = true
		"hover": hover_buttons.append(b)
	add_child(b)

func add_bar(e: Dictionary) -> void:
	add_nine("bar_frame", e["x"], e["y"], e["w"], 8)
	var fa: Dictionary = atlas["ui"]["bar_frame"]["fillArea"]
	var p := TextureProgressBar.new()
	p.texture_progress = tex(ui_file("bar_fill_" + e["kind"]))
	p.nine_patch_stretch = true
	p.position = Vector2(e["x"] + fa["x"], e["y"] + fa["y"])
	p.size = Vector2(e["w"] - 2 * fa["x"], fa["h"])
	p.max_value = 1.0
	p.step = 0.0
	p.value = e["value"]
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(p)

func _ready() -> void:
	atlas = JSON.parse_string(FileAccess.get_file_as_string(PACK + "atlas.json"))
	font = load(PACK + "font/hearthmark5x7.fnt")
	var layout: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://layout.json"))
	var bg := ColorRect.new()
	bg.color = Color(layout["background"])
	bg.size = Vector2(320, 180)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(bg)
	for e in layout["elements"]:
		match e["type"]:
			"nine": add_nine(e["sprite"], e["x"], e["y"], e["w"], e["h"])
			"sprite":
				var t := TextureRect.new()
				t.texture = tex(ui_file(e["sprite"]))
				t.position = Vector2(e["x"], e["y"])
				add_child(t)
			"icon":
				var t := TextureRect.new()
				t.texture = tex(atlas["iconSets"][e["style"]]["icons"][e["name"]]["file"])
				t.position = Vector2(e["x"], e["y"])
				add_child(t)
			"button": add_button(e)
			"bar": add_bar(e)
			"text": add_text(e)
	for c in get_children():
		if c is Label or c is NinePatchRect or c is TextureRect:
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_capture.call_deferred()

func frame_image() -> Image:
	for i in 3:
		await RenderingServer.frame_post_draw
	return get_viewport().get_texture().get_image()

func hover(b: TextureButton) -> void:
	var ev := InputEventMouseMotion.new()
	ev.position = b.position + b.size / 2
	ev.global_position = ev.position
	get_viewport().push_input(ev, true)

func _capture() -> void:
	var out: Image = null
	for b in hover_buttons:
		hover(b)
		var img: Image = await frame_image()
		if out == null:
			out = img
		else:
			out.blit_rect(img, Rect2i(b.position, b.size), Vector2i(b.position))
	if out == null:
		out = await frame_image()
	out.convert(Image.FORMAT_RGBA8)
	var name := "perturbed-1x.png" if "--perturb" in OS.get_cmdline_user_args() else "screenshot-1x.png"
	out.save_png(ProjectSettings.globalize_path("res://" + name))
	print("saved screenshot ", out.get_size())
	get_tree().quit()
