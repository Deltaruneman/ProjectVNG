class_name PlayerSkillState
extends PlayerState
const BattleFX := preload("res://scenes/player/battle_vfx.gd")
const ORB_SCENE := preload("res://scenes/objects/elemental_orb.tscn")
const SKILL_ANIMATION_SPEED_SCALE := 1.2
@export var skill_scene: PackedScene
@export var cast_time := 0.3
@export var spawn_height := 0.8
@export var spawn_forward := 0.5

var active: Node3D = null
var _time := 0.0
var _cast_duration := 0.0
var _cast_blade_suppressed := false
var _previous_animation_speed_scale := 1.0
var _animation_speed_overridden := false


func can_throw() -> bool:
	return skill_scene != null and not is_instance_valid(active)


func _play_one_shot(animation: String) -> void:
	obj.change_animation(animation)
	var animation_speed_scale := SKILL_ANIMATION_SPEED_SCALE
	if obj.anim_player != null:
		_previous_animation_speed_scale = obj.anim_player.speed_scale
		animation_speed_scale *= _previous_animation_speed_scale
		obj.anim_player.speed_scale = animation_speed_scale
		_animation_speed_overridden = true
	var animation_name := "%s_%s" % [animation, obj.direction]
	if obj.anim_player.has_animation(animation_name):
		_cast_duration = maxf(cast_time, obj.anim_player.get_animation(animation_name).length / maxf(animation_speed_scale, 0.01))
	else:
		_cast_duration = cast_time


func _enter() -> void:
	_time = 0.0
	_cast_blade_suppressed = false
	_cast_duration = cast_time
	obj.stop_horizontal()
	var selected_skill_id: String = obj.get_selected_active_skill_id()
	if obj.get_active_skill_cooldown_for_id(selected_skill_id) > 0.0:
		obj.clear_skill_cast_aim()
		change_state(fsm.states.idle)
		return
	if obj.cast_active_skill(selected_skill_id):
		obj.clear_skill_cast_aim()
		obj.suppress_blade(true)
		_cast_blade_suppressed = true
		obj.start_active_skill_cooldown(selected_skill_id)
		BattleFX.play_skill_sound(obj, selected_skill_id)
		if selected_skill_id in ["active_wind_3", "active_ice_2"]:
			var aim: Vector3 = obj.forward()
			BattleFX.emberline_slash(obj, obj.skill_effect_position(aim, 1.2, 0.8), GameManager.weapon_form, aim, 1.0)
		_play_one_shot("attack")
		return
	if not can_throw():
		obj.clear_skill_cast_aim()
		return

	obj.start_active_skill_cooldown(selected_skill_id)
	var flat_dir: Vector3 = obj.get_skill_aim_direction()
	var spawn_position: Vector3 = obj.global_position + Vector3.UP * spawn_height + flat_dir * spawn_forward
	var dir: Vector3 = obj.get_projectile_aim_direction(spawn_position)
	_play_one_shot("throw")
	var elemental_form: String = GameManager.weapon_form if obj.selected_active_slot == 1 else ""
	BattleFX.play_skill_sound(obj, selected_skill_id if selected_skill_id != "" else "orb_white")
	if elemental_form == "wind":
		BattleFX.slash(obj, obj.global_position + Vector3.UP * 0.85 + flat_dir * 0.55, elemental_form, flat_dir, 0.34)
		BattleFX.emberline_slash(obj, obj.global_position + Vector3.UP * 0.85 + flat_dir * 0.55, elemental_form, flat_dir, 0.7)

	active = skill_scene.instantiate() if elemental_form == "wind" else ORB_SCENE.instantiate()
	if elemental_form != "wind":
		active.set("elemental_form", elemental_form)
	if elemental_form == "wind" and int(GameManager.skill_allocations.get("evo_wind_return", 0)) > 0:
		active.set("max_distance", float(active.get("max_distance")) * 1.25)
		active.set("return_speed", float(active.get("return_speed")) * 1.2)
	obj.get_parent().add_child(active)
	var hit_area := active.get_node_or_null("HitArea3D") as HitArea3D
	if hit_area != null:
		hit_area.damage = obj.attack_damage + int(GameManager.skill_allocations.get("char_element", 0)) + int(GameManager.skill_allocations.get("char_crit", 0))
		hit_area.hitted.connect(obj._on_skill_hit.bind(elemental_form))
	active.global_position = spawn_position
	active.setup(obj, dir)
	obj.clear_skill_cast_aim()


func _update(delta: float) -> void:
	_time += delta
	if _time >= _cast_duration:
		change_state(fsm.states.idle)


func _exit() -> void:
	_restore_animation_speed()
	_release_cast_blade()


func _finish() -> void:
	_restore_animation_speed()
	_release_cast_blade()
	queue_free()


func _restore_animation_speed() -> void:
	if not _animation_speed_overridden:
		return
	if is_instance_valid(obj) and is_instance_valid(obj.anim_player):
		obj.anim_player.speed_scale = _previous_animation_speed_scale
	_animation_speed_overridden = false


func _release_cast_blade() -> void:
	if not _cast_blade_suppressed:
		return
	if is_instance_valid(obj) and obj.has_method("suppress_blade"):
		obj.suppress_blade(false)
	_cast_blade_suppressed = false
