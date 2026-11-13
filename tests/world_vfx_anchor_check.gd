extends SceneTree
const Anchor = preload("res://world_vfx_anchor.gd")
var failures := 0
var checks := 0

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, label: String) -> void:
	checks += 1
	if not condition:
		failures += 1
	print("PASS " if condition else "FAIL ", label)

func _run() -> void:
	var stage := Node3D.new()
	root.add_child(stage)
	var camera := Camera3D.new()
	stage.add_child(camera)
	camera.current = true
	camera.position = Vector3(0, 2, 10)
	camera.look_at(Vector3.ZERO)
	var layer := CanvasLayer.new()
	root.add_child(layer)
	var anchor := Anchor.new()
	layer.add_child(anchor)
	var sprite := Node2D.new()
	anchor.add_child(sprite)
	var effect_point := Vector3(2, 0, 0)
	anchor.configure(camera, effect_point, Vector3.RIGHT, 1.0, 32.0, sprite)
	check(anchor.visible and anchor.position.distance_to(camera.unproject_position(effect_point)) < 0.01, "initial world projection")
	var first_position: Vector2 = anchor.position
	var first_scale: float = anchor.scale.x
	camera.position = Vector3(8, 3, 8)
	camera.look_at(Vector3.ZERO)
	anchor._process(0.016)
	check(anchor.position.distance_to(camera.unproject_position(effect_point)) < 0.01 and sprite.rotation != 0.0, "orbited camera updates position and direction")
	check(anchor.position != first_position, "effect is not pinned to cast-time pixel")
	camera.position = Vector3(0, 2, 5)
	camera.look_at(Vector3.ZERO)
	anchor._process(0.016)
	check(anchor.scale.x > first_scale, "zoom grows projected effect")
	camera.position = Vector3(0, 2, -5)
	camera.look_at(Vector3(0, 2, -10))
	anchor._process(0.016)
	check(not anchor.visible, "effect hides behind lens")
	camera.look_at(Vector3.ZERO)
	anchor._process(0.016)
	check(anchor.visible, "effect reappears when visible")
	print("RESULT checks=%d failures=%d" % [checks, failures])
	quit(1 if failures else 0)
