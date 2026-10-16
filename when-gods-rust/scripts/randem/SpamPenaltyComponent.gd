class_name SpamPenaltyComponent
extends Node

@export var recovery_delay: float = 3.0
@export var penalty_starts_at: int = 4
@export var penalty_disabled_at: int = 7

var use_count = 0
var recovery_left: float = 0.0

func record_use() -> void:
	use_count = mini(use_count + 1, penalty_disabled_at)
	recovery_left = recovery_delay

func update(action_active: bool, delta: float) -> void:
	if action_active or use_count == 0:
		return
	
	recovery_left -= delta
	
	if recovery_left <= 0.0:
		reset()

func window_scale() -> float:
	var penalty_steps = maxi(penalty_disabled_at - penalty_starts_at + 1, 1)
	var penalty_step = clampi(
		use_count - penalty_starts_at + 1,
		0,
		penalty_steps
	)
	return 1.0 - float(penalty_step) / float(penalty_steps)

func reset() -> void:
	use_count = 0
	recovery_left = 0
