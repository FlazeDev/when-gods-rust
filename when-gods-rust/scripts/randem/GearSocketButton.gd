class_name GearSocketButton
extends Button

var upgradeC : UpgradeComponent
var slot_type: GearData.Slot
var socket_index: int

func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY or not data.has("gear"):
		return false
	
	var gear = data["gear"] as GearData
	if gear == null or gear.slot != slot_type:
		return false
	
	var sockets: Array[GearData]
	
	match slot_type:
		GearData.Slot.ARM:
			sockets = upgradeC.arm_sockets
		GearData.Slot.CORE:
			sockets = upgradeC.core_sockets
	
	return (
		socket_index >= 0 and socket_index < sockets.size() and sockets[socket_index] == null
	)

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var gear = data["gear"] as GearData
	upgradeC.install_gear(gear, socket_index)
