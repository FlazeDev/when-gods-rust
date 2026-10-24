extends Node

const TEST_LEVEL := preload("res://Scenes/randemlyy/THEtestlevel.tscn")

func _on_button_button_down() -> void:
	get_tree().change_scene_to_packed(TEST_LEVEL)
	
func _on_button_2_button_down() -> void:
	get_tree().quit()
