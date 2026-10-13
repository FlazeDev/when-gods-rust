extends Node

func _on_button_button_down() -> void:
	print("changing scene")
	get_tree().change_scene_to_packed(preload("uid://bj4s2hn8pbd5d"))
	
func _on_button_2_button_down() -> void:
	get_tree().quit()
