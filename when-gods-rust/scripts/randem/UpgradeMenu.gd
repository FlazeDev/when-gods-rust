extends Control

@onready var upgrade_component: UpgradeComponent = get_node("../../UpgradeComponent")
@onready var gear_list: VBoxContainer = $CenterContainer/PanelContainer/HBoxContainer/InventoryColumn/ScrollContainer/GearList
@onready var arm_sockets: VBoxContainer = $CenterContainer/PanelContainer/HBoxContainer/ArmColumn/ArmSockets
@onready var core_sockets: VBoxContainer = $CenterContainer/PanelContainer/HBoxContainer/CoreColumn/CoreSockets

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	upgrade_component.loadout_changed.connect(_refresh_menu)
	_refresh_menu()
	
func _refresh_menu() -> void:
	_clear_children(gear_list)
	_clear_children(arm_sockets)
	_clear_children(core_sockets)
	
	for gear in upgrade_component.owned_gears:
		var button = Button.new()
		button.text = "%s  |  Load: %s" % [gear.gear_name, gear.load]
		gear_list.add_child(button)
	
	_add_socket_buttons(arm_sockets, upgrade_component.arm_sockets, "Arm")
	_add_socket_buttons(core_sockets, upgrade_component.core_sockets, "Core")

func _add_socket_buttons(container: VBoxContainer, sockets: Array[GearData], part_name: String) -> void:
	for i in range(sockets.size()):
		var button = Button.new()
		var gear : GearData = sockets[i]
		
		if gear == null:
			button.text = "%s Socket %d - Empty" % [part_name, i + 1]
		else:
			button.text = "%s Socket %d — %s" % [part_name, i + 1, gear.gear_name]
		container.add_child(button)

func _clear_children(container: Node) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()
