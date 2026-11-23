extends Node
class_name CropField

signal stage_changed(cell: Vector2i, crop: String, stage: int)
signal harvested(cell: Vector2i, crop: String)

const SOIL_SOURCE := 0
const STAGE_SOURCE := 1
const SWAY_SOURCE := 2
const SOIL_TERRAIN_SET := 0
const SOIL_TERRAIN := 0
const WET_ROW_OFFSET := 7
const CROPS: PackedStringArray = ["rice", "cucumber", "zucchini", "broccoli", "spinach", "celery", "asparagus", "sweet_potato", "green_bean", "okra", "soybean", "ginger", "pineapple", "grape", "raspberry", "cotton", "coffee", "tea", "lavender", "tulip", "hops", "artichoke", "bok_choy", "rhubarb"]
const STAGES: PackedStringArray = ["seed", "sprout", "growing", "mature", "harvest"]

@export var soil: TileMapLayer
@export var plants: TileMapLayer
@export var seconds_per_stage := 4.0
@export var needs_water := true
@export var dry_after_growth := true
@export var crop_names: PackedStringArray = CROPS

var _crops: Dictionary = {}
var _wet: Dictionary = {}


func till(cells: Array[Vector2i]) -> void:
	soil.set_cells_terrain_connect(cells, SOIL_TERRAIN_SET, SOIL_TERRAIN)
	_refresh_soil()


func is_tilled(cell: Vector2i) -> bool:
	return soil.get_cell_source_id(cell) == SOIL_SOURCE


func water(cell: Vector2i) -> void:
	if not is_tilled(cell):
		return
	_wet[cell] = true
	_refresh_cell(cell)


func dry(cell: Vector2i) -> void:
	_wet.erase(cell)
	_refresh_cell(cell)


func is_wet(cell: Vector2i) -> bool:
	return _wet.has(cell)


func plant(cell: Vector2i, crop: String) -> bool:
	var row := crop_names.find(crop)
	if row < 0 or not is_tilled(cell) or _crops.has(cell):
		return false
	_crops[cell] = {"row": row, "stage": 0, "time": 0.0}
	_show(cell)
	return true


func stage_of(cell: Vector2i) -> int:
	return int(_crops[cell]["stage"]) if _crops.has(cell) else -1


func is_ready(cell: Vector2i) -> bool:
	return stage_of(cell) == STAGES.size() - 1


func harvest(cell: Vector2i) -> String:
	if not is_ready(cell):
		return ""
	var crop := crop_names[int(_crops[cell]["row"])]
	_crops.erase(cell)
	plants.erase_cell(cell)
	harvested.emit(cell, crop)
	return crop


func grow(cell: Vector2i) -> void:
	if not _crops.has(cell) or is_ready(cell):
		return
	var c: Dictionary = _crops[cell]
	c["stage"] = int(c["stage"]) + 1
	c["time"] = 0.0
	_show(cell)
	if dry_after_growth:
		dry(cell)
	stage_changed.emit(cell, crop_names[int(c["row"])], int(c["stage"]))


func _process(delta: float) -> void:
	for cell: Vector2i in _crops.keys():
		if is_ready(cell) or (needs_water and not is_wet(cell)):
			continue
		var c: Dictionary = _crops[cell]
		c["time"] = float(c["time"]) + delta
		if float(c["time"]) >= seconds_per_stage:
			grow(cell)


func _show(cell: Vector2i) -> void:
	var c: Dictionary = _crops[cell]
	var row := int(c["row"])
	var stage := int(c["stage"])
	if stage == 3:
		plants.set_cell(cell, SWAY_SOURCE, Vector2i(0, row))
	elif stage == 4:
		plants.set_cell(cell, SWAY_SOURCE, Vector2i(4, row))
	else:
		plants.set_cell(cell, STAGE_SOURCE, Vector2i(stage, row))


func _refresh_soil() -> void:
	for cell in soil.get_used_cells_by_id(SOIL_SOURCE):
		_refresh_cell(cell)


func _refresh_cell(cell: Vector2i) -> void:
	if soil.get_cell_source_id(cell) != SOIL_SOURCE:
		return
	var at := soil.get_cell_atlas_coords(cell)
	var dry_at := Vector2i(at.x, at.y % WET_ROW_OFFSET)
	var want := dry_at + Vector2i(0, WET_ROW_OFFSET) if _wet.has(cell) else dry_at
	if want != at:
		soil.set_cell(cell, SOIL_SOURCE, want)
