class_name ItemWeapon
extends Node
@export var Weapon:PackedScene
@export var Name:String
@export var unlocked:bool
@export var iText:Label

func _process(delta: float) -> void:
	if !unlocked:
		iText.text = "Not Unlocked"
	else:
		iText.text = "E to Interact"
