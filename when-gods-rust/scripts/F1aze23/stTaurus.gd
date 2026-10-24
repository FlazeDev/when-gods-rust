extends CharacterBody3D

@onready var staggerC: StaggerComponent = $StaggerComponent
@onready var movementC: MovementComponent = $MovementComponent
@onready var healthC: HealthComponent = $HealthComponent
@onready var lootC: LootComponent = $LootComponent

func _ready() -> void:
	healthC.start()
	healthC.died.connect(death)
	
func _process(delta: float) -> void:
	healthC.update(delta)

func death():
	lootC.spawnLoot()
	queue_free()
