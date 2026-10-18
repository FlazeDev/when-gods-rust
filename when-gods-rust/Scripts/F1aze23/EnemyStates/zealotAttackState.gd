extends state

@onready var nav: NavigationAgent3D = $"../../NavigationAgent3D"
@onready var movementC: MovementComponent = $"../../MovementComponent"
@onready var aTimer: Timer = $"../../aTimer"
@onready var anim: AnimationPlayer = $"../../AnimationPlayer"
@onready var attackDist: RayCast3D = $"../../AttackDist"

@export var canAttack := true
@export var body:CharacterBody3D

var player:CharacterBody3D
var hit:Node
var dir:Vector3


func enter():
	player = get_tree().get_first_node_in_group("Player")
	nav.reparent(body)
	
func update(delta):
	if !body.is_inside_tree():
		return
	if player == null or not is_instance_valid(player):
		sm.change_state("wander")
		return
	if attackDist.is_colliding() and canAttack == true:
		Attack()
		return
	elif nav.distance_to_target() > 7:
		sm.change_state("wander")
		return
	nav.target_position = player.global_position
	
	dir = (nav.get_next_path_position() - body.global_position).normalized()
	movementC.physics_update(delta, dir, body)
	body.move_and_slide()
	
func Attack():
	if !canAttack:
		return
	body.isAttacking = true
	hit = null

func onAttackHit(node: Node3D) -> void:
	if canAttack or player == null or hit == player:
		return
	if not node.is_in_group("Player"):
		return
	
	hit = player
	var direction = (player.global_position - body.global_position).normalized()
	player.take_hit(10, 0.6, direction, body, node)
