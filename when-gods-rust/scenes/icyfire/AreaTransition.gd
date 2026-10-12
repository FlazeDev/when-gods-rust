extends Area3D

@export var PlayerSpawnPosition: Node3D
@export var CameraSpawnPosRot: Node3D
@export var CamOffset: Vector3
@export var CamRotation: Vector3 = Vector3(0.8, 0, 0)
@export var InvertControls:bool = false

@onready var player: CharacterBody3D = self.get_tree().get_first_node_in_group("Player")

func _ready() -> void:
	#off sets the camera
	CamOffset = CameraSpawnPosRot.global_position - PlayerSpawnPosition.global_position
func _on_body_entered(body: Node3D) -> void:
	if body == player:
		player.global_position = PlayerSpawnPosition.global_position
		player.get_node("CameraComponent").offset = CamOffset
		print (player.get_node("CameraComponent").offset)
		player.get_node("CameraComponent").rotation = CamRotation
		print (player.get_node("CameraComponent").rotation)
		if InvertControls:
			player.invertControls = -1
			print ("player controls inverted")
		else:
			player.invertControls = 1
			print ("player controls normal")
