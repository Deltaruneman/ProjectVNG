extends EnemyCharacter

@export var bullet_speed: float = 12.0
@onready var bullet_factory: Node3DFactory = $Direction/BulletFactory

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Idle)
	super._ready()

func fire() -> void:
	var bullet := bullet_factory.create() as RigidBody3D
	register_projectile(bullet)
	bullet.apply_impulse(forward() * bullet_speed)
