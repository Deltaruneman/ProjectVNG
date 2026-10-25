class_name BaseCharacter
extends CharacterBody3D

## The Y-axis rotation of the Direction node for each facing direction. A character's front is its
## local +Z (Vector3.MODEL_FRONT) and the topdown camera sits toward +Z, so yaw 0 faces "down"
## (toward the camera) and PI faces "up".
const DIRECTION_YAW: Dictionary = {
	"up": PI,
	"left": -PI / 2,
	"down": 0.0,
	"right": PI / 2,
}

## Những animation chỉ có 1 bản duy nhất, KHÔNG ghép hậu tố hướng (ví dụ "parry" thay vì "parry_down").
const NON_DIRECTIONAL_ANIMATIONS: Array[String] = []

## The opposite direction, used by turn_around().
const OPPOSITE_DIRECTION: Dictionary = {
	"up": "down",
	"down": "up",
	"left": "right",
	"right": "left",
}

@export var movement_speed: float = 6.0 # Cập nhật tốc độ từ Source 1
@export var gravity: float = 24.0
@export var input_lock_timer: float = 0.0 # Bổ sung từ Source 1
@export var direction: String = "down"

@export var attack_damage: int = 1
@export var max_health: int = 3

## Phát ra mỗi khi máu thay đổi (HUD lắng nghe tín hiệu này).
signal health_changed(current: int, maximum: int)

var health: int = max_health:
	set(value):
		health = clampi(value, 0, max_health)
		health_changed.emit(health, max_health)

## Turn off to make the character stand absolutely still: no gravity, no move_and_slide().
var movement_enabled: bool = true

var jump_speed: float = 12.0

## Dash: quãng đường lướt ~ dash_speed * dash_duration (mặc định 18 * 0.15 = 2.7 đơn vị)
@export var dash_speed: float = 30.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 0.75
var dash_cooldown_timer: float = 0.0

## Parry: trong `parry_window` giây đầu của state Parry, đòn đánh từ phía trước sẽ bị gạt đi.
@export var parry_window: float = 0.167
@export var parry_cooldown: float = 0.5
var parry_cooldown_timer: float = 0.0
## Khi true, nhân vật đang trong khung thời gian parry (xem PlayerState.take_damage)
var parrying: bool = false

## Khi true, nhân vật không nhận sát thương (dùng cho dash)
var invincible: bool = false
var maxjump: int = 2 
var curjump: int = 0 

var fsm: FSM = null
var current_animation = null

@onready var sprite: Sprite3D = $Sprite3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var _next_animation = null
var _next_direction: String = "down"
var _played_direction: String = ""

func _ready() -> void:
	# max_health là @export nên có thể đã được đổi trong Inspector -> đồng bộ lại máu ban đầu
	health = max_health
	_next_direction = direction
	_apply_direction()

func _physics_process(delta: float) -> void:
	_check_changed_animation()
	
	# Giảm timer khóa input (Bổ sung từ Source 1)
	if input_lock_timer > 0:
		input_lock_timer -= delta
		
	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	if parry_cooldown_timer > 0.0:
		parry_cooldown_timer -= delta

	if fsm != null:
		fsm._update(delta)
	_update_movement(delta)
	_check_changed_direction()


func _update_movement(delta: float) -> void:
	if not is_inside_tree():
		return

	if not movement_enabled:
		return
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		curjump = 0 
		
	move_and_slide()

# Pick the facing direction from the input vector: whichever axis is stronger wins
static func direction_from_input(input: Vector2) -> String:
	if absf(input.x) > absf(input.y):
		return "right" if input.x > 0.0 else "left"
	return "down" if input.y > 0.0 else "up"

func turn_around() -> void:
	if _next_direction != direction:
		return
	_next_direction = OPPOSITE_DIRECTION[direction]

func is_left() -> bool:
	return direction == "left"

func is_right() -> bool:
	return direction == "right"

func turn_left() -> void:
	_next_direction = "left"

func turn_right() -> void:
	_next_direction = "right"

func turn_up() -> void:
	_next_direction = "up"

func turn_down() -> void:
	_next_direction = "down"

func jump() -> void:
	velocity.y = jump_speed
	curjump += 1 

func stop_move() -> void:
	velocity = Vector3.ZERO

func stop_horizontal() -> void:
	velocity.x = 0.0
	velocity.z = 0.0

func change_animation(new_animation: String) -> void:
	_next_animation = new_animation

func change_direction(new_direction: String) -> void:
	_next_direction = new_direction

# The actual animation name to run on AnimationPlayer
func get_animation_name() -> String:
	if current_animation == null:
		return ""
	if current_animation in NON_DIRECTIONAL_ANIMATIONS:
		return current_animation
	return "%s_%s" % [current_animation, direction]

func _check_changed_animation() -> void:
	var need_play: bool = false
	if _next_animation != current_animation:
		current_animation = _next_animation
		need_play = true
	# Changing direction must also replay the animation (trừ animation không theo hướng)
	if direction != _played_direction:
		_played_direction = direction
		if not (current_animation in NON_DIRECTIONAL_ANIMATIONS):
			need_play = true
	if need_play and anim_player != null and current_animation != null:
		anim_player.play(get_animation_name())

func _check_changed_direction() -> void:
	if _next_direction != direction:
		direction = _next_direction
		_on_changed_direction()
		_apply_direction() 

# Rotate the Direction node to the facing direction.
func _apply_direction() -> void:
	$Direction.rotation.y = DIRECTION_YAW[direction]

func _on_changed_direction() -> void:
	pass

func take_damage(damage: int) -> void:
	if invincible:
		return
	health -= damage

## The facing vector, in the XZ plane.
func forward() -> Vector3:
	return Vector3.MODEL_FRONT.rotated(Vector3.UP, DIRECTION_YAW[direction])

## The facing direction toward a position: whichever XZ axis has the larger difference wins.
static func direction_to(from: Vector3, to: Vector3) -> String:
	var delta := to - from
	if absf(delta.x) > absf(delta.z):
		return "right" if delta.x > 0.0 else "left"
	return "down" if delta.z > 0.0 else "up"

## Can be picked up when it has both the Carried and Thrown states
func can_be_carried() -> bool:
	if fsm == null or not fsm.states.has("carried") or not fsm.states.has("thrown"):
		return false
	return fsm.current_state != fsm.states.carried and fsm.current_state != fsm.states.thrown
