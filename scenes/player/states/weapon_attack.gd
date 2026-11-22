extends PlayerState

const BattleFX := preload("res://scenes/player/battle_vfx.gd")
const CHARGE_THRESHOLD := 0.4
const MAX_CHARGE_HOLD := 1.0
const COMBO_END_RECOVERY := 0.5
const STRIKE_RECOVERY := 0.2
const CHARGE_DASH_SPEED := 13.0
const CHARGE_DAGGER_SPEED := 16.0
const COMBO_COUNTS := {"sword": 3, "axe": 3, "spear": 4, "dagger": 1}
const COMBO_BEATS := {"sword": 0.25, "axe": 0.32, "spear": 0.2, "dagger": 0.2}
const CHARGE_DAMAGE := {"sword": 2.0, "axe": 3.0, "spear": 2.0, "dagger": 1.5}

const PHASE_INPUT := 0
const PHASE_COMBO := 1
const PHASE_HEAVY := 2
const PHASE_DASH_OUT := 3
const PHASE_DASH_HIT := 4
const PHASE_DASH_RETURN := 5
const PHASE_RECOVER := 6
const PHASE_LINK := 7
const PHASE_AXE_AIR := 8
const COMBO_LINK_TIME := 0.3

var _phase := PHASE_INPUT
var _kind := "sword"
var _element := ""
var _weapon: Node3D
var _home_position := Vector3.ZERO
var _home_rotation := Vector3.ZERO
var _recovery_start_position := Vector3.ZERO
var _recovery_start_rotation := Vector3.ZERO
var _hand_position := Vector3(0.34, 1.05, 0.24)
var _elapsed := 0.0
var _charge_time := 0.0
var _strike_index := -1
var _strike_fx_played := false
var _hit_active := false
var _dash_target: EnemyCharacter
var _dash_destination := Vector3.ZERO
var _dash_return_origin := Vector3.ZERO
var _previous_shape_scale := Vector3.ONE
var _previous_shape_position := Vector3.ZERO
var _hit_shape: CollisionShape3D
var _hit_area: HitArea3D
var _combo_beat := 0.25
var _combo_count := 1
var _charge_hit_connected := false
var _sprite: Sprite3D
var _home_transform := Transform3D.IDENTITY
var _sprite_transform := Transform3D.IDENTITY
var _sprite_offset := Vector2.ZERO
var _weapon_processing := true
var _buffered := false
var _buffer_released := false
var _buffer_hold := 0.0
var _pose_origin := Vector3.ZERO
var _pose_tip_origin := Vector3.FORWARD
var _last_grip := Vector3.ZERO
var _last_tip := Vector3.FORWARD
var _return_from := Transform3D.IDENTITY
var _return_sprite := Transform3D.IDENTITY
var _return_offset := Vector2.ZERO
var _return_basis := Basis.IDENTITY
var _next_strike := 0
var _old_anim_speed := 1.0
var _flight_start := Vector3.ZERO
var _flight_time := 0.0
var _flight_duration := 0.3
var _axe_descending := false
var _body_offset := Vector2.ZERO
var _legacy_blade := false
var _legacy_blade_suppressed := false
var _source_tip_angle := 3.0 * PI / 4.0
var _recovery_lock_duration := STRIKE_RECOVERY


func _enter() -> void:
	obj.stop_horizontal()
	var equipment: Dictionary = GameManager.inventory.definition_for_slot("main")
	_legacy_blade = bool(equipment.get("legacy", false))
	if _legacy_blade:
		obj.suppress_blade(true)
		_legacy_blade_suppressed = true
	obj.change_animation("attack" if _legacy_blade else "idle")
	_kind = str(equipment.get("kind", "sword"))
	if _kind not in COMBO_COUNTS:
		_kind = "sword" # Blade cũ uses the sword motion while keeping its neutral identity.
	_element = str(equipment.get("resonance", ""))
	_weapon = obj.get_node_or_null("Direction/Blade") as Node3D
	if is_instance_valid(_weapon):
		_home_position = _weapon.position
		_home_rotation = _weapon.rotation
		_home_transform = _weapon.transform
		_weapon_processing = _weapon.is_processing()
		_sprite = _weapon.get_node("Sprite3D") as Sprite3D
		_sprite_transform = _sprite.transform
		_sprite_offset = _sprite.offset
		_weapon.set_process(false)
		_last_grip = _home_position
		_last_tip = Vector3(0.0, 0.3, 1.0)
		_sprite.transform = Transform3D.IDENTITY
		# Every atlas weapon points upper-left; move its lower-right handle onto the grip.
		var size := _sprite.texture.get_size()
		_source_tip_angle = PI / 2.0 if equipment.get("legacy", false) else 3.0 * PI / 4.0
		_sprite.offset = Vector2(0.0, size.y * 0.3) if equipment.get("legacy", false) else Vector2(-size.x * 0.25, size.y * 0.25)
	_hit_area = obj.get_node("Direction/HitArea3D") as HitArea3D
	_hit_shape = _hit_area.get_node("CollisionShape3D") as CollisionShape3D
	_previous_shape_scale = _hit_shape.scale
	_previous_shape_position = _hit_shape.position
	_hit_area.damage = obj.roll_weapon_damage(obj.attack_damage)
	_phase = PHASE_INPUT
	_pose_origin = _home_position
	_elapsed = 0.0
	_charge_time = 0.0
	_strike_index = -1
	_next_strike = 0
	_buffered = false
	_buffer_released = false
	_buffer_hold = 0.0
	_old_anim_speed = obj.anim_player.speed_scale
	_body_offset = (obj.get_node("Sprite3D") as Sprite3D).offset
	_strike_fx_played = false
	_hit_active = false
	_set_hit_active(false)


func _update(delta: float) -> void:
	# Dash is an immediate movement cancel: discard the current attack phase/buffer by exiting this state.
	if control_dash():
		return
	if _phase in [PHASE_COMBO, PHASE_LINK]:
		_capture_next_click(delta)
	match _phase:
		PHASE_INPUT:
			_update_input_charge(delta)
		PHASE_COMBO:
			_update_combo(delta)
		PHASE_HEAVY:
			_update_heavy(delta)
		PHASE_DASH_OUT:
			_update_dash_out(delta)
		PHASE_DASH_HIT:
			_update_dash_hit(delta)
		PHASE_DASH_RETURN:
			_update_dash_return(delta)
		PHASE_RECOVER:
			_update_recovery(delta)
		PHASE_LINK:
			_update_link(delta)
		PHASE_AXE_AIR:
			_update_axe_air(delta)


func _update_input_charge(delta: float) -> void:
	_charge_time += delta
	var t := _ease_out(_charge_time / 0.12)
	_set_weapon_pose(_pose_origin.lerp(_hand_position, t), Vector3(0.0, 0.4, 1.0))
	if _charge_time >= MAX_CHARGE_HOLD:
		_start_charged_attack()
	elif not Input.is_action_pressed("attack"):
		if _charge_time >= CHARGE_THRESHOLD:
			_start_charged_attack()
		else:
			_start_combo()


func _capture_next_click(delta: float) -> void:
	if Input.is_action_just_pressed("attack") and not _buffered:
		_buffered = true
		_buffer_released = false
		_buffer_hold = 0.0
	if _buffered and not _buffer_released:
		_buffer_hold += delta
		if not Input.is_action_pressed("attack"):
			_buffer_released = true


func _consume_next_click() -> bool:
	if not _buffered:
		return false
	_buffered = false
	_next_strike = (_strike_index + 1) % _combo_count
	_pose_origin = _last_grip
	if _buffer_released:
		if _buffer_hold >= CHARGE_THRESHOLD:
			_phase = PHASE_INPUT
			_start_charged_attack()
		else:
			_start_combo()
	else:
		_phase = PHASE_INPUT
		_charge_time = _buffer_hold
	return true


func _update_link(delta: float) -> void:
	obj.stop_horizontal()
	if _consume_next_click():
		return
	_elapsed += delta
	if control_dash() or control_moving():
		return
	if _elapsed >= COMBO_LINK_TIME:
		_finish_attacking(true)

func _start_combo() -> void:
	_phase = PHASE_COMBO
	_elapsed = 0.0
	_strike_index = _next_strike
	_strike_fx_played = false
	_pose_origin = _last_grip
	_pose_tip_origin = _last_tip
	_play_attack_pose(0.0)
	var equipment: Dictionary = GameManager.inventory.definition_for_slot("main")
	var tempo := maxf(0.35, float(equipment.get("tempo", 1.0)))
	var reach := float(equipment.get("reach", 1.0)) * (1.0 + 0.1 * GameManager.inventory.enchant_rank("main", "reach"))
	_hit_shape.scale = _previous_shape_scale * Vector3(float(equipment.get("width", 1.0)), 1.0, reach)
	_hit_shape.position.z = _previous_shape_position.z * reach
	_set_hit_active(false)
	_combo_beat = float(COMBO_BEATS[_kind]) / tempo
	_combo_count = int(COMBO_COUNTS[_kind])


func _update_combo(delta: float) -> void:
	_elapsed += delta
	var progress := clampf(_elapsed / _combo_beat, 0.0, 1.0)
	var hit_window := progress >= 0.34 and progress <= 0.66
	_apply_combo_pose(progress, _strike_index)
	if hit_window and not _strike_fx_played:
		_spawn_strike_fx(false)
		_strike_fx_played = true
	_set_hit_active(hit_window)
	_play_attack_pose(progress)
	obj.stop_horizontal()
	if _kind == "spear" and hit_window:
		var forward := obj.forward().normalized()
		obj.velocity.x = forward.x * 2.6
		obj.velocity.z = forward.z * 2.6
	if progress >= 1.0:
		_set_hit_active(false)
		obj.stop_horizontal()
		if _strike_index >= _combo_count - 1:
			# The final hit closes this combo. Discard surplus buffered clicks so
			# button mashing cannot skip the end-of-combo recovery.
			_buffered = false
			_buffer_released = false
			_buffer_hold = 0.0
			_finish_attacking(true)
		else:
			_phase = PHASE_LINK
			_elapsed = 0.0
			_consume_next_click()

func _apply_combo_pose(progress: float, strike: int) -> void:
	if _legacy_blade:
		return # The original Blade uses Player's attack animation; it never flies out from the back.
	# Coordinates are in Direction space: +Z forward, +X right, +Y up.
	# Grip stays near the hands; tip follows an arc around it, never the floating rest tilt.
	var start := Vector3(0.35, 1.0, 0.22)
	var end := Vector3(-0.28, 0.96, 0.55)
	var from_tip := Vector3(1.0, 0.2, -0.25)
	var to_tip := Vector3(-0.85, -0.15, 0.5)
	var sweep := true
	match _kind:
		"sword":
			if strike == 1:
				start = Vector3(-0.3, 1.12, 0.3)
				end = Vector3(0.34, 0.95, 0.5)
				from_tip = Vector3(-0.9, 0.5, -0.1)
				to_tip = Vector3(0.8, -0.35, 0.65)
			elif strike == 2:
				start = Vector3(0.2, 1.5, 0.05)
				end = Vector3(0.12, 0.75, 0.7)
				from_tip = Vector3(0.0, 1.0, -0.3)
				to_tip = Vector3(0.0, -0.65, 1.0)
		"axe":
			start = Vector3(0.35, 1.25, 0.05)
			end = Vector3(-0.2, 0.8, 0.65)
			from_tip = Vector3(1.0, 0.75, -0.3)
			to_tip = Vector3(-0.8, -0.45, 0.8)
			if strike == 1:
				start.x = -0.35
				end.x = 0.25
				from_tip.x = -1.0
				to_tip.x = 0.8
			elif strike == 2:
				start = Vector3(0.15, 1.6, 0.0)
				end = Vector3(0.15, 0.62, 0.8)
				from_tip = Vector3(0.0, 1.0, -0.4)
				to_tip = Vector3(0.0, -0.85, 0.65)
		"spear":
			start = Vector3(0.22, 0.95, -0.2)
			end = Vector3(0.12, 1.0, 1.0 if strike == 3 else 0.75)
			from_tip = Vector3(0.0, 0.05, 1.0)
			to_tip = from_tip
			sweep = false
			if strike == 1:
				start.y = 0.75
				end.y = 1.05
				to_tip.y = 0.18
			elif strike == 2:
				start = Vector3(-0.35, 1.0, 0.1)
				end = Vector3(0.3, 0.92, 0.55)
				from_tip = Vector3(-1.0, 0.0, 0.2)
				to_tip = Vector3(1.0, 0.0, 0.3)
				sweep = true
		"dagger":
			start = Vector3(0.25, 1.05, 0.15)
			end = Vector3(0.1, 0.98, 0.9)
			from_tip = Vector3(0.0, 0.0, 1.0)
			to_tip = from_tip
			sweep = false
	var grip: Vector3
	var tip: Vector3
	if progress < 0.3:
		var t := smoothstep(0.0, 0.3, progress)
		grip = _pose_origin.lerp(start, t)
		tip = _pose_tip_origin.normalized().slerp(from_tip.normalized(), t)
	elif progress < 0.68:
		var t := _ease_out((progress - 0.3) / 0.38)
		grip = start.lerp(end, t)
		tip = from_tip.normalized().slerp(to_tip.normalized(), t)
		if sweep:
			# Arc bulges forward through contact rather than cutting through the torso.
			grip.z += sin(t * PI) * 0.2
	else:
		var t := smoothstep(0.68, 1.0, progress)
		grip = end.lerp(end + Vector3(0.0, 0.08, -0.15), t)
		tip = to_tip.normalized()
	_set_weapon_pose(grip, tip)

func _start_charged_attack() -> void:
	if _phase != PHASE_INPUT:
		return
	if not obj.try_spend_stamina(Player.STAMINA_CHARGE_COST):
		if obj.stamina_exhausted:
			return
		_start_combo()
		return
	_elapsed = 0.0
	_strike_index = -1
	var equipment: Dictionary = GameManager.inventory.definition_for_slot("main")
	var reach := float(equipment.get("reach", 1.0)) * (1.0 + 0.1 * GameManager.inventory.enchant_rank("main", "reach"))
	var width := float(equipment.get("width", 1.0))
	match _kind:
		"sword":
			reach *= 1.65
			width *= 1.15
		"axe":
			reach *= 1.35
			width *= 2.0
		"spear":
			reach *= 1.5
			width *= 0.85
		"dagger":
			reach *= 1.2
	_hit_shape.scale = _previous_shape_scale * Vector3(width, 1.0, reach)
	_hit_shape.position.z = _previous_shape_position.z * reach
	var multiplier := float(CHARGE_DAMAGE[_kind])
	_hit_area.damage = obj.roll_weapon_damage(maxi(1, ceili(float(obj.attack_damage) * multiplier)))
	_set_hit_active(false)
	_dash_return_origin = obj.global_position
	if not _charge_hit_connected:
		_hit_area.hitted.connect(_on_charge_hit)
		_charge_hit_connected = true
	if _kind == "axe":
		_phase = PHASE_AXE_AIR
		_axe_descending = false
		obj.velocity.y = 8.5
	elif _kind in ["spear", "dagger"]:
		_begin_target_dash()
	else:
		_phase = PHASE_HEAVY
		_elapsed = 0.0
		_strike_fx_played = false


func _begin_target_dash() -> void:
	_dash_target = _nearest_enemy()
	var dash_direction := obj.forward().normalized()
	if is_instance_valid(_dash_target):
		dash_direction = _dash_target.global_position - obj.global_position
		dash_direction.y = 0.0
		if dash_direction.length_squared() > 0.001:
			dash_direction = dash_direction.normalized()
			obj.call("face_movement", dash_direction)
		var stop_distance := 0.45 if _kind == "dagger" else 0.9
		_dash_destination = _dash_target.global_position - dash_direction * stop_distance
	else:
		_dash_destination = obj.global_position + dash_direction * (2.0 if _kind == "dagger" else 3.0)
	if _kind == "dagger" and is_instance_valid(_dash_target) and obj.global_position.distance_to(_dash_destination) < 0.15:
		_dash_destination = obj.global_position + dash_direction * 0.15
	_phase = PHASE_DASH_OUT
	_flight_start = obj.global_position
	_flight_time = 0.0
	_flight_duration = clampf(_flight_start.distance_to(_dash_destination) / CHARGE_DAGGER_SPEED, 0.2, 0.65)
	_set_hit_active(false)
	_spawn_strike_fx(false)


func _update_dash_out(delta: float) -> void:
	if _kind == "dagger":
		_play_attack_pose(0.35)
		_set_weapon_pose(_hand_position + Vector3(0.0, 0.0, 0.7), Vector3(0.0, 0.0, 1.0))
		if _fly_segment(delta, _dash_destination, 0.8):
			_phase = PHASE_DASH_HIT
			_elapsed = 0.0
			_spawn_strike_fx(true)
		return
	var toward := _dash_destination - obj.global_position
	toward.y = 0.0
	if toward.length() <= 0.55:
		obj.stop_horizontal()
		_phase = PHASE_DASH_HIT
		_elapsed = 0.0
		_spawn_strike_fx(true)
		return
	var direction := toward.normalized()
	if obj.test_move(obj.global_transform, direction * minf(0.18, toward.length())):
		obj.stop_horizontal()
		_phase = PHASE_DASH_HIT
		_elapsed = 0.0
		_spawn_strike_fx(true)
		return
	var speed := CHARGE_DAGGER_SPEED if _kind == "dagger" else CHARGE_DASH_SPEED
	var frame_speed := minf(speed, toward.length() / maxf(delta, 0.001))
	obj.velocity.x = direction.x * frame_speed
	obj.velocity.z = direction.z * frame_speed
	_set_weapon_pose(_hand_position + Vector3(0.0, 0.0, 0.85), Vector3(0.0, 0.0, 1.0))


func _update_dash_hit(delta: float) -> void:
	_elapsed += delta
	_play_attack_pose(0.45 + _elapsed * 2.0)
	if _kind == "dagger":
		obj.velocity.y = obj.gravity * delta if not obj.is_on_floor() else 0.0
	_set_hit_active(_elapsed <= 0.14)
	_set_weapon_pose(Vector3(0.1, 1.0, 0.85), Vector3(0.0, 0.0, 1.0))
	if _elapsed > 0.14:
		_set_hit_active(false)
		if _kind == "dagger":
			_phase = PHASE_DASH_RETURN
			_flight_start = obj.global_position
			_flight_time = 0.0
			_flight_duration = clampf(_flight_start.distance_to(_dash_return_origin) / CHARGE_DAGGER_SPEED, 0.2, 0.65)
		else:
			_finish_attacking()


func _update_dash_return(delta: float) -> void:
	_play_attack_pose(0.8)
	_set_weapon_pose(_hand_position, Vector3(0.0, 0.0, 1.0))
	if _fly_segment(delta, _dash_return_origin, 0.95):
		_finish_attacking()


func _fly_segment(delta: float, destination: Vector3, height: float) -> bool:
	_flight_time += delta
	var t := clampf(_flight_time / _flight_duration, 0.0, 1.0)
	var desired := _flight_start.lerp(destination, smoothstep(0.0, 1.0, t))
	desired.y += sin(t * PI) * height + 0.035
	var motion := desired - obj.global_position
	# Probe the full frame's 3D path; retain collision/gravity through Player movement.
	var blocked := obj.test_move(obj.global_transform, motion)
	obj.velocity = motion / maxf(delta, 0.001)
	if not obj.is_on_floor():
		obj.velocity.y += obj.gravity * delta
	if blocked:
		obj.stop_horizontal()
		return true
	return t >= 1.0


func _update_axe_air(delta: float) -> void:
	_elapsed += delta
	obj.stop_horizontal()
	_set_hit_active(false)
	_play_attack_pose(0.15 if not _axe_descending else 0.36)
	_set_weapon_pose(Vector3(0.15, 1.55, 0.0), Vector3(0.0, 1.0, -0.15))
	if _elapsed >= 0.23 or obj.is_on_ceiling():
		_axe_descending = true
		obj.velocity.y = -18.0
	if _axe_descending and obj.is_on_floor():
		obj.velocity.y = 0.0
		_phase = PHASE_HEAVY
		_elapsed = 0.68 * 0.38
		_strike_fx_played = false
	elif _elapsed > 1.5:
		# No ground underneath: release state and let normal falling continue.
		_finish_attacking()

func _update_heavy(delta: float) -> void:
	_elapsed += delta
	var progress := clampf(_elapsed / 0.68, 0.0, 1.0)
	_play_attack_pose(progress)
	var active := progress >= 0.38 and progress <= 0.64
	_set_hit_active(active)
	if active and not _strike_fx_played:
		_spawn_strike_fx(true)
		_strike_fx_played = true
	var raised := Vector3(0.18, 1.5, 0.0) if _kind == "axe" else Vector3(0.2, 1.0, -0.2)
	var end := Vector3(0.12, 0.65, 0.85) if _kind == "axe" else Vector3(0.1, 1.0, 1.15)
	var t := _ease_out((progress - 0.28) / 0.36)
	var tip := Vector3(0.0, 1.0, -0.3).slerp(Vector3(0.0, -0.65, 1.0).normalized(), t) if _kind == "axe" else Vector3(0.0, 0.0, 1.0)
	_set_weapon_pose(raised.lerp(end, t), tip)
	if progress >= 1.0:
		_finish_attacking()

func _update_recovery(delta: float) -> void:
	_elapsed += delta
	var t := smoothstep(0.0, 0.2, _elapsed)
	if is_instance_valid(_weapon):
		_weapon.transform = Transform3D(_return_basis.slerp(_home_transform.basis.orthonormalized(), t).scaled(_return_from.basis.get_scale().lerp(_home_transform.basis.get_scale(), t)), _return_from.origin.lerp(_home_transform.origin, t))
		_sprite.transform = _return_sprite.interpolate_with(_sprite_transform, t)
		_sprite.offset = _return_offset.lerp(_sprite_offset, t)
	obj.stop_horizontal()
	if _elapsed >= _recovery_lock_duration:
		change_state(fsm.states.idle)

func _finish_attacking(combo_finished: bool = false) -> void:
	_set_hit_active(false)
	# Recovery still locks actions, but the body must no longer hold the last attack frame.
	obj.anim_player.speed_scale = _old_anim_speed
	(obj.get_node("Sprite3D") as Sprite3D).offset = _body_offset
	if _legacy_blade_suppressed:
		obj.suppress_blade(false)
		_legacy_blade_suppressed = false
	obj.change_animation("idle")
	obj.call("_check_changed_animation")
	_phase = PHASE_RECOVER
	_elapsed = 0.0
	_recovery_lock_duration = COMBO_END_RECOVERY if combo_finished else STRIKE_RECOVERY
	if is_instance_valid(_weapon):
		_recovery_start_position = _weapon.position
		_recovery_start_rotation = _weapon.rotation
		_return_from = _weapon.transform
		_return_basis = _weapon.basis.orthonormalized()
		_return_sprite = _sprite.transform
		_return_offset = _sprite.offset
	obj.stop_horizontal()


func _spawn_strike_fx(charged: bool) -> void:
	var direction := obj.forward().normalized()
	var position := obj.global_position + Vector3.UP * 0.82 + direction * (1.0 if charged else 0.82)
	if _kind == "spear":
		direction = _world_weapon_tip_direction()
		position = _weapon_fx_position(direction)
	var effect_id := "melee/sword-slash"
	var extent := 1.05
	match _kind:
		"axe":
			effect_id = "impacts/ground-slam" if charged else "melee/sword-slash"
			extent = 1.65 if charged else 0.85
			if charged:
				position = obj.global_position + Vector3.UP * 0.12 + direction * 0.55
				direction = Vector3.ZERO # Ground shock stays upright at every facing.
				BattleFX.weapon_attack_effect(obj, "melee/thrust", position + Vector3.UP * 1.45, _element, Vector3.DOWN, 1.7)
		"spear":
			effect_id = "melee/spear-sweep" if not charged and _strike_index == 2 else "melee/thrust"
			extent = 1.55 if charged else 1.0
		"dagger":
			effect_id = "melee/dagger-flurry" if charged else "melee/thrust"
			extent = 1.15 if charged else 0.68
		"sword":
			effect_id = "melee/thrust" if charged else "melee/sword-slash"
			extent = 1.35 if charged else 0.9
	var effect := BattleFX.weapon_attack_effect(obj, effect_id, position, _element, direction, extent)
	if effect != null:
		effect.speed_scale = 2.8 if charged else 2.0
		effect.flip_v = not charged and _strike_index == 1 and _kind in ["sword", "axe"]


func _world_weapon_tip_direction() -> Vector3:
	if not is_instance_valid(_weapon):
		return obj.forward().normalized()
	var source_tip := Vector3(cos(_source_tip_angle), sin(_source_tip_angle), 0.0)
	var world_tip: Vector3 = _weapon.global_basis * source_tip
	return world_tip.normalized() if world_tip.length_squared() > 0.001 else obj.forward().normalized()


func _weapon_fx_position(direction: Vector3) -> Vector3:
	if not is_instance_valid(_weapon):
		return obj.global_position + Vector3.UP * 0.82 + direction * 0.82
	var weapon_extent := 1.15
	if is_instance_valid(_sprite) and _sprite.texture != null:
		# Spear sweeps are wide, centered sprites. Start their center farther out
		# from the animated weapon tip so the inner half doesn't wash over Player.
		weapon_extent = clampf(_sprite.texture.get_size().x * _sprite.pixel_size * 0.75, 1.15, 1.8)
	return _weapon.global_position + direction * (weapon_extent + 0.35)


func _nearest_enemy() -> EnemyCharacter:
	var nearest: EnemyCharacter
	var nearest_distance := INF
	for candidate: Node in obj.get_tree().get_nodes_in_group("enemies"):
		if not is_instance_valid(candidate) or not (candidate is EnemyCharacter):
			continue
		var enemy := candidate as EnemyCharacter
		if enemy.health <= 0:
			continue
		var distance := obj.global_position.distance_squared_to(enemy.global_position)
		if distance < nearest_distance:
			nearest = enemy
			nearest_distance = distance
	return nearest


func _on_charge_hit(area: Area3D) -> void:
	var enemy := obj.call("_get_enemy_from_hurt_area", area) as EnemyCharacter
	if enemy == null or enemy.health <= 0:
		return
	var direction := enemy.global_position - obj.global_position
	direction.y = 0.0
	if direction.length_squared() <= 0.001:
		direction = obj.forward()
	direction = direction.normalized()
	var force := 0.0
	match _kind:
		"sword": force = 12.0
		"axe":
			force = 9.0
			enemy.velocity.y = maxf(enemy.velocity.y, 7.5)
		"spear": force = 10.0
	if force > 0.0:
		enemy.velocity.x += direction.x * force
		enemy.velocity.z += direction.z * force


func _set_hit_active(active: bool) -> void:
	if not is_instance_valid(_hit_shape) or _hit_active == active:
		return
	_hit_active = active
	_hit_shape.set_deferred("disabled", not active)


func _set_weapon_pose(local_position: Vector3, tip_direction: Vector3) -> void:
	_last_grip = local_position
	_last_tip = tip_direction.normalized()
	if not is_instance_valid(_weapon):
		return
	_weapon.position = local_position
	var camera := obj.get_viewport().get_camera_3d()
	var view_basis := camera.global_basis if camera != null else Basis.IDENTITY
	var world_tip: Vector3 = obj.get_node("Direction").global_basis * _last_tip
	var projected := Vector2(world_tip.dot(view_basis.x), world_tip.dot(view_basis.y))
	if projected.length_squared() < 0.001:
		projected = Vector2(1.0, 0.0)
	# Atlas tip is NW (135deg), handle SE. Align this axis with projected world tip.
	_weapon.global_basis = view_basis * Basis(Vector3.BACK, projected.angle() - _source_tip_angle)
	_sprite.position = Vector3.ZERO
	obj.call("place_weapon_below_body", _sprite)

func _play_attack_pose(progress: float) -> void:
	var body_sprite := obj.get_node("Sprite3D") as Sprite3D
	if _legacy_blade:
		obj.change_animation("attack")
	else:
		# Other weapons use a compact run-step with a short forward body pulse;
		# the weapon's own hand path carries the strike, without the two-arm pose.
		obj.change_animation("run")
	obj.call("_check_changed_animation")
	obj.anim_player.speed_scale = 0.0
	obj.anim_player.seek(clampf(progress, 0.0, 0.99) * obj.anim_player.current_animation_length, true)
	if not _legacy_blade:
		var camera := obj.get_viewport().get_camera_3d()
		var forward := obj.forward().normalized()
		var advance := Vector2.ZERO
		if camera != null:
			advance = Vector2(forward.dot(camera.global_basis.x), -forward.dot(camera.global_basis.y)).normalized()
		var pulse := sin(clampf(progress, 0.0, 1.0) * PI)
		var hit_recoil := -sin(clampf((progress - 0.46) / 0.22, 0.0, 1.0) * PI) * 1.5
		body_sprite.offset = _body_offset + advance * pulse * 2.0 + Vector2(0.0, pulse * 0.6 + hit_recoil)
	else:
		body_sprite.offset = _body_offset + Vector2(0.0, sin(clampf(progress, 0.0, 1.0) * PI) * (1.5 if _kind == "axe" else 0.8))


func _ease_out(value: float) -> float:
	var t := clampf(value, 0.0, 1.0)
	return 1.0 - pow(1.0 - t, 3.0)


func _exit() -> void:
	if is_instance_valid(_hit_shape):
		_hit_shape.set_deferred("disabled", true)
		_hit_shape.scale = _previous_shape_scale
		_hit_shape.position = _previous_shape_position
	_hit_active = false
	if is_instance_valid(_weapon):
		_weapon.transform = _home_transform
		_sprite.transform = _sprite_transform
		_sprite.offset = _sprite_offset
		_weapon.set_process(_weapon_processing)
	if is_instance_valid(_hit_area) and _charge_hit_connected and _hit_area.hitted.is_connected(_on_charge_hit):
		_hit_area.hitted.disconnect(_on_charge_hit)
	_charge_hit_connected = false
	if _legacy_blade_suppressed and is_instance_valid(obj):
		obj.suppress_blade(false)
		_legacy_blade_suppressed = false
	if is_instance_valid(obj):
		if _kind == "dagger" and _phase in [PHASE_DASH_OUT, PHASE_DASH_HIT, PHASE_DASH_RETURN]:
			obj.velocity.y = minf(obj.velocity.y, 0.0)
		obj.anim_player.speed_scale = _old_anim_speed
		(obj.get_node("Sprite3D") as Sprite3D).offset = _body_offset
		obj.stop_horizontal()


## Read-only presentation contract; FPS never advances combat or activates hitboxes.
func get_first_person_pose() -> Dictionary:
	var phase_name := "idle"
	var progress := 0.0
	match _phase:
		PHASE_INPUT:
			phase_name = "charge"
			progress = clampf(_charge_time / MAX_CHARGE_HOLD, 0.0, 1.0)
		PHASE_COMBO:
			phase_name = "strike"
			progress = clampf(_elapsed / _combo_beat, 0.0, 1.0)
		PHASE_HEAVY:
			phase_name = "heavy"
			progress = clampf(_elapsed / 0.68, 0.0, 1.0)
		PHASE_DASH_OUT, PHASE_DASH_HIT:
			phase_name = "thrust"
			progress = clampf(_flight_time / maxf(_flight_duration, 0.01), 0.0, 1.0) if _phase == PHASE_DASH_OUT else 1.0
		PHASE_AXE_AIR:
			phase_name = "lift"
			progress = 1.0
		PHASE_LINK, PHASE_DASH_RETURN:
			phase_name = "hold"
		PHASE_RECOVER:
			phase_name = "recover"
			progress = clampf(_elapsed / 0.2, 0.0, 1.0)
	var pose := {"phase": phase_name, "progress": progress, "strike": _strike_index, "kind": _kind, "legacy": _legacy_blade, "grip": _last_grip, "tip": _last_tip}
	if _legacy_blade and _phase in [PHASE_COMBO, PHASE_HEAVY]:
		# The old Blade is baked into these four actual body animation frames.
		# Side-view grip/tip pixels preserve its raised -> downward/outward cut.
		var body := obj.get_node("Sprite3D") as Sprite3D
		var frame := clampi(int(body.frame / body.hframes) - 11, 0, 3)
		var grips := [Vector2(40, 43), Vector2(40, 49), Vector2(40, 49), Vector2(40, 49)]
		var tips := [Vector2(44, 32), Vector2(54, 52), Vector2(53, 52), Vector2(53, 52)]
		var direction: Vector2 = tips[frame] - grips[frame]
		pose["legacy_frame"] = frame
		pose["legacy_sheet"] = body.texture
		pose["legacy_grip_pixel"] = grips[frame]
		pose["legacy_tip_pixel"] = tips[frame]
		pose["grip"] = Vector3(0.34, 1.05 - (grips[frame].y - 43.0) * 0.045, 0.24 + float(frame > 0) * 0.3)
		pose["tip"] = Vector3(0.0, -direction.y, direction.x).normalized()
	return pose
