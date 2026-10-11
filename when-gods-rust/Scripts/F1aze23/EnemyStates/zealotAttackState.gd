extends state

var player:CharacterBody3D
@onready var nav: NavigationAgent3D = $"../../NavigationAgent3D"
@export var body:CharacterBody3D
@onready var movementC: MovementComponent = $"../../MovementComponent"
@onready var aTimer: Timer = $"../../aTimer"
var dir:Vector3
var canAttack := true

func enter():
	player = get_tree().get_first_node_in_group("Player")
	nav.reparent(body)
	
func update(delta):
	if !body.is_inside_tree():
		return
	if player == null or not is_instance_valid(player):
		sm.change_state("wander")
		return
	if nav.distance_to_target() < 1.5:
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
	player.get_node("HealthComponent").take_damage(20)
	canAttack = false
	aTimer.start(1)
	await aTimer.timeout
	canAttack = true
	
