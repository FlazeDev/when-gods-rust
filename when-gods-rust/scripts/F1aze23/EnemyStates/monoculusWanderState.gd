extends state

@export var body: CharacterBody3D
@export var attack_dist = 10.0
@export var retreat_dist = 4.0
@export var wander_radius = 6.0
@export var wander_time = 3.0
@export var walk_burst_min := 1.0
@export var walk_burst_max := 2.0
@export var pause_min := 1.5
@export var pause_max := 3.0


@onready var movementC: MovementComponent = $"../../MovementComponent"
@onready var nav: NavigationAgent3D = $"../../NavigationAgent3D"

var player: CharacterBody3D
var cooldown_left = 0.0
var wander_center: Vector3
var has_wander_center := false
var is_walking_burst := false
var phase_time_left := 0.0


func enter() -> void:
	player = get_tree().get_first_node_in_group("Player")
	if not has_wander_center:
		wander_center = body.global_position
		has_wander_center = true
	nav.set_navigation_map(body.get_world_3d().navigation_map)
	is_walking_burst = false
	phase_time_left = randf_range(pause_min, pause_max)
	_pick_wander_destination()

func update(delta:float) -> void:
	if not is_instance_valid(player):
		return
	
	var distance = body.global_position.distance_to(player.global_position)
	
	if cooldown_left > 0.0:
		cooldown_left = maxf(cooldown_left - delta, 0.0)
		
		if distance < retreat_dist:
			var away = body.global_position - player.global_position
			away.y = 0.0
			
			if away.length_squared() < 0.001:
				away = Vector3.FORWARD
			
			movementC.physics_update(delta, away.normalized(), body)
			body.move_and_slide()
			return
	
	if cooldown_left <= 0.0 and distance <= attack_dist:
		sm.change_state("Attack")
		return
	
	if not is_walking_burst:
		phase_time_left -= delta
		movementC.physics_update(delta, Vector3.ZERO, body)
		body.move_and_slide()
		
		if phase_time_left <= 0.0:
			_start_wander_burst()
		return
	phase_time_left -= delta
	if phase_time_left <= 0.0 or nav.is_navigation_finished():
		is_walking_burst = false
		phase_time_left = randf_range(pause_min, pause_max)
		movementC.physics_update(delta, Vector3.ZERO, body)
		body.move_and_slide()
		return
		
	if nav.is_navigation_finished():
		_pick_wander_destination()
	
	var direction = (nav.get_next_path_position() - body.global_position).normalized()
	movementC.physics_update(delta, direction, body)
	body.move_and_slide()

func start_wander() -> void:
	cooldown_left = wander_time
	_pick_wander_destination()

func _start_wander_burst() -> void:
	_pick_wander_destination()
	is_walking_burst = true
	phase_time_left = randf_range(walk_burst_min, walk_burst_max)

func _pick_wander_destination() -> void:
	var angle := randf_range(0.0, TAU)
	var radius := randf_range(0.0, wander_radius)
	var offset := Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)

	nav.target_position = wander_center + offset
