class_name AnimationComponent
extends Node

@onready var animation_player: AnimationPlayer = $"../Node3D/WGR3/AnimationPlayer"

func process(IsMoving:bool, IsStaggered:bool) -> void:
	if !IsStaggered:
		if IsMoving:
			animation_player.play("Walk2")
		elif !IsMoving:
			animation_player.play("Idle")
	else:
		animation_player.stop()
		animation_player.play("Staggered")
