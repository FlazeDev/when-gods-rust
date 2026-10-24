extends state

@export var patrolPoints:Array = []
var player:CharacterBody3D
@export var nav: NavigationAgent3D 
var cPoint
@export var body:CharacterBody3D
@export var movementC: MovementComponent
var CPIndex:int = 0
var wait
@export var vArea:Area3D

func enter():
	player = get_tree().get_first_node_in_group("Player")
	patrolPoints = get_tree().get_first_node_in_group("PatrolPoint").get_children()
	cPoint = patrolPoints[0]
	nav.target_position = cPoint.global_position
	
func update(delta:float):
	var moveDir = (nav.get_next_path_position() - body.global_position).normalized()
	movementC.physics_update(delta, moveDir, body)
	if wait:
		return
	body.move_and_slide()
	
func updatePatrol():
	if patrolPoints.size() == 0:
		return
	wait = true
	await get_tree().create_timer(2).timeout
	wait = false
	CPIndex = (CPIndex + 1) % patrolPoints.size()
	cPoint = patrolPoints[CPIndex]
	nav.target_position = cPoint.global_position
	
func onVisionEntered(node:Node):
	if node.is_in_group("Player"):
		sm.change_state("Attack")
	

	
