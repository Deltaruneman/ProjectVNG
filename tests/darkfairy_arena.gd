extends "res://levels/level_1/basement_floor_visibility.gd"


func _ready() -> void:
	super._ready()
	# Keep F6 testing in the arena without changing the player's saved checkpoint.
	player.died.disconnect(GameManager.respawn)
	player.died.connect(get_tree().reload_current_scene, CONNECT_DEFERRED)
