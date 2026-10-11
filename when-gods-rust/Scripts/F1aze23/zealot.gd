extends CharacterBody3D

@onready var healthC: HealthComponent = $HealthComponent

func _ready() -> void:
	healthC.start()

func _process(delta: float) -> void:
	healthC.update()
