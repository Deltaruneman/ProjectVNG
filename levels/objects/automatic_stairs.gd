extends InteractiveArea3D

## Destination is local to this entrance. Movement remains collision-aware.
@export var destination := Vector3(0, 8, -19)
@export var ladder := false
@export var climb_height := 10.2

func _ready() -> void:
	super._ready()
	if ladder:
		_prompt.text = "F: Xuống thang" if climb_height < 0.0 else "F: Leo thang"
	else:
		_prompt.text = "F: Xuống cầu thang" if destination.y < 0.0 else "F: Lên cầu thang"
	_prompt.font_size = 32
	interacted.connect(_climb)

func _someone_can_interact() -> bool:
	for body in get_overlapping_bodies():
		if body is Player and body.can_interact() and body.is_on_floor():
			return true
	return false

func _process(_delta: float) -> void:
	var eligible := _someone_can_interact()
	_prompt.visible = eligible
	set_process_unhandled_input(eligible)

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_echo():
		super._unhandled_input(event)

func _climb() -> void:
	for body in get_overlapping_bodies():
		if body is Player and body.can_interact():
			var route := PackedVector3Array([global_position])
			var end_point: Vector3 = to_global(destination)
			if ladder:
				var ladder_endpoint := global_position + Vector3.UP * climb_height
				if climb_height < 0.0:
					# Reverse the ascent route: move to the top of the shaft first, then descend.
					ladder_endpoint = end_point + Vector3.UP * absf(climb_height)
				route.append(ladder_endpoint)
			route.append(end_point)
			body.start_automatic_stairs(route, ladder)
			return
