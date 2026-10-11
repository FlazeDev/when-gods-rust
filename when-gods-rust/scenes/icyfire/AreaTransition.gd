extends Area3D

@export var PlayerSpawnPosition: Node3D
@export var CameraSpawnPosRot: Node3D
@export var CamOffset: Vector3
@export var CamRotation: Vector3

@onready var player: CharacterBody3D = self.get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	CamOffset = PlayerSpawnPosition.global_position - CameraSpawnPosRot.global_position

func _on_body_entered(body: Node3D) -> void:
	if body == player:
		player.global_position = PlayerSpawnPosition.global_position
		player.get_node("CameraComponent").offset = CamOffset
		print (player.get_node("CameraComponent").offset)
		player.get_node("CameraComponent").rotation = CamRotation
		print (player.get_node("CameraComponent").rotation)
		pass
	pass # Replace with function body.
