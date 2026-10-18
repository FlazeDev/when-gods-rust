class_name DodgeComponent
extends Node

@export var dArea:Area3D
@export var body:CharacterBody3D
var isDodging

func dodge():
	body.velocity += Vector3(5,0,5)
	isDodging =  true
	await get_tree().create_timer(1).timeout
	isDodging = false
