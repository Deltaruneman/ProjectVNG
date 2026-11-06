extends Node3D

var phase := 1
var radius := 1.25
var damage := 1
var source: Node3D
var elapsed := 0.0
var impacted := false
var duration := 1.0

@onready var hit: Area3D = $HitArea3D


func _ready() -> void:
	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = 1.8
	$HitArea3D/CollisionShape3D.shape = shape
	$Warning.mesh = $Warning.mesh.duplicate()
	$Warning.mesh.top_radius = radius
	$Warning.mesh.bottom_radius = radius
	$Sprite3D.scale = Vector3.ONE * radius / 1.25
	$AnimationPlayer.play("phase%d_spell" % phase)
	duration = $AnimationPlayer.get_animation("phase%d_spell" % phase).length


func _physics_process(delta: float) -> void:
	elapsed += delta
	# The ring and the first spell frames give the player time to dodge.
	var impact_time := 0.6 if phase == 1 else 0.72
	if elapsed >= impact_time and not impacted:
		impacted = true
		$Warning.hide()
		for area in hit.get_overlapping_areas():
			if area is HurtArea3D:
				var direction := area.global_position - global_position
				direction.y = 0.0
				area.take_damage(direction.normalized(), damage, source)
	if elapsed >= duration:
		queue_free()
