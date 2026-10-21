extends Node

func _on_button_button_down() -> void:
	print("changing scene")
	get_tree().change_scene_to_packed(preload("res://scenes/randemlyy/THEtestlevel.tscn"))
	
func _on_button_2_button_down() -> void:
	get_tree().quit()
