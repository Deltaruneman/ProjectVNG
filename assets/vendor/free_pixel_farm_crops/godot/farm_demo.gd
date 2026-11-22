extends Node2D

const ROOT := "res://free_pixel_farm_crops/"
const W := 26
const H := 15

var field: CropField
var rng := RandomNumberGenerator.new()
var cells: Array[Vector2i] = []
var t := 0.0
var harvests := 0


func layer(z: int) -> TileMapLayer:
	var l := TileMapLayer.new()
	l.tile_set = load(ROOT + "godot/farm_crops_tileset.tres")
	l.z_index = z
	add_child(l)
	return l


func _ready() -> void:
	rng.seed = 110
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var ground := layer(-2)
	for y in range(-1, H + 1):
		for x in range(-1, W + 1):
			ground.set_cell(Vector2i(x, y), 0, Vector2i((x * 3 + y * 5) % 4, 14))
	var soil := layer(-1)
	var plants := layer(0)
	field = CropField.new()
	field.soil = soil
	field.plants = plants
	field.seconds_per_stage = 0.6
	add_child(field)
	for y in range(2, 7):
		for x in range(2, 14):
			cells.append(Vector2i(x, y))
	for y in range(8, 13):
		for x in range(4, 12):
			cells.append(Vector2i(x, y))
	for y in range(3, 12):
		for x in range(16, 23):
			if not (x > 19 and y > 8):
				cells.append(Vector2i(x, y))
	field.till(cells)
	for i in cells.size():
		field.plant(cells[i], CropField.CROPS[i % CropField.CROPS.size()])
	field.harvested.connect(func(_c: Vector2i, _n: String) -> void: harvests += 1)
	var cam := Camera2D.new()
	cam.position = Vector2(W * 8, H * 8)
	cam.zoom = Vector2(2, 2)
	add_child(cam)
	cam.make_current()


func _process(delta: float) -> void:
	t += delta
	for i in 10:
		var c: Vector2i = cells[rng.randi() % cells.size()]
		if not field.is_wet(c):
			field.water(c)
	if t > 9.0:
		for c in cells:
			if field.is_ready(c) and rng.randf() < 0.02:
				var crop := field.harvest(c)
				field.plant(c, crop)
