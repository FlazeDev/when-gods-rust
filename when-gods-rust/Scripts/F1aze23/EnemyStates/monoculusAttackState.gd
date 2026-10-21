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
@onready var chargeIndicator: MeshInstance3D = $"../../LaserSpawn/ChargeIndicator"

@export var body: CharacterBody3D
@export var canAttack:=true
@export var readyToAttack:bool = false
@export var windup_time := 0.4
@export var recovery_time := 0.27
@export var attack_range = 10.0
@export var aim_height = 1.0
@export var aim_lock_time = 0.5

var lock_left = -1.0
var player: CharacterBody3D
var dir
var aimSpeed = 1.5
var hitpoint
var windup_left := -1.0
var attack_serial := 0
var attack_id := ""

func enter() -> void:
	player = get_tree().get_first_node_in_group("Player")
	canAttack = true
	readyToAttack = false
	windup_left = -1.0
	lock_left = -1.0
	chargeIndicator.visible = false
	if beam:
		beam.visible = false


func update(delta: float) -> void:
	nav.target_position = player.global_position
	
	if !canAttack:
		if windup_left >= 0.0:
			_turn_body_towards_player(delta)
			laserSpawn.look_at(
				player.global_position + Vector3.UP * aim_height,
				Vector3.UP
			)
			windup_left -= delta
			if windup_left <= 0.0:
				windup_left = -1.0
				lock_left = aim_lock_time
		
		elif lock_left >= 0.0:
			lock_left -= delta
			if lock_left <= 0.0:
				lock_left = 1.0
				RTA.emit()
		
		movementC.physics_update(delta, Vector3.ZERO, body)
		return
	
	if body.global_position.distance_to(player.global_position) <= attack_range:
		Attack()
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
	attack_serial += 1
	attack_id = "%s:%d" % [get_instance_id(), attack_serial]
	canAttack = false
	readyToAttack = false
	body.isAttacking = true
	windup_left = windup_time
	lock_left = -1.0
	chargeIndicator.visible = true
	await RTA
	chargeIndicator.visible = false
	readyToAttack = false
	
	if not is_inside_tree() or not is_instance_valid(player):
		_finish_attack()
		return
	
	attackRay.force_raycast_update()
	
	if beam:
		beam.visible = true
	
	if attackRay.is_colliding():
		var target = attackRay.get_collider()
		print("Laser hit: ", target.name)
		if target == player:
			var direction = (player.global_position - body.global_position).normalized()
			if not player.try_dodge_graze(attack_id):
				player.take_hit(10, 0.5, direction, body)
		elif target is Area3D and target.is_in_group("DodgeArea") and target.get_parent() == player:
			player.try_dodge_graze(attack_id)
	
	await get_tree().create_timer(recovery_time).timeout
	
	if beam:
		beam.visible = false
	
	_finish_attack()
	wander_state.call("start_wander")
	sm.change_state("Wander")

func _turn_body_towards_player(delta: float) -> void:
	var direction = player.global_position - body.global_position
	direction.y = 0.0
	
	if direction.length_squared() < 0.001:
		return
	
	var target_yaw = atan2(-direction.x, -direction.z)
	body.rotation.y = rotate_toward(body.rotation.y, target_yaw, 8.0 * delta)
	

func _finish_attack() -> void:
	if is_instance_valid(player) and not attack_id.is_empty():
		player.finish_dodge_graze_attack(attack_id)
	attack_id = ""
	if is_instance_valid(body):
		body.isAttacking = false
	canAttack = true	
	readyToAttack = true
	windup_left = -1.0
	lock_left = -1.0
