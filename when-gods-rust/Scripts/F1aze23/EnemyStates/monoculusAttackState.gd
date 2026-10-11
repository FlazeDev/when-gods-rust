extends state

@onready var nav: NavigationAgent3D = $"../../NavigationAgent3D"
var player: CharacterBody3D
@export var body: CharacterBody3D
@onready var movementC: MovementComponent = $"../../MovementComponent"
@export var canAttack:=true
@onready var attackRay: RayCast3D = $"../../LaserSpawn/AttackRay"
@onready var beam: MeshInstance3D = $"../../LaserSpawn/BeamNode/Beam"
@onready var laserSpawn: Node3D = $"../../LaserSpawn"
@onready var anim: AnimationPlayer = $"../../AnimationPlayer"
var dir
@export var readyToAttack:bool = false
signal RTA
@onready var beamNode: Node3D = $"../../LaserSpawn/BeamNode"
var aimSpeed = 1.5
var hitpoint

func enter() -> void:
	player = get_tree().get_first_node_in_group("Player")
	if beam:
		beam.visible = false
	canAttack = true

func update(delta: float) -> void:
	nav.target_position = player.global_position
	if !canAttack:
		if readyToAttack:
			RTA.emit()
		movementC.physics_update(delta, Vector3.ZERO, body)
		return
	if attackRay.is_colliding() and attackRay.get_collider().is_in_group("Player"):
		Attack()
		hitpoint = attackRay.get_collision_point()
		print("attacking")
		return
	elif nav.distance_to_target() > 10.0:
		sm.change_state("Wander")
		return
	dir = (nav.get_next_path_position() - body.global_position).normalized()
	movementC.physics_update(delta, dir, body)
	body.move_and_slide()


func Attack() -> void:
	if !canAttack:
		return
	print("attack")
	canAttack = false
	body.isAttacking = true
	await RTA
	readyToAttack = false
	if attackRay:
		attackRay.force_raycast_update()
		if attackRay.is_colliding():
			print("hello")
			var collider = attackRay.get_collider()
			var current_distance = laserSpawn.global_position.distance_to(hitpoint)
			if beam:
				beamNode.scale.z = current_distance* 2
			print(collider)
			if collider.is_in_group("Player"):
				print("player")
				var hc = collider.get_node("HealthComponent")
				if hc:
					hc.take_damage(20)
		else:
			if beam:
				player.get_node("ResolveComponent").gainResolve(5)
				beamNode.scale.z = 12.0
				print("hi")
