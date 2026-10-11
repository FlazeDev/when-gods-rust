extends state

var player:CharacterBody3D
@onready var nav: NavigationAgent3D = $"../../NavigationAgent3D"
@export var body:CharacterBody3D
@onready var movementC: MovementComponent = $"../../MovementComponent"
@onready var aTimer: Timer = $"../../aTimer"
@onready var anim: AnimationPlayer = $"../../AnimationPlayer"
@onready var attackDist: RayCast3D = $"../../AttackDist"
var dir:Vector3
@export var canAttack := true
var hit:Node

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
	if canAttack or hit == node:
		return
	if node.is_in_group("Player"):
		hit = node
		if node.has_node("HealthComponent"):
			node.get_node("HealthComponent").take_damage(5)
		elif node.get_parent().has_node("ResolveComponent"):
			var health = node.get_parent().get_node("HealthComponent")
			var cHealth = health.current_health
			await anim.animation_finished
			if cHealth != health.current_health:
				return
			hit.get_parent().get_node("ResolveComponent").gainResolve(5)
