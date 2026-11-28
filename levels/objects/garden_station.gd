extends Node3D
## Garden-only access to existing enchant and brewing systems.
@export_enum("enchant", "brew") var service := "enchant"
const CATALOG := preload("res://scripts/item_catalog.gd")
func _ready() -> void:
	var table := preload("res://assets/vendor/KayKit_Dungeon/Assets/gltf/table_medium.gltf").instantiate()
	table.name = "Table"
	add_child(table)
	var body := StaticBody3D.new()
	var shape := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(1.9, 1, 1.9)
	shape.shape = box
	shape.position.y = 0.5
	body.add_child(shape)
	add_child(body)
	var icon := Sprite3D.new()
	icon.texture = load("res://assets/sprites/item/RavenmoreIconPack2023/RavenmoreIconPack2023/64/TomeYellow.png") if service == "enchant" else CATALOG.texture("healing_potion")
	icon.pixel_size = 0.02 if service == "enchant" else 0.035
	icon.position.y = 1.5
	icon.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	icon.texture_filter = BaseMaterial3D.TEXTURE_FILTER_NEAREST
	add_child(icon)
	var label := Label3D.new()
	label.text = "Bàn enchant" if service == "enchant" else "Bàn chế thuốc"
	label.position.y = 2.3
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.font_size = 32
	label.pixel_size = 0.008
	add_child(label)
	var area := InteractiveArea3D.new()
	area.name = "Interaction"
	area.prompt_height = 2.8
	var range_shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 2.2
	range_shape.shape = sphere
	range_shape.position.y = 0.8
	area.add_child(range_shape)
	area.interacted.connect(_interact)
	add_child(area)

func _interact() -> void:
	if get_tree().paused or GameManager.is_changing():
		return
	var farm := get_parent().get_node("Farm")
	if service == "enchant":
		InventoryMenu.open_menu("enchant")
	elif not farm.opened and not farm.talking and farm.player.can_interact():
		farm._start_interaction()
		farm._show_panel(null, "brew")
