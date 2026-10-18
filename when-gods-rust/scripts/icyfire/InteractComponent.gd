extends Node

@onready var interact_area: Area3D = $"../InteractArea"


func process(delta: float, IsInteractInput:bool) -> void:
	if IsInteractInput:
		for obj in interact_area.get_overlapping_bodies():
			if obj.is_in_group("Checkpoint"):
				print("campfire")
