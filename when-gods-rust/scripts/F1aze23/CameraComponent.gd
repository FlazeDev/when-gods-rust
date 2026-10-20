class_name CameraComponent
extends Node

@export var mouse_sensitivity: float = 0.003
@export var follow_height: float = 0.5
@export var min_pitch_degrees: float = -55.0
@export var max_pitch_degrees: float = 30.0
@export var follow_smoothing: float = 24.0

@onready var pivot: Node3D = $"../CameraPivot"
@onready var cam: Camera3D = $"../CameraPivot/SpringArm3D/ShakePivot/Camera3D"

var yaw: float = 0.0
var pitch: float = deg_to_rad(-15.0)

var shake_timer: float = 0.0
var shake_duration = 0.0
var shake_strength = 0.0

func start() -> void:
	var body = get_parent() as Node3D
	
	pivot.top_level = true
	yaw = body.global_rotation.y
	pivot.global_position = body.global_position + Vector3.UP * follow_height
	pivot.global_rotation = Vector3(pitch, yaw, 0.0)
	
	cam.make_current()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	
	if event is InputEventMouseMotion:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clampf(pitch, deg_to_rad(min_pitch_degrees), deg_to_rad(max_pitch_degrees))
		pivot.global_rotation = Vector3(pitch, yaw, 0.0)

func get_move_direction(input_dir: Vector2) -> Vector3:
	var forward = -pivot.global_basis.z
	forward.y = 0.0
	forward = forward.normalized()
	
	var right = pivot.global_basis.x
	right.y = 0.0
	right = right.normalized()
	
	return (right * input_dir.x - forward * input_dir.y).limit_length(1.0)

func shake(strength: float, duration: float) -> void:
	if duration <= 0.0:
		return
	
	shake_strength = maxf(shake_strength, strength)
	shake_duration = maxf(shake_duration, duration)
	shake_timer = maxf(shake_timer, duration)

func update(body: CharacterBody3D, delta: float) -> void:
	var target_position := body.global_position + Vector3.UP * follow_height
	var weight := 1.0 - exp(-follow_smoothing * delta)
	pivot.global_position = pivot.global_position.lerp(target_position, weight)
	pivot.global_rotation = Vector3(pitch, yaw, 0.0)

	
	if shake_timer <= 0.0:
		cam.position = Vector3.ZERO
		return
	
	var fade = shake_timer / shake_duration
	
	cam.position = Vector3(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0), 0.0) * shake_strength * fade
	
	shake_timer = maxf(shake_timer - delta, 0.0)
	
#class_name CameraComponent
#extends Node
#
#@export var offset:Vector3 = Vector3(7.72, 9.25, 9.81)
#@export var rotation:Vector3 = Vector3(-0.8, 0, 0)
#
#var shake_timer = 0.0
#var shake_duration = 0.0
#var shake_strength = 0.0
#
#var cam:Camera3D
#
#func start():
	#cam = Camera3D.new()
	#get_tree().root.add_child.call_deferred(cam)
	#cam.projection = Camera3D.PROJECTION_PERSPECTIVE
	#cam.size = 15
	#cam.make_current() 
	#
#
#func shake(strength: float, duration: float):
	#if duration <= 0.0:
		#return
	#
	#shake_strength = maxf(shake_strength, strength)
	#shake_duration = maxf(shake_duration, duration)
	#shake_timer = maxf(shake_timer, duration)
	#
#
#func update(body:CharacterBody3D, delta:float):
	#if not is_instance_valid(cam):
		#return
		#
	#cam.global_position = body.global_position + offset
	#cam.look_at(body.global_position)
	#cam.rotation = rotation
	#
	#if shake_timer <= 0.0:
		#return
	#
	#var fade = shake_timer/shake_duration
	#var shake_offset = (
		#cam.global_basis.x * randf_range(-1.0, 1.0) +
		#cam.global_basis.y * randf_range(-1.0, 1.0)
	#) * shake_strength * fade
	#
	#cam.global_position += shake_offset
	#shake_timer = maxf(shake_timer - delta, 0.0)
