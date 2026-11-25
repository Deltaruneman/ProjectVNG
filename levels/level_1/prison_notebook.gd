extends Node3D

func _ready() -> void:
	$InteractiveArea3D.interacted.connect(_read)

func _read() -> void:
	var stage := get_tree().current_scene
	var story := stage.get_node_or_null("BasementStory")
	if story != null:
		story.play_event("prison_notebook")
