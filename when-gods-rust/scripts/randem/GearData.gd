class_name GearData
extends Resource

enum Slot {
	ARM,
	CORE
}

@export var attack_damage_bonus: float = 0.0
@export var block_resolve_cost_reduction: float = 0.0
@export var gear_name: String
@export var slot: Slot
@export var load: float = 0.0
