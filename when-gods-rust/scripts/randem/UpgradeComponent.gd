class_name UpgradeComponent
extends Node

signal load_changed(current_load: float, max_load: float)

@onready var resolveC: ResolveComponent = $"../ResolveComponent"

@export var arm_gear: GearData
@export var core_gear: GearData

func _ready() -> void:
	load_changed.emit(get_current_load(), resolveC.maxResolve)
	print("Gear load: ", get_current_load(), " / ", resolveC.maxResolve)


func get_current_load() -> float:
	var total = 0.0
	
	if arm_gear != null:
		total += arm_gear.load
	
	if core_gear != null:
		total += core_gear.load
	
	return total

func equip_gear(gear: GearData) -> void:
	if gear == null:
		return
	
	match gear.slot:
		GearData.Slot.ARM:
			arm_gear = gear
		GearData.Slot.CORE:
			core_gear = gear
	load_changed.emit(get_current_load(), resolveC.maxResolve)
