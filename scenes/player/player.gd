class_name Player
extends BaseCharacter
const BattleFX := preload("res://scenes/player/battle_vfx.gd")

## Turned on throughout the Hurt state so one hit doesn't drain health every single frame in a row.
var is_invulnerable: bool = false

signal died
signal rage_changed(current: float, maximum: float)
signal active_skill_slot_changed(slot: int, skill_id: String)
var rage := 0.0
const MAX_RAGE := 100.0
var selected_active_slot := 1
const ACTIVE_SKILL_COOLDOWNS := {
	"basic_dagger": 1.2,
	"active_wind_1": 1.6, "active_wind_2": 8.0, "active_wind_3": 6.0,
	"active_fire_1": 1.6, "active_fire_2": 10.0, "active_fire_3": 8.0,
	"active_ice_1": 1.8, "active_ice_2": 8.0, "active_ice_3": 12.0,
}
const ULTIMATE_SKILL_COOLDOWNS := {
	"ultimate_wind_1": 20.0, "ultimate_wind_2": 18.0,
	"ultimate_fire_1": 18.0, "ultimate_fire_2": 25.0,
	"ultimate_ice_1": 22.0, "ultimate_ice_2": 25.0,
}
var _active_skill_cooldowns: Dictionary = {}
var _ultimate_cooldown_remaining := 0.0
var _base_attack_damage := 1
var _base_max_health := 3
var _base_movement_speed := 6.0
var _base_dash_cooldown := 0.75
var _base_parry_window := 0.167
var _base_maxjump := 2
var _temp_attack_bonus := 0
var _temp_speed_bonus := 0.0
var ice_shield := 0
func _enter_tree() -> void:
	# Để HUD tìm được player (group được thêm trước khi bất kỳ node nào chạy _ready)
	add_to_group("player")


func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Idle, true)
	super._ready()
	$Direction/HitArea3D.hitted.connect(_on_attack_hit)
	_base_attack_damage = attack_damage
	_base_max_health = max_health
	_base_movement_speed = movement_speed
	_base_dash_cooldown = dash_cooldown
	_base_parry_window = parry_window
	_base_maxjump = maxjump
	GameManager.skill_progress_changed.connect(_apply_skill_bonuses)
	_apply_skill_bonuses()
	active_skill_slot_changed.emit(selected_active_slot, get_selected_active_skill_id())


func _process(delta: float) -> void:
	for key: Variant in _active_skill_cooldowns.keys():
		var skill_id: String = str(key)
		var remaining: float = maxf(0.0, float(_active_skill_cooldowns[skill_id]) - delta)
		if remaining <= 0.0:
			_active_skill_cooldowns.erase(skill_id)
		else:
			_active_skill_cooldowns[skill_id] = remaining
	_ultimate_cooldown_remaining = maxf(0.0, _ultimate_cooldown_remaining - delta)


func die() -> void:
	if fsm == null or fsm.current_state == null or not fsm.states.has("dead"):
		return
	if fsm.current_state == fsm.states.dead:
		return
	health = 0
	fsm.change_state(fsm.states.dead)


func _unhandled_input(event: InputEvent) -> void:
	for slot in 3:
		if event.is_action_pressed("active_skill_%d" % (slot + 1)):
			selected_active_slot = slot + 1
			active_skill_slot_changed.emit(selected_active_slot, get_selected_active_skill_id())
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("skill"):
		var skill_id := get_selected_active_skill_id()
		if _can_use_skills() and fsm.states.has("skill") and fsm.states.skill.can_throw() and get_active_skill_cooldown_for_id(skill_id) <= 0.0:
			fsm.change_state(fsm.states.skill)
			get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ultimate"):
		if _can_use_skills():
			cast_ultimate()
		get_viewport().set_input_as_handled()
		return
	super._unhandled_input(event)


func _can_use_skills() -> bool:
	if fsm == null or fsm.current_state == null:
		return false
	return not ["dead", "hurt", "carry", "throw", "skill"].has(fsm.current_state.name.to_lower())


func get_selected_active_skill_id() -> String:
	return get_active_skill_id_for_slot(selected_active_slot)


func get_active_skill_id_for_slot(slot: int) -> String:
	if GameManager.weapon_form == "" or slot < 1 or slot > 3:
		return ""
	var skill_id := "active_%s_%d" % [GameManager.weapon_form, slot]
	return skill_id if GameManager.unlocked_skills.has(skill_id) else ""


func get_active_skill_cooldown_key_for_slot(slot: int) -> String:
	var skill_id := get_active_skill_id_for_slot(slot)
	return skill_id if skill_id != "" else "basic_dagger"


func get_active_skill_cooldown_for_id(skill_id: String) -> float:
	var cooldown_key := skill_id if skill_id != "" else "basic_dagger"
	return float(_active_skill_cooldowns.get(cooldown_key, 0.0))


func get_active_skill_cooldown_for_slot(slot: int) -> float:
	return get_active_skill_cooldown_for_id(get_active_skill_id_for_slot(slot))


func get_active_skill_cooldown_duration_for_slot(slot: int) -> float:
	return get_active_skill_cooldown_duration(get_active_skill_cooldown_key_for_slot(slot))


func get_active_skill_cooldown_duration(skill_id: String) -> float:
	var cooldown_key := skill_id if skill_id != "" else "basic_dagger"
	return float(ACTIVE_SKILL_COOLDOWNS.get(cooldown_key, ACTIVE_SKILL_COOLDOWNS["basic_dagger"]))


func start_active_skill_cooldown(skill_id: String) -> void:
	var cooldown_key := skill_id if skill_id != "" else "basic_dagger"
	_active_skill_cooldowns[cooldown_key] = get_active_skill_cooldown_duration(cooldown_key)


func get_ultimate_cooldown_remaining() -> float:
	return _ultimate_cooldown_remaining


func get_ultimate_cooldown_duration(skill_id: String) -> float:
	return float(ULTIMATE_SKILL_COOLDOWNS.get(skill_id, 20.0))


func get_skill_aim_direction() -> Vector3:
	var input := Input.get_vector("left", "right", "up", "down")
	if input.length() > 0.15:
		change_direction(BaseCharacter.direction_from_input(input))
		return Vector3(input.x, 0.0, input.y).normalized()
	return forward().normalized()


func skill_effect_position(aim: Vector3, distance: float = 0.9, height: float = 0.65) -> Vector3:
	return global_position + Vector3.UP * height + aim * distance


func _on_attack_hit(_area: Area3D) -> void:
	if rage >= MAX_RAGE:
		return
	rage = minf(MAX_RAGE, rage + 12.5)
	rage_changed.emit(rage, MAX_RAGE)


func _on_skill_hit(area: Area3D, elemental_form: String = "") -> void:
	_on_attack_hit(area)
	var enemy := _get_enemy_from_hurt_area(area)
	if enemy != null:
		if elemental_form == "fire":
			var ember_rank := int(GameManager.skill_allocations.get("evo_fire_ember", 0))
			enemy.apply_skill_burn(self, maxi(1, int(attack_damage / 2)) + ember_rank, 3.0 + float(ember_rank), 1.0)
		elif elemental_form == "ice":
			var frostbite_rank := int(GameManager.skill_allocations.get("evo_ice_frostbite", 0))
			enemy.apply_skill_slow(2.0 + float(frostbite_rank), 0.5)
	var stage := get_tree().current_scene as Node3D
	if stage != null and elemental_form != "":
		var impact_direction := area.global_position - global_position
		impact_direction.y = 0.0
		if impact_direction.length_squared() < 0.001:
			impact_direction = get_skill_aim_direction()
		BattleFX.impact(stage, area.global_position + Vector3.UP * 0.5, elemental_form, impact_direction.normalized())
		BattleFX.emberline_impact(self, area.global_position + Vector3.UP * 0.5, elemental_form, impact_direction, 0.42)


func _get_enemy_from_hurt_area(area: Area3D) -> EnemyCharacter:
	var candidate: Node = area
	while candidate != null:
		if candidate is EnemyCharacter:
			return candidate as EnemyCharacter
		candidate = candidate.get_parent()
	return null


func _gain_rage(amount: float) -> void:
	if rage >= MAX_RAGE:
		return
	rage = minf(MAX_RAGE, rage + amount)
	rage_changed.emit(rage, MAX_RAGE)


func _apply_skill_bonuses() -> void:
	var ranks: Dictionary = GameManager.skill_allocations
	var extra_health := int(ranks.get("char_health", 0))
	var previous_max := max_health
	max_health = _base_max_health + extra_health
	health += maxi(max_health - previous_max, 0)
	health = mini(health, max_health)
	attack_damage = _base_attack_damage + int(ranks.get("char_attack", 0)) + _temp_attack_bonus
	movement_speed = _base_movement_speed * (1.0 + 0.08 * int(ranks.get("char_speed", 0))) + _temp_speed_bonus
	dash_cooldown = _base_dash_cooldown * pow(0.85, int(ranks.get("char_dash", 0)))
	parry_window = _base_parry_window * (1.0 + 0.25 * int(ranks.get("char_parry", 0)))
	maxjump = _base_maxjump + int(ranks.get("char_double_jump", 0))
	active_skill_slot_changed.emit(selected_active_slot, get_selected_active_skill_id())


func cast_active_skill(active_id: String) -> bool:
	if active_id in ["", "active_wind_1", "active_fire_1", "active_ice_1"]:
		return false
	var aim := get_skill_aim_direction()
	var damage := attack_damage + int(GameManager.skill_allocations.get("char_element", 0))
	var effect_position := skill_effect_position(aim)
	match active_id:
		"active_wind_2":
			BattleFX.swing(self, effect_position, "wind", aim)
			_apply_timed_buff(1, 2.0, 5.0)
		"active_wind_3":
			var dash_origin := global_position
			var gale_rank := int(GameManager.skill_allocations.get("evo_wind_gale", 0))
			var dash_reach := 2.5 + 0.5 * float(gale_rank)
			BattleFX.claw(self, skill_effect_position(aim, 1.25, 0.55), "wind", aim, 0.9 + 0.18 * float(gale_rank))
			BattleFX.slash(self, skill_effect_position(aim, 1.25, 0.5), "wind", aim, 0.8 + 0.16 * float(gale_rank))
			_damage_enemies_in_shape(dash_origin, aim, "line", dash_reach, 1.6, 0.0, roundi(float(damage * 2) * (1.0 + 0.5 * float(gale_rank))))
			global_position += aim * (1.5 + 0.5 * float(gale_rank))
		"active_fire_2":
			BattleFX.charge(self, global_position + Vector3.UP * 0.65, "fire", 0.65)
			var inferno_rank := int(GameManager.skill_allocations.get("evo_fire_inferno", 0))
			var blast_radius := 5.0 + float(inferno_rank)
			var timer := get_tree().create_timer(5.0)
			timer.timeout.connect(func() -> void:
				if is_inside_tree():
					var blast_center := global_position
					BattleFX.circle_burst(self, blast_center + Vector3.UP * 0.65, "fire", blast_radius)
					BattleFX.emberline_ring(self, blast_center, "fire", aim, blast_radius)
					BattleFX.play_skill_sound(self, "fire_impact")
					_damage_enemies_in_shape(blast_center, aim, "circle", blast_radius, 0.0, 360.0, damage * 2))
		"active_fire_3":
			health = maxi(1, health - int(ceil(health * 0.25)))
			_fire_rage_sequence.call_deferred(damage, aim)
		"active_ice_2":
			var frostbite_rank := int(GameManager.skill_allocations.get("evo_ice_frostbite", 0))
			var shatter_rank := int(GameManager.skill_allocations.get("evo_ice_shatter", 0))
			var cone_reach := 5.0
			var cone_half_angle := 32.0
			var cone_width := 2.0 * cone_reach * sin(deg_to_rad(cone_half_angle))
			BattleFX.claw(self, skill_effect_position(aim, cone_reach * 0.5, 0.55), "ice", aim, cone_width / 3.0)
			_damage_enemies_in_shape(global_position, aim, "cone", cone_reach, 0.0, cone_half_angle, damage * 2, 2.0 + 0.5 * float(frostbite_rank), 0.0, 0.5 * float(shatter_rank))
		"active_ice_3":
			ice_shield = int(ceil(max_health * 0.25))
			BattleFX.shield(self, global_position, "ice", 8.0, 0.25)
			BattleFX.emberline_ring(self, global_position, "ice", aim, 1.25)
			get_tree().create_timer(8.0).timeout.connect(func() -> void: ice_shield = 0)
	return true


func _fire_rage_sequence(damage: int, aim: Vector3) -> void:
	var radius := 3.5 + float(GameManager.skill_allocations.get("evo_fire_inferno", 0))
	for tick in 3:
		BattleFX.circle_burst(self, global_position + Vector3.UP * 0.55, "fire", radius)
		BattleFX.emberline_burst(self, global_position, "fire", aim, radius)
		_damage_enemies_in_shape(global_position, aim, "circle", radius, 0.0, 360.0, damage)
		if tick < 2:
			await get_tree().create_timer(1.0).timeout


func _apply_timed_buff(attack_bonus: int, speed_bonus: float, duration: float) -> void:
	_temp_attack_bonus += attack_bonus
	_temp_speed_bonus += speed_bonus
	_apply_skill_bonuses()
	get_tree().create_timer(duration).timeout.connect(func() -> void:
		if is_inside_tree():
			_temp_attack_bonus -= attack_bonus
			_temp_speed_bonus -= speed_bonus
			_apply_skill_bonuses())


func _damage_enemies_in_shape(center: Vector3, aim: Vector3, shape: String, reach: float, width: float, half_angle: float, damage: int, freeze_duration: float = 0.0, slow_duration: float = 0.0, bonus_vs_frozen: float = 0.0) -> int:
	var aim_2d := Vector2(aim.x, aim.z).normalized()
	if aim_2d.length_squared() < 0.001:
		aim_2d = Vector2(forward().x, forward().z).normalized()
	var right_2d := Vector2(aim_2d.y, -aim_2d.x)
	var hit_count := 0
	for candidate: Node in get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(candidate) or not (candidate is EnemyCharacter):
			continue
		var enemy := candidate as EnemyCharacter
		var offset_3d := enemy.global_position - center
		if absf(offset_3d.y) > 2.5:
			continue
		var offset := Vector2(offset_3d.x, offset_3d.z)
		var distance := offset.length()
		var forward_distance := offset.dot(aim_2d)
		var lateral_distance := absf(offset.dot(right_2d))
		var hits := false
		match shape:
			"circle":
				hits = distance <= reach
			"global":
				hits = true
			"box", "line":
				hits = forward_distance >= 0.0 and forward_distance <= reach and lateral_distance <= width * 0.5
			"cone":
				hits = distance <= reach and (distance <= 0.001 or offset.normalized().dot(aim_2d) >= cos(deg_to_rad(half_angle)))
		if not hits:
			continue
		var hurt_area := enemy.get_node_or_null("Direction/HurtArea3D") as HurtArea3D
		if hurt_area != null:
			var impact_direction := offset_3d.normalized()
			if impact_direction.length_squared() < 0.001:
				impact_direction = Vector3(aim_2d.x, 0.0, aim_2d.y)
			var final_damage := damage
			if bonus_vs_frozen > 0.0 and enemy.is_skill_frozen():
				final_damage += roundi(float(damage) * bonus_vs_frozen)
			hurt_area.take_damage(impact_direction, final_damage, self)
			_gain_rage(12.5)
			var stage := get_tree().current_scene as Node3D
			if stage != null:
				BattleFX.impact(stage, enemy.global_position + Vector3.UP * 0.55, GameManager.weapon_form, impact_direction)
			BattleFX.emberline_impact(self, enemy.global_position + Vector3.UP * 0.55, GameManager.weapon_form, impact_direction, 0.42)
			hit_count += 1
		if freeze_duration > 0.0:
			enemy.apply_skill_freeze(freeze_duration)
		if slow_duration > 0.0:
			enemy.apply_skill_slow(slow_duration, 0.5)
	return hit_count


func cast_ultimate() -> bool:
	if rage < MAX_RAGE or _ultimate_cooldown_remaining > 0.0 or not GameManager.unlocked_skills.has(GameManager.selected_ultimate_skill):
		return false
	var skill_id: String = GameManager.selected_ultimate_skill
	var aim := get_skill_aim_direction()
	BattleFX.play_skill_sound(self, skill_id)
	var radius := 18.0 if skill_id == "ultimate_ice_2" else 7.0
	if skill_id == "ultimate_fire_2":
		radius += float(GameManager.skill_allocations.get("evo_fire_inferno", 0))
	var damage := attack_damage * (4 if radius < 10.0 else 2)
	var vfx_position := global_position + Vector3.UP * 0.6
	if skill_id == "ultimate_wind_1":
		BattleFX.circle_burst(self, vfx_position, "wind", 7.0)
		for angle_index in 8:
			var angle := TAU * float(angle_index) / 8.0
			var radial := Vector3(cos(angle), 0.0, sin(angle))
			BattleFX.slash(self, global_position + Vector3.UP * 0.55 + radial * 3.5, "wind", radial, 1.1)
	elif skill_id == "ultimate_wind_2":
		BattleFX.circle_burst(self, vfx_position, "wind", 7.0)
		BattleFX.claw(self, skill_effect_position(aim, 0.8, 0.55), "wind", aim, 1.5)
	elif skill_id == "ultimate_fire_1":
		_apply_timed_buff(2, 0.0, 5.0)
		BattleFX.circle_burst(self, vfx_position, "fire", 7.0)
		BattleFX.slash(self, skill_effect_position(aim, 0.65, 0.6), "fire", aim, 0.8)
	elif skill_id == "ultimate_fire_2":
		BattleFX.charge(self, global_position + Vector3.UP * 3.5, "fire", 2.2)
		BattleFX.circle_burst(self, vfx_position, "fire", 7.0)
	elif skill_id == "ultimate_ice_1":
		BattleFX.shield(self, global_position, "ice", 2.0, 1.0)
	else:
		BattleFX.circle_burst(self, vfx_position, "ice", 18.0)
		BattleFX.slash(self, vfx_position, "ice", aim, 1.1)
	if skill_id == "ultimate_fire_2":
		health = maxi(1, health - int(ceil(health * 0.5)))
	if skill_id.begins_with("ultimate_wind"):
		movement_speed *= 1.5
		get_tree().create_timer(4.0).timeout.connect(func() -> void:
			if is_inside_tree():
				_apply_skill_bonuses())
	if skill_id == "ultimate_ice_1":
		_ice_pillar_pulses.call_deferred(damage)
	else:
		var ultimate_shape := "global" if skill_id == "ultimate_ice_2" else "circle"
		if skill_id in ["ultimate_fire_2", "ultimate_ice_2"]:
			BattleFX.emberline_burst(self, global_position, GameManager.weapon_form, aim, radius)
		elif skill_id == "ultimate_wind_1":
			BattleFX.emberline_ring(self, global_position, "wind", aim, radius)
		_damage_enemies_in_shape(global_position, aim, ultimate_shape, radius, 0.0, 360.0, damage, 1.0 if skill_id == "ultimate_ice_2" else 0.0)
	rage = 0.0
	_ultimate_cooldown_remaining = get_ultimate_cooldown_duration(skill_id)
	rage_changed.emit(rage, MAX_RAGE)
	return true


func _ice_pillar_pulses(damage: int) -> void:
	for pulse in 3:
		if not is_inside_tree():
			return
		BattleFX.shield(self, global_position, "ice", 0.7, 1.0)
		_damage_enemies_in_shape(global_position, Vector3.ZERO, "circle", 4.0, 0.0, 360.0, damage, 0.5)
		if pulse < 2:
			await get_tree().create_timer(0.7).timeout


## Every state of the fox can take damage, so this calls straight into the current state; whichever
## state doesn't want to lose health (Dead) overrides take_damage().
func _on_hurt_area_3d_hurt(_direction: Vector3, damage: float) -> void:
	print("Nhan sat thuong")
	if is_invulnerable:
		return
	if ice_shield > 0:
		var absorbed := mini(ice_shield, int(damage))
		ice_shield -= absorbed
		damage -= absorbed
		if damage <= 0.0:
			return
	fsm.current_state.take_damage(int(damage))
