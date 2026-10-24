extends Node

@onready var pause_menu: CanvasLayer = $"../PauseMenu"
@onready var resume_button: Button = $"../PauseMenu/cont"
@onready var quit_button: Button = $"../PauseMenu/quit"

var mouse_mode_before_pause: Input.MouseMode = Input.MOUSE_MODE_CAPTURED

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_menu.hide()
	resume_button.pressed.connect(toggle_pause)
	quit_button.pressed.connect(_quit_game)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu") and not event.is_echo():
		toggle_pause()

func toggle_pause() -> void:
	var pausing = not get_tree().paused

	if pausing:
		mouse_mode_before_pause = Input.mouse_mode
	
	get_tree().paused = pausing
	pause_menu.visible = pausing

	if pausing:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = mouse_mode_before_pause

func _quit_game() -> void:
	get_tree().paused = false
	get_tree().quit()
