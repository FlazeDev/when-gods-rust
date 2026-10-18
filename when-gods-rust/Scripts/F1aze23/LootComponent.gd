class_name  LootComponent
extends Node

@export var lootTable:Dictionary
@export var body:CharacterBody3D

func spawnLoot():
	var roll = randf_range(0.0,100.0)
	var totalWeight = 0.0
	for i in lootTable:
		totalWeight+=lootTable[i]
		if roll <= totalWeight:
			var inst = i.instantiate()
			get_tree().root.add_child(inst)
			inst.global_position = body.global_position
			print("Successfully spawned: ", inst.name)
			break
		
