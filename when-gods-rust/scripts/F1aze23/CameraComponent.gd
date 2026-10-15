class_name CameraComponent
extends Node

@export var offset:Vector3 = Vector3(7.72, 9.25, 9.81)
@export var rotation:Vector3 = Vector3(-0.8, 0, 0)

var shake_timer = 0.0
var shake_duration = 0.0
var shake_strength = 0.0

var cam:Camera3D

func start():
	cam = Camera3D.new()
	get_tree().root.add_child.call_deferred(cam)
	cam.projection = Camera3D.PROJECTION_PERSPECTIVE
	cam.size = 14
	cam.make_current() 
	

func shake(strength: float, duration: float):
	if duration <= 0.0:
		return
	
	shake_strength = maxf(shake_strength, strength)
	shake_duration = maxf(shake_duration, duration)
	shake_timer = maxf(shake_timer, duration)
	

func update(body:CharacterBody3D, delta:float):
	if not is_instance_valid(cam):
		return
		
	cam.global_position = body.global_position + offset
	cam.look_at(body.global_position)
	cam.rotation = rotation
	
	if shake_timer <= 0.0:
		return
	
	var fade = shake_timer/shake_duration
	var shake_offset = (
		cam.global_basis.x * randf_range(-1.0, 1.0) +
		cam.global_basis.y * randf_range(-1.0, 1.0)
	) * shake_strength * fade
	
	cam.global_position += shake_offset
	shake_timer = maxf(shake_timer - delta, 0.0)
