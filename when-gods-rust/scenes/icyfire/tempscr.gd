extends Area3D

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_packed(preload("uid://o73v2cty65b6"))
