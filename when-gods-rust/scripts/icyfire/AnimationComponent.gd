class_name AnimationComponent
extends Node

@onready var animation_player: AnimationPlayer = $"../Model2/WGR3/AnimationPlayer"

func process(IsMoving:bool, IsStaggered:bool) -> void:
	if !IsStaggered:
		if IsMoving:
			print("moveanim")
			animation_player.play("Walk2")
		elif !IsMoving:
			print("walkanim")
			animation_player.play("Idle")
	else:
		animation_player.stop()
		animation_player.play("Staggered")
		print("staggeredanim")
