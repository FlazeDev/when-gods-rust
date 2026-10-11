extends state
var rDir: Vector3
var mDir: Vector3

@onready var wTimer = $"../../wTimer"
@export var body:CharacterBody3D
@onready var movementC: MovementComponent = $"../../MovementComponent"
@onready var nav: NavigationAgent3D = $"../../NavigationAgent3D"
var player:CharacterBody3D
var wait = false

func enter():
	randomDir()
	nav.set_navigation_map(body.get_world_3d().navigation_map)
	player = get_tree().get_first_node_in_group("Player")

func update(delta:float):
	if !is_inside_tree():
		return
	if player == null or not is_instance_valid(player):
		# Player is dead/gone: just stand still. (Re-entering "wander" here would
		# restart this state every frame and stack 3s timer coroutines forever.)
		return
	if body.global_position.distance_to(player.global_position) <= 7:
		sm.change_state("Attack")
		return
	if wait:
		return
	if nav.is_navigation_finished():
		randomDir()

	var nextPathPosition: Vector3 = nav.get_next_path_position()
	mDir = (nextPathPosition - body.global_position).normalized()

	movementC.physics_update(delta, mDir, body)
	body.move_and_slide()

func randomDir() -> void:
	wait = true
	body.velocity = Vector3.ZERO
	await get_tree().create_timer(3.0).timeout
	wait = false
	rDir = Vector3(randf_range(-5, 5), 0, randf_range(-5, 5))
	# Shift the target location relative to where the enemy currently stands
	nav.target_position = body.global_position + rDir
	wTimer.start()
