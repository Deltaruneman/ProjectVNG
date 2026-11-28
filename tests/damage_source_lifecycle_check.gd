extends Node3D
var checks := 0
var failures := 0
var events := 0
var received_source: Node3D
var received_damage := 0.0
var receiver: HurtArea3D
func check(ok: bool,label: String) -> void:
	checks += 1
	if not ok: failures += 1
	print("PASS " if ok else "FAIL ",label)
func frames(n: int = 3) -> void:
	for i in n:
		await get_tree().physics_frame
		await get_tree().process_frame
func make_receiver() -> HurtArea3D:
	var area := HurtArea3D.new()
	area.collision_layer = 4
	area.collision_mask = 0
	area.position = Vector3(0,0.9,0)
	var collision := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.6
	collision.shape = sphere
	area.add_child(collision)
	add_child(area)
	return area
func _ready() -> void:
	if not "ArcanaDamageSource-20261128" in OS.get_user_data_dir():
		get_tree().quit(2)
		return
	run.call_deferred()
func run() -> void:
	SaveSystem.save_path = "user://damage-source-fixture.json"
	GameManager.reset()
	receiver = make_receiver()
	receiver.hurt.connect(func(_direction: Vector3,damage: float) -> void:
		events += 1
		received_damage += damage
		received_source = receiver.attacker)
	var caster := Node3D.new()
	add_child(caster)
	var spell: Node3D = load("res://scenes/enemies/darkfairy/darkfairy_spell.tscn").instantiate()
	spell.source = caster
	add_child(spell)
	spell.set_physics_process(false)
	await frames(4)
	caster.free()
	spell.set_physics_process(true)
	await get_tree().create_timer(0.9).timeout
	check(events == 1 and is_equal_approx(received_damage,1.0),"actual delayed Fairy spell delivers damage after caster is freed")
	check(received_source == null,"expired spell source reported as null attribution")
	if OS.get_cmdline_user_args().has("--before"):
		print("DAMAGE_SOURCE_BEFORE_RESULT ",checks-failures,"/",checks)
		get_tree().quit(1 if failures else 0)
		return
	if is_instance_valid(spell): spell.queue_free()
	await frames()
	var live := Node3D.new()
	add_child(live)
	var before := events
	receiver.take_damage(Vector3.RIGHT,0.5,live)
	check(events == before+1 and received_source == live,"live source remains visible to synchronous hit consumers")
	check(receiver.attacker == null,"attribution restored to null after delivery")
	receiver.attacker = live
	var freed := Node3D.new()
	add_child(freed)
	freed.free()
	before = events
	receiver.take_damage(Vector3.ZERO,0.5,freed)
	check(events == before+1 and received_source == null,"direct freed third argument safely delivers damage")
	check(receiver.attacker == live,"live prior attribution restored after expired-source hit")
	var queued := Node3D.new()
	add_child(queued)
	queued.queue_free()
	receiver.take_damage(Vector3.ZERO,0.5,queued)
	check(received_source == null,"queued-for-deletion source has no live attribution")
	receiver.take_damage(Vector3.ZERO,0.5,null)
	check(received_source == null,"ordinary null source still supported")
	live.free()
	check(receiver.attacker == null,"public attacker getter does not expose a freed prior source")
	receiver.take_damage(Vector3.ZERO,0.5)
	check(receiver.attacker == null,"freed prior attribution cannot be restored")
	# A hit listener can free a source before later listeners read the same context.
	var transient := Node3D.new()
	add_child(transient)
	var killer := func(_d: Vector3,_v: float) -> void:
		if is_instance_valid(transient): transient.free()
	var later := func(_d: Vector3,_v: float) -> void:
		check(receiver.attacker == null,"later listener sees null after previous listener frees attacker")
	receiver.hurt.connect(killer)
	receiver.hurt.connect(later)
	receiver.take_damage(Vector3.ZERO,0.5,transient)
	receiver.hurt.disconnect(killer)
	receiver.hurt.disconnect(later)
	# Reentrant hits preserve the outer context and the original pre-hit context.
	var prior := Node3D.new()
	var outer := Node3D.new()
	var inner := Node3D.new()
	add_child(prior)
	add_child(outer)
	add_child(inner)
	receiver.attacker = prior
	var depth := [0]
	var nested := func(_d: Vector3,_v: float) -> void:
		if depth[0] == 0:
			check(receiver.attacker == outer,"outer signal retains its source before nested hit")
			depth[0] = 1
			receiver.take_damage(Vector3.ZERO,0.25,inner)
			check(receiver.attacker == outer,"nested hit restores outer attribution")
			depth[0] = 0
		else: check(receiver.attacker == inner,"nested signal uses its own source")
	receiver.hurt.connect(nested)
	receiver.take_damage(Vector3.ZERO,0.5,outer)
	receiver.hurt.disconnect(nested)
	check(receiver.attacker == prior,"outer hit restores original prior attribution")
	# Original context can also expire during signal delivery.
	var expire_prior := func(_d: Vector3,_v: float) -> void:
		if is_instance_valid(prior): prior.free()
	receiver.hurt.connect(expire_prior)
	receiver.take_damage(Vector3.ZERO,0.5,outer)
	receiver.hurt.disconnect(expire_prior)
	check(receiver.attacker == null,"prior source freed during callback is not restored")
	var hitbox := HitArea3D.new()
	hitbox.damage = 0.5
	var expired_owner := Node3D.new()
	add_child(expired_owner)
	hitbox.attacker = expired_owner
	add_child(hitbox)
	expired_owner.free()
	before = events
	hitbox.hit(receiver)
	check(events == before+1 and received_source == null,"actual HitArea caller tolerates freed attacker without fallback owner")
	var disposable := make_receiver()
	disposable.hurt.connect(func(_d: Vector3,_v: float) -> void: disposable.queue_free())
	disposable.take_damage(Vector3.ZERO,0.5,outer)
	await frames(2)
	check(not is_instance_valid(disposable),"receiver queued by hurt callback is safely released after delivery")
	print("DAMAGE_SOURCE_RESULT ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
