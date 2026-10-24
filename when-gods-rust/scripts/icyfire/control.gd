extends Control

@export var fade_delay := 2.0
@export var fade_duration := 1.0

@onready var labels: Array[Label] = [$Label, $Label2]

var elapsed := 0.0

func _ready() -> void:
	for label in labels:
		label.modulate.a = 1.0

func _process(delta: float) -> void:
	elapsed += delta
	if elapsed < fade_delay:
		return

	var alpha := 1.0 - (elapsed - fade_delay) / maxf(fade_duration, 0.01)
	for label in labels:
		label.modulate.a = clampf(alpha, 0.0, 1.0)

	if alpha <= 0.0:
		queue_free()
