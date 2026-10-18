class_name UpgradeComponent
extends Node

signal load_changed(current_load: float, max_load: float)
signal loadout_changed

@onready var resolveC: ResolveComponent = $"../ResolveComponent"

@export var arm_part: BodyPartData
@export var core_part: BodyPartData
@export var owned_gears: Array[GearData] = []

var arm_sockets: Array[GearData] = []
var core_sockets: Array[GearData] = []
var attack_damage_bonus: float = 0.0
var block_resolve_cost_reduction: float = 0.0

func _ready() -> void:
	if arm_part != null:
		arm_sockets.resize(maxi(arm_part.socket_count, 0))
		
	if core_part != null:
		core_sockets.resize(maxi(core_part.socket_count, 0))
		
	_notify_loadout_changed()

func get_current_load() -> float:
	var total = 0.0
	
	for gear in arm_sockets:
		if gear != null:
			total += gear.load
	for gear in core_sockets:
		if gear != null:
			total += gear.load
	return total

func install_gear(gear: GearData, socket_index: int) -> bool:
	if gear == null or not owned_gears.has(gear):
		return false
	
	var installed = false
	
	match gear.slot:
			GearData.Slot.ARM:
				installed = _install_into(arm_sockets, gear, socket_index)
			GearData.Slot.CORE:
				installed = _install_into(core_sockets, gear, socket_index)
	
	if not installed:
		return false
	
	owned_gears.erase(gear)
	_notify_loadout_changed()
	return true

func remove_gear(slot: GearData.Slot, socket_index: int) -> bool:
	var gear: GearData
	
	match slot:
		
		GearData.Slot.ARM:
			if socket_index < 0 or socket_index >= arm_sockets.size():
				return false
			gear = arm_sockets[socket_index]
			if gear == null:
				return false
			arm_sockets[socket_index] = null
			
		GearData.Slot.CORE:
			if socket_index < 0 or socket_index >= core_sockets.size():
				return false
			gear = core_sockets[socket_index]
			if gear == null:
				return false
			core_sockets[socket_index] = null
			
	owned_gears.append(gear)
	_notify_loadout_changed()
	return true
	
func _notify_loadout_changed() -> void:
	_recalculate_final_stats()
	load_changed.emit(get_current_load(), resolveC.maxResolve)
	loadout_changed.emit()

func _recalculate_final_stats() -> void:
	attack_damage_bonus = 0.0
	block_resolve_cost_reduction = 0.0
	_add_gear_stats(arm_sockets)
	_add_gear_stats(core_sockets)
	
func _add_gear_stats(sockets: Array[GearData]) -> void:
	for gear in sockets:
		if gear == null:
			continue
		
		attack_damage_bonus += gear.attack_damage_bonus
		block_resolve_cost_reduction += gear.block_resolve_cost_reduction

func _install_into(sockets: Array[GearData], gear: GearData, socket_index: int) -> bool:
	if socket_index < 0 or socket_index >= sockets.size():
		return false
	if sockets[socket_index] != null:
		return false
		
	sockets[socket_index] = gear
	return true
	
func pickupGear(gear:GearData):
	if gear.slot == gear.Slot.ARM:
		for i in range(arm_sockets.size()):
			if arm_sockets[i] == null:
				_install_into(arm_sockets, gear, i)
				print("installed arm scoket succesfully")
	elif gear.slot == gear.Slot.CORE:
		for i in range(core_sockets.size()):
			if core_sockets[i] == null:
				_install_into(core_sockets, gear, i)
				print("Installed core socket sucessfully")
