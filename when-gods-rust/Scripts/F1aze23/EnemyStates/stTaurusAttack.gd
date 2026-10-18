extends state

@export var nav:NavigationAgent3D
@export var body:CharacterBody3D
@export var player:CharacterBody3D
@export var movementC:MovementComponent
var wait
var isAttacking
var aDir
@export var dArea:Area3D
var hit:Array = []

func enter():
	player = get_tree().get_first_node_in_group("Player")
	nav.target_position = player.global_position
func update(delta:float):
	if isAttacking:
		movementC.speed = 10
		movementC.physics_update(delta,aDir, body)
		if wait:
			return
		body.move_and_slide()
		for i in dArea.get_overlapping_bodies():
			if i.is_in_group("Player"):
				if hit == []:
					i.take_hit(10)
					hit.append(i)
				else:
					for j in hit:
						if j == i:
							return
						i.take_hit(10)
		return
	if nav.distance_to_target() > 12:
		sm.change_state("Patrol")
	elif nav.distance_to_target() < 5:
		var dir = (player.global_position - body.global_position).normalized()
		attack(delta, dir)
	movementC.speed = 5
	nav.target_position = player.global_position
	var moveDir = (nav.get_next_path_position()-body.global_position).normalized()
	movementC.physics_update(delta, moveDir, body)
	if wait:
		return
	body.move_and_slide()
	
func attack(delta:float, moveDir:Vector3):
	print("Attack")
	aDir = moveDir
	if isAttacking:
		return
	isAttacking = true
	wait = true
	await get_tree().create_timer(3).timeout
	wait = false
	await get_tree().create_timer(2).timeout
	isAttacking = false
	hit.clear()

	
	
