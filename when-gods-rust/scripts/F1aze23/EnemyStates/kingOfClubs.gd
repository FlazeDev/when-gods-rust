extends state

@export var body:CharacterBody3D
var player
@export var nav:NavigationAgent3D
@export var movementC:MovementComponent
@export var shockwave:Area3D
var wait = false
var isAttacking = false
func enter():
	player = get_tree().get_first_node_in_group("Player")
	
func update(delta:float):
	if nav.distance_to_target() < 5:
		wait = true
		isAttacking = true
		shockwave.global_position.y = body.global_position.y
		await get_tree().create_timer(1).timeout
		shockwave.global_position.y = 25
		wait = false
		isAttacking = false
	else:
		wait = false
		shockwave.global_position.y = 25
	nav.target_position = player.global_position
	var moveDir = (nav.get_next_path_position() - body.global_position).normalized()
	movementC.physics_update(delta, moveDir, body)
	if wait:
		return
	body.move_and_slide()
	


func _on_shockwave_body_entered(body: Node3D) -> void:
	if body.is_in_group("Player") and isAttacking:
		body.take_hit(10)
