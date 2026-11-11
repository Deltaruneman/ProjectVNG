extends EnemyCharacter

signal defeated
signal phase_changed(phase: int)

const SPELL := preload("res://scenes/enemies/darkfairy/darkfairy_spell.tscn")
const SPIRIT := preload("res://scenes/enemies/darkfairy/darkfairy_spirit.tscn")
const BOSS_CINEMATIC := preload("res://scenes/enemies/darkfairy/darkfairy_cinematic.gd")

@export var detection_range := 11.0
@export var attack_cooldown := 1.3
@export var melee_range := 2.7

var phase := 1
var state: StringName = &"idle"
var engaged := false
var shield_hits := 0
var cooldown := 1.0
var shield_timer := 0.0
var action_index := 0
var spawn_position: Vector3
var attack_target: Vector3
var effects: Array[Node3D] = []
var intro_seen := false
var defeat_finished := false

@onready var melee: Area3D = $Direction/HitArea3D
@onready var boss_bar: TextureProgressBar = $BossHUD/Bar
@onready var boss_label: Label = $BossHUD/Name


func _ready() -> void:
	movement_enabled = false
	super._ready()
	spawn_position = global_position
	anim_player.animation_finished.connect(_on_animation_finished)
	_play(&"idle")


func _physics_process(delta: float) -> void:
	cooldown = maxf(0.0, cooldown - delta)
	shield_timer = maxf(0.0, shield_timer - delta)
	if shield_timer == 0.0:
		shield_hits = 0
	$Shield.visible = shield_hits > 0
	if state == &"death":
		_update_boss_hud()
		return
	found_player = get_tree().get_first_node_in_group("player") as Node3D
	if not _target_in_range():
		engaged = false
		_update_boss_hud()
		return
	engaged = true
	if not intro_seen:
		intro_seen = true
		_update_boss_hud()
		state = &"boss_intro"
		if _start_boss_cinematic(&"intro"):
			return
		state = &"idle"
	_update_boss_hud()
	if state == &"idle":
		sprite.flip_h = found_player.global_position.x < global_position.x
		if cooldown <= 0.0:
			_choose_attack()


func _update_boss_hud() -> void:
	boss_bar.visible = engaged and health > 0
	boss_label.visible = boss_bar.visible
	boss_bar.max_value = max_health
	boss_bar.value = health
	boss_label.text = "DARK FAIRY  /  PHASE %d%s" % [phase, "  /  SHIELD" if shield_hits > 0 else ""]


func _start_boss_cinematic(kind: StringName) -> bool:
	if get_tree().paused:
		return false
	var camera := get_viewport().get_camera_3d()
	var scene := get_tree().current_scene
	if camera == null or scene == null:
		return false
	var cinematic = BOSS_CINEMATIC.new()
	cinematic.process_mode = Node.PROCESS_MODE_ALWAYS
	cinematic.connect("finished", Callable(self, "_on_boss_cinematic_finished"), CONNECT_ONE_SHOT)
	cinematic.connect("aborted", Callable(self, "_on_boss_cinematic_aborted"), CONNECT_ONE_SHOT)
	scene.add_child(cinematic)
	var started: bool = cinematic.call("begin", self, found_player, camera, kind)
	if not started:
		cinematic.queue_free()
	return started


func _on_boss_cinematic_finished(kind: StringName) -> void:
	if kind == &"intro":
		if state == &"boss_intro":
			state = &"idle"
	elif kind == &"defeat":
		_finish_defeat()


func _on_boss_cinematic_aborted(kind: StringName) -> void:
	if kind == &"intro":
		if state == &"boss_intro":
			state = &"idle"
	elif kind == &"defeat" and is_inside_tree() and state == &"death":
		_play(&"death")


func _finish_defeat() -> void:
	if defeat_finished:
		return
	defeat_finished = true
	_drop_skill_points(5, "mini_boss:dark_fairy")
	defeated.emit()
	queue_free()


func _target_in_range() -> bool:
	return is_instance_valid(found_player) and found_player.health > 0 \
		and absf(found_player.global_position.y - spawn_position.y) < 2.5 \
		and found_player.global_position.distance_to(spawn_position) <= detection_range


func _choose_attack() -> void:
	attack_target = found_player.global_position
	attack_target.y = spawn_position.y
	change_direction(direction_to(global_position, attack_target))
	_check_changed_direction()
	if phase == 1:
		var actions := [&"castspell", &"createshield", &"teleportation", &"castspell"]
		var next: StringName = actions[action_index % actions.size()]
		action_index += 1
		if global_position.distance_to(attack_target) < melee_range and next == &"castspell":
			next = &"closeattack"
		_play(next)
	else:
		var actions := [&"castspell", &"summonspirits", &"castspell", &"explosion"]
		_play(actions[action_index % actions.size()])
		action_index += 1


func _play(next: StringName) -> void:
	state = next
	var prefix := "phase%d_" % phase
	anim_player.play("transformation" if next == &"transformation" else prefix + String(next))


# These callbacks run on the impact frames of the supplied sprite animations.
func close_attack() -> void:
	if state != &"closeattack":
		return
	for area in melee.get_overlapping_areas():
		if area is HurtArea3D:
			area.take_damage(global_position.direction_to(area.global_position), attack_damage, self)


func cast_spell() -> void:
	if state != &"castspell" or not _target_in_range():
		return
	_spawn_spell(attack_target, phase, 1.25 if phase == 1 else 1.7)
	if phase == 2:
		for offset: Vector3 in [Vector3(2.5, 0, 0), Vector3(-2.5, 0, 0)]:
			_spawn_spell(attack_target + offset, phase, 1.25)


func _spawn_spell(at: Vector3, spell_phase: int, radius: float) -> void:
	var spell := SPELL.instantiate()
	spell.phase = spell_phase
	spell.radius = radius
	spell.source = self
	spell.damage = attack_damage
	get_parent().add_child(spell)
	spell.global_position = at
	_track_effect(spell)


func create_shield() -> void:
	if state == &"createshield":
		shield_hits = 3
		shield_timer = 5.0


func teleport_out() -> void:
	if state != &"teleportation":
		return
	invincible = true
	# Only land on nearby world geometry at this floor's height, with room for the body.
	for offset: Vector3 in [Vector3(4, 0, 0), Vector3(0, 0, -4), Vector3(-4, 0, 0), Vector3(0, 0, 4)]:
		var candidate := spawn_position + offset
		if candidate.distance_to(global_position) < 2.0:
			continue
		var ray := PhysicsRayQueryParameters3D.create(candidate + Vector3.UP * 2.0,
			candidate - Vector3.UP, 1)
		var floor_hit := get_world_3d().direct_space_state.intersect_ray(ray)
		if floor_hit.is_empty() or absf(floor_hit.position.y - spawn_position.y) > 0.5:
			continue
		candidate.y = floor_hit.position.y + 0.05
		var query := PhysicsShapeQueryParameters3D.new()
		query.shape = $CollisionShape3D.shape
		query.transform = Transform3D(Basis.IDENTITY, candidate + $CollisionShape3D.position)
		query.collision_mask = 1 | 2
		if get_world_3d().direct_space_state.intersect_shape(query).is_empty():
			global_position = candidate
			break
	anim_player.play_backwards("phase1_teleportation")
	state = &"reappear"


func summon_spirits() -> void:
	if state != &"summonspirits" or not _target_in_range():
		return
	effects = effects.filter(func(effect): return is_instance_valid(effect))
	var living := 0
	for effect in effects:
		if effect.is_in_group("darkfairy_spirits"):
			living += 1
	for i in range(mini(3, 6 - living)):
		var spirit := SPIRIT.instantiate()
		spirit.target = found_player
		get_parent().add_child(spirit)
		spirit.global_position = global_position + Vector3(2.0, 0, 0).rotated(Vector3.UP, TAU * i / 3.0)
		_track_effect(spirit)


func explode() -> void:
	if state == &"explosion":
		_spawn_spell(global_position, 2, 3.8)


func _track_effect(effect: Node3D) -> void:
	effects = effects.filter(func(item): return is_instance_valid(item))
	effects.append(effect)


func _clear_effects() -> void:
	for effect in effects:
		if is_instance_valid(effect):
			effect.queue_free()
	effects.clear()


func _on_hurt_area_3d_hurt(_hit_direction: Vector3, damage: float) -> void:
	if invincible or state in [&"death", &"hurt", &"transformation", &"shieldhit"]:
		return
	if shield_hits > 0:
		shield_hits -= 1
		_play(&"shieldhit")
		return
	take_damage(int(damage))
	if phase == 1:
		health = maxi(health, 1)
	if health <= 0:
		_clear_effects()
		$Direction/HurtArea3D.set_deferred("collision_layer", 0)
		$CollisionShape3D.set_deferred("disabled", true)
		invincible = true
		state = &"death"
		$Shield.visible = false
		$BossHUD.visible = false
		anim_player.stop()
		if not _start_boss_cinematic(&"defeat"):
			_play(&"death")
	elif phase == 1 and health <= max_health / 2:
		shield_hits = 0
		_clear_effects()
		invincible = true
		_play(&"transformation")
	else:
		_play(&"hurt")


func _enter_parry_hurt(_hit_direction: Vector3) -> void:
	if state in [&"death", &"transformation"]:
		return
	invincible = false
	shield_hits = 0
	_clear_effects()
	_play(&"hurt")


func _on_animation_finished(animation: StringName) -> void:
	if animation == &"phase2_death":
		_finish_defeat()
		return
	if animation == &"transformation":
		phase = 2
		action_index = 0
		phase_changed.emit(phase)
	invincible = false
	cooldown = attack_cooldown * (0.7 if phase == 2 else 1.0)
	_play(&"idle")


func _exit_tree() -> void:
	_clear_effects()
