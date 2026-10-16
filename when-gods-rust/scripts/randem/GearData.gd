class_name GearData
extends Resource

enum Slot {
	ARM,
	CORE
}

@export var gear_name: String
@export var slot: Slot
@export var load: float = 0.0
