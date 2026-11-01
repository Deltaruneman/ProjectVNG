class_name EnemyCharacter
extends BaseCharacter

const HEALTH_BAR_SCENE := preload("res://scenes/ui/enemy_health_bar.tscn")

## Common framework for every enemy. Every child node below is OPTIONAL — attach whichever an
## enemy needs: a stationary barrel doesn't need a RayCast, a crab doesn't need a detection area.
##
##   <Enemy> (EnemyCharacter)
##   └── Direction (Node3D)
##       ├── FrontRayCast3D      hit a wall yet?
##       ├── DownRayCast3D       still floor ahead?
##       ├── DetectPlayerArea3D  is the fox in range yet?
##       └── HurtArea3D          takes hits from the fox

# Two rays that check for walls and floor edges. They sit under Direction so they ROTATE
# automatically with the facing direction — the 2D version had to flip them by hand with scale.x,
# here that's not needed.
var front_ray_cast: RayCast3D
var down_ray_cast: RayCast3D

# Area that detects the fox
var detect_player_area: Area3D
var found_player: Node3D = null
var _skill_slow_base_speed := -1.0
var _skill_slow_factor := 1.0
var _skill_slow_until_msec := 0
var _skill_freeze_until_msec := 0
var _skill_freeze_running := false
var _skill_burn_until_msec := 0
var _skill_burn_damage := 0
var _skill_burn_source: Node3D = null
var _skill_burn_running := false


func _ready() -> void:
	add_to_group("enemies")
	_init_ray_cast()
	_init_detect_player_area()
	_init_hurt_area()
	super._ready()
	health = max_health
	add_child(HEALTH_BAR_SCENE.instantiate())


func apply_skill_freeze(duration: float) -> void:
	if duration <= 0.0 or health <= 0:
		return
	movement_enabled = false
	_skill_freeze_until_msec = maxi(_skill_freeze_until_msec, Time.get_ticks_msec() + int(duration * 1000.0))
	if not _skill_freeze_running:
		_skill_freeze_running = true
		_finish_skill_freeze.call_deferred()


func _finish_skill_freeze() -> void:
	while is_inside_tree() and health > 0 and Time.get_ticks_msec() < _skill_freeze_until_msec:
		var remaining := maxf(0.01, float(_skill_freeze_until_msec - Time.get_ticks_msec()) / 1000.0)
		await get_tree().create_timer(remaining).timeout
	if is_inside_tree() and health > 0:
		movement_enabled = true
	_skill_freeze_running = false


func is_skill_frozen() -> bool:
	return Time.get_ticks_msec() < _skill_freeze_until_msec


func is_skill_slowed() -> bool:
	return _skill_slow_base_speed >= 0.0 and Time.get_ticks_msec() < _skill_slow_until_msec


func apply_skill_slow(duration: float, speed_factor: float = 0.5) -> void:
	if duration <= 0.0 or health <= 0:
		return
	if _skill_slow_base_speed < 0.0:
		_skill_slow_base_speed = movement_speed
	_skill_slow_factor = minf(_skill_slow_factor, clampf(speed_factor, 0.1, 1.0))
	movement_speed = _skill_slow_base_speed * _skill_slow_factor
	_skill_slow_until_msec = maxi(_skill_slow_until_msec, Time.get_ticks_msec() + int(duration * 1000.0))
	var wait_time := maxf(0.0, float(_skill_slow_until_msec - Time.get_ticks_msec()) / 1000.0)
	await get_tree().create_timer(wait_time).timeout
	if is_inside_tree() and Time.get_ticks_msec() >= _skill_slow_until_msec:
		movement_speed = _skill_slow_base_speed
		_skill_slow_base_speed = -1.0
		_skill_slow_factor = 1.0


func apply_skill_burn(source: Node3D, damage_per_tick: int = 1, duration: float = 3.0, tick_interval: float = 1.0) -> void:
	if duration <= 0.0 or tick_interval <= 0.0 or health <= 0:
		return
	_skill_burn_damage = maxi(_skill_burn_damage, damage_per_tick)
	_skill_burn_source = source
	_skill_burn_until_msec = maxi(_skill_burn_until_msec, Time.get_ticks_msec() + int(duration * 1000.0))
	if not _skill_burn_running:
		_skill_burn_running = true
		_run_skill_burn.call_deferred(tick_interval)


func _run_skill_burn(tick_interval: float) -> void:
	while is_inside_tree() and health > 0 and Time.get_ticks_msec() < _skill_burn_until_msec:
		await get_tree().create_timer(tick_interval).timeout
		if not is_inside_tree() or health <= 0 or Time.get_ticks_msec() > _skill_burn_until_msec:
			break
		var hurt_area := get_node_or_null("Direction/HurtArea3D") as HurtArea3D
		if hurt_area != null:
			var source: Node3D = _skill_burn_source if is_instance_valid(_skill_burn_source) else null
			hurt_area.take_damage(Vector3.ZERO, _skill_burn_damage, source)
	_skill_burn_running = false
	_skill_burn_damage = 0
	_skill_burn_source = null


func _init_ray_cast() -> void:
	if has_node("Direction/FrontRayCast3D"):
		front_ray_cast = $Direction/FrontRayCast3D
	if has_node("Direction/DownRayCast3D"):
		down_ray_cast = $Direction/DownRayCast3D


func _init_detect_player_area() -> void:
	if not has_node("Direction/DetectPlayerArea3D"):
		return
	detect_player_area = $Direction/DetectPlayerArea3D
	detect_player_area.body_entered.connect(_on_body_entered)
	detect_player_area.body_exited.connect(_on_body_exited)


func _init_hurt_area() -> void:
	if has_node("Direction/HurtArea3D"):
		$Direction/HurtArea3D.hurt.connect(_on_hurt_area_3d_hurt)


func is_touch_wall() -> bool:
	return front_ray_cast != null and front_ray_cast.is_colliding()


func is_can_fall() -> bool:
	return down_ray_cast != null and not down_ray_cast.is_colliding()


func enable_check_player_in_sight() -> void:
	if detect_player_area != null:
		detect_player_area.get_node("CollisionShape3D").disabled = false


func disable_check_player_in_sight() -> void:
	if detect_player_area != null:
		detect_player_area.get_node("CollisionShape3D").disabled = true


func _on_body_entered(body: Node3D) -> void:
	found_player = body
	_on_player_in_sight(body.global_position)


func _on_body_exited(_body: Node3D) -> void:
	found_player = null
	_on_player_not_in_sight()


## The current state decides how to take the hit — the Dead state overrides this to skip it.
func _on_hurt_area_3d_hurt(direction: Vector3, damage: float) -> void:
	fsm.current_state.take_damage(direction, damage)


## Interrupt an existing hurt state without applying damage.
func on_parried(direction: Vector3) -> void:
	if health <= 0:
		return
	if fsm != null:
		if not fsm.states.has("hurt"):
			return
		velocity.x = direction.x * EnemyState.KNOCKBACK_SPEED
		velocity.z = direction.z * EnemyState.KNOCKBACK_SPEED
		fsm.change_state(fsm.states.hurt)
	else:
		_enter_parry_hurt(direction)


## Only enemies with an existing hurt state override this.
func _enter_parry_hurt(_direction: Vector3) -> void:
	pass


func register_projectile(projectile: Node) -> void:
	for area in projectile.find_children("*", "HitArea3D", true, false):
		area.attacker = self


## Called when the fox comes into range. Override this in whichever enemy needs it.
func _on_player_in_sight(_player_pos: Vector3) -> void:
	pass


## Called when the fox leaves range.
func _on_player_not_in_sight() -> void:
	pass
