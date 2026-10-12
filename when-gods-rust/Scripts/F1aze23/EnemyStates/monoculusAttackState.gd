extends state

signal RTA

@onready var attackRay: RayCast3D = $"../../LaserSpawn/AttackRay"
@onready var beam: MeshInstance3D = $"../../LaserSpawn/BeamNode/Beam"
@onready var laserSpawn: Node3D = $"../../LaserSpawn"
@onready var anim: AnimationPlayer = $"../../AnimationPlayer"
@onready var nav: NavigationAgent3D = $"../../NavigationAgent3D"
@onready var movementC: MovementComponent = $"../../MovementComponent"
@onready var wander_state: Node = $"../Wander"
@onready var beamNode: Node3D = $"../../LaserSpawn/BeamNode"

@export var body: CharacterBody3D
@export var canAttack:=true
@export var readyToAttack:bool = false
@export var windup_time := 0.4
@export var recovery_time := 0.27
@export var attack_range = 10.0
@export var aim_height = 1.0

var player: CharacterBody3D
var dir
var aimSpeed = 1.5
var hitpoint
var windup_left := -1.0




func enter() -> void:
	player = get_tree().get_first_node_in_group("Player")
	canAttack = true
	readyToAttack = false
	windup_left = -1.0
	if beam:
		beam.visible = false


func update(delta: float) -> void:
	nav.target_position = player.global_position
	
	if !canAttack:
		if windup_left >= 0.0:
			laserSpawn.look_at(
				player.global_position + Vector3.UP * aim_height,
				Vector3.UP
			)
			windup_left -= delta
			if windup_left <= 0.0:
				windup_left = -1.0
				RTA.emit()
		movementC.physics_update(delta, Vector3.ZERO, body)
		return
	
	if body.global_position.distance_to(player.global_position) <= attack_range:
		Attack()
		return
			
	#if attackRay.is_colliding() and attackRay.get_collider().is_in_group("Player"):
		#Attack()
		#hitpoint = attackRay.get_collision_point()
		#print("attacking")
		#return
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
	readyToAttack = false
	body.isAttacking = true
	windup_left = windup_time
	
	await RTA
	readyToAttack = false
	
	if not is_inside_tree() or not is_instance_valid(player):
		_finish_attack()
		return
	
	attackRay.force_raycast_update()
	
	if beam:
		beam.visible = true
	
	if attackRay.is_colliding():
		var target = attackRay.get_collider()
		if target == player:
			player.take_hit(15)
	
	await get_tree().create_timer(recovery_time).timeout
	
	if beam:
		beam.visible = false
	
	_finish_attack()
	wander_state.call("start_wander")
	sm.change_state("Wander")
	#if attackRay:
		#attackRay.force_raycast_update()
		#if attackRay.is_colliding():
			#print("hello")
			#var collider = attackRay.get_collider()
			#var current_distance = laserSpawn.global_position.distance_to(hitpoint)
			#if beam:
				#beamNode.scale.z = current_distance* 2
			#print(collider)
			#if collider.is_in_group("Player"):
				#print("player")
				#var hc = collider.get_node("HealthComponent")
				#if hc:
					#hc.take_damage(20)
		#else:
			#if beam:
				#player.get_node("ResolveComponent").gainResolve(5)
				#beamNode.scale.z = 12.0
				#print("hi")

func _finish_attack() -> void:
	if is_instance_valid(body):
		body.isAttacking = false
	canAttack = true	
	readyToAttack = true
	windup_left = -1.0
