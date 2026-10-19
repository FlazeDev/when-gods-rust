extends Node

@onready var canvas_layer: CanvasLayer = $"../CanvasLayer"
@onready var cont: Button = $"../CanvasLayer/cont"
@onready var quit: Button = $"../CanvasLayer/quit"

func _ready() -> void:
	canvas_layer.hide()
	cont.pressed.connect(_on_resume_pressed)
	quit.pressed.connect(_on_quit_pressed)
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("menu"):
		toggle_pause()

func toggle_pause() -> void:
#	print("Pause toggled")
	var new_pause_state = !get_tree().paused
	get_tree().paused = new_pause_state
	
	if new_pause_state:
		canvas_layer.show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		canvas_layer.hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		


func _on_resume_pressed() -> void:
#	print("resume pressed")
	toggle_pause()
	
func _on_quit_pressed() -> void:
	print ("quit pressed")
	get_tree().paused = false
	get_tree().quit()
	pass
