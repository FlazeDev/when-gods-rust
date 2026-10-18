class_name DodgeComponent
extends Node

@export var body:CharacterBody3D
var isDodging

func dodge():
	if body.velocity != Vector3.ZERO:
			body.velocity += Vector3(5,0,5)
	else:
		body.velocity = Vector3(20,0,0)
	isDodging =  true
	await get_tree().create_timer(1).timeout
	isDodging = false
