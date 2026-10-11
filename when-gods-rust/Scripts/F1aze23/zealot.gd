extends CharacterBody3D

@onready var healthC: HealthComponent = $HealthComponent
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var movementC: MovementComponent = $MovementComponent
@export var isAttacking:=false

func _ready() -> void:
	healthC.start()
	healthC.died.connect(queue_free)

func _process(delta: float) -> void:
	if isAttacking:
		anim.play("Attack")
	elif movementC.isWalking:
		anim.play("Walk")
	else:
		anim.play("Idle")
	healthC.update()
