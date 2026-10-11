extends CharacterBody3D

@onready var healthC: HealthComponent = $HealthComponent
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var movementC: MovementComponent = $MovementComponent
var isAttacking:=false

func _ready() -> void:
	healthC.start()

func _process(delta: float) -> void:
	if isAttacking:
		anim.play("Attack")
	elif movementC.isWalking:
		anim.play("Walk")
	else:
		anim.play("Idle")
	healthC.update()
