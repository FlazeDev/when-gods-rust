class_name DodgeComponent
extends Node

@export var body:CharacterBody3D
@export var step_speed: float = 8.0
@export var step_duration: float = 0.14
@export var dodge_window_duration: float = 0.18
@export var recovery_duration: float = 0.2
@export var graze_grace_period: float = 0.1

var is_dashing: bool = false
var is_dodging: bool = false
var step_direction: Vector3 = Vector3.ZERO
var step_time_left: float = 0.0
var dodge_time_left: float = 0.0
var recovery_left: float = 0.0
var graze_time_left: float = 0.0


func start_dash(direction: Vector3) -> bool:
	if is_dashing or recovery_left > 0.0:
		return false
	
	direction.y = 0.0
	if direction.length_squared() < 0.001:
		return false
	
	step_direction = direction.normalized()
	step_time_left = step_duration
	dodge_time_left = dodge_window_duration
	graze_time_left = graze_grace_period + dodge_window_duration
	is_dashing = true
	is_dodging = true
	_set_step_velocity()

	return true

func physics_update(delta: float) -> void:
	recovery_left = maxf(recovery_left - delta, 0.0)
	graze_time_left = maxf(graze_time_left - delta, 0.0)
	if is_dodging:
		dodge_time_left -= delta
		if dodge_time_left <= 0.0:
			is_dodging = false

	if not is_dashing:
		return

	step_time_left -= delta
	if step_time_left <= 0.0:
		is_dashing = false
		recovery_left = recovery_duration
		body.velocity.x = 0.0
		body.velocity.z = 0.0
		return

	_set_step_velocity()

func cancel_dash() -> void:
	is_dashing = false
	is_dodging = false
	step_time_left = 0.0
	dodge_time_left = 0.0
	graze_time_left = 0.0

func _set_step_velocity() -> void:
	body.velocity.x = step_direction.x * step_speed
	body.velocity.z = step_direction.z * step_speed

func can_graze_attack() -> bool:
	return graze_time_left > 0.0
