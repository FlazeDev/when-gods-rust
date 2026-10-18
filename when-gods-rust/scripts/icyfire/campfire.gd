extends Node3D
@export var camPos: Node3D
@export var playerPos: Node3D


func Rest(player:Node3D) -> void:
	player.global_position = playerPos.global_position
	player.get_node("InventoryComponent").Heals = 4
	pass
