extends Area3D



@export var PlayerSpawnPosition: Node3D
@export var CameraSpawnPosRot: Node3D
@export var CamOffset: Vector3
@export var CamRotation: Vector3 = Vector3(0.8, 0, 0)
@export var InvertControlsX:bool = false
@export var InvertControlsY:bool = false
@export var SwitchControlAxes:bool = false
@onready var player: CharacterBody3D = self.get_tree().get_first_node_in_group("Player")
func _on_body_entered(body: Node3D) -> void:
	
	if body == player:
		CamOffset = CameraSpawnPosRot.global_position - PlayerSpawnPosition.global_position
		player.global_position = PlayerSpawnPosition.global_position
		player.get_node("CameraComponent").offset = CamOffset
		print (player.get_node("CameraComponent").offset)
		player.get_node("CameraComponent").rotation = CamRotation
		print (player.get_node("CameraComponent").rotation)
		
		
		
		if InvertControlsX:
			player.invertControlsX = -1
		else:
			player.invertControlsX = 1
		if InvertControlsY:
			player.invertControlsY = -1
		else:
			player.invertControlsY = 1
		
		if SwitchControlAxes:
			player.SwitchControlAxes = true
		else:
			player.SwitchControlAxes = false
