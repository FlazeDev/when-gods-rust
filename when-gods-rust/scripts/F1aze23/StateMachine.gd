class_name StateMachine
extends Node

@export var iState:state
@export var staggerC:StaggerComponent
var cState:state
var states:Dictionary = {}

func _ready() -> void:
	for child in get_children():
		if child is state:
			states[child.name.to_lower()] = child
			child.sm = self
			
	if !staggerC:
		print("--- STATE MACHINE WARNING ---")
		print("Owner Enemy Name: ", get_parent().name)
		print("Checking for sibling node... ")
		if get_parent().has_node("StaggerComponent"):
			print("Found sibling node, but the @export slot is empty! Please assign it in the Inspector.")
		else:
			print("CRITICAL: The sibling node 'StaggerComponent' does not even exist under this enemy!")
		print("-----------------------------")

	if iState:
		change_state(iState.name.to_lower())

func _process(delta: float) -> void:
	if !staggerC:
		return
	if cState and not staggerC.is_staggered:
		cState.update(delta)
	
func _physics_process(delta: float) -> void:
	if !staggerC:
		return
	if cState and not staggerC.is_staggered:
		cState.physics_update(delta)
func change_state(newStateName:String):
	if cState:
		cState.exit()
		
	cState = states.get(newStateName.to_lower())
	
	if cState:
		cState.enter()
