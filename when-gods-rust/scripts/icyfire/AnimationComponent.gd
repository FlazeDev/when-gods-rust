class_name AnimationComponent
extends Node

@onready var animation_player: AnimationPlayer = $"../Node3D/WGR1/AnimationPlayer"

func process(delta:float, IsMoving:bool) -> void:
	if IsMoving:
		animation_player.play("Walk")
	else:
		animation_player.play("Idle")
	pass
