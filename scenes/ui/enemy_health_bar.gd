extends TextureProgressBar

@onready var enemy: BaseCharacter = get_parent() as BaseCharacter


func _ready() -> void:
	max_value = enemy.max_health
	value = enemy.health
	_update_position()


func _process(_delta: float) -> void:
	value = enemy.health
	_update_position()


func _update_position() -> void:
	var camera := get_viewport().get_camera_3d()
	if camera == null:
		hide()
		return
	var sprite_top := enemy.sprite.get_aabb().end.y
	var anchor := enemy.sprite.to_global(Vector3(0.0, sprite_top + 0.3, 0.0))
	visible = enemy.is_visible_in_tree() and enemy.health > 0 and not camera.is_position_behind(anchor)
	if visible:
		position = (camera.unproject_position(anchor) - size * 0.5).round()
