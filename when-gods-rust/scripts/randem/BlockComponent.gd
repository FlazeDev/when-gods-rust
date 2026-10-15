class_name BlockComponent
extends Node

signal blocking_started
signal blocking_ended

@onready var resolveC: ResolveComponent = $"../ResolveComponent"

@export var block_resolve_cost: float = 10.0
@export var early_parry_window: float = 0.15
@export var late_parry_window: float = 0.04
@export var resolve_on_parry: float = 40.0
@export var spam_recovery_delay: float = 3.0
@export var parry_disabled_at: int = 7
@export var penalty_starts_at: int = 4


var consecutive_block_presses: int = 0
var spam_recovery_left: float = 0.0
var last_block_press_time: float = -1.0e20
var is_blocking: bool = false

func update(block_held: bool, block_pressed: bool, delta: float) -> void:
	if block_pressed:
		last_block_press_time = float(Time.get_ticks_usec()) / 1_000_000.0
		consecutive_block_presses = mini(
			consecutive_block_presses + 1,
			parry_disabled_at
		)
		spam_recovery_left = spam_recovery_delay
		
	elif not block_held and consecutive_block_presses > 0:
		spam_recovery_left -= delta
		
		if spam_recovery_left <= 0:
			consecutive_block_presses = 0
			last_block_press_time = -1.0e20
	
	if not block_held or resolveC.cResolve <= 0.0:
		_set_blocking(false)
		return
	
	_set_blocking(true)

func _get_parry_window() -> float:
	var penalty_steps = maxi(parry_disabled_at - penalty_starts_at + 1, 1)
	var penalty_step = clampi(
		consecutive_block_presses - penalty_starts_at + 1,
		0,
		penalty_steps
	)
	return 1.0 - float(penalty_step) / float(penalty_steps)
	
func spend_for_block() -> bool:
	if resolveC.cResolve < block_resolve_cost:
		_set_blocking(false)
		return false
	
	resolveC.useResolve(block_resolve_cost)
	
	if resolveC.cResolve <= 0.0:
		_set_blocking(false)
	
	return true 

func _set_blocking(value: bool) -> void:
	if is_blocking == value:
		return
	
	is_blocking = value
	
	if is_blocking:
		blocking_started.emit()
	else:
		blocking_ended.emit()	

func check_parry_press(impact_time: float) -> bool:
	var window_scale = _get_parry_window()
	
	if window_scale <= 0.0:
		return false

	var parry_offset = last_block_press_time - impact_time
	if parry_offset < -early_parry_window * window_scale:
		return false
	if parry_offset > late_parry_window * window_scale:
		return false
	
	last_block_press_time = -1.0e20
	consecutive_block_presses = 0
	spam_recovery_left = 0 
	return true
