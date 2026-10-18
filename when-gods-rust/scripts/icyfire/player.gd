extends CharacterBody3D


@onready var inputC: InputComponent = $InputComponent
@onready var movementC: MovementComponent = $MovementComponent
@onready var cameraC: CameraComponent = $CameraComponent
@onready var healthC: HealthComponent = $HealthComponent
@onready var staggerC: StaggerComponent = $StaggerComponent
@onready var resolveC: ResolveComponent = $ResolveComponent
@onready var inventoryC: InventoryComponent = $InventoryComponent
@onready var blockC: BlockComponent = $BlockComponent
@onready var animC: AnimationComponent = $AnimationComponent
@onready var upgradeMenu: UpgradeMenu = $CanvasLayer/UpgradeMenu
@onready var anim: AnimationPlayer = $TestAnimPlayer
@onready var iArea: Area3D = $InteractArea
@onready var loadPenaltyC: LoadPenaltyComponent = $LoadPenaltyComponent

const PARRY_SPARK = preload("res://Assets/Randemlyy/ParrySpark.tscn")

@export var canCombo:bool = false
@export var canCrit:bool = false
@export var canStagger:bool = false
@export var stagger_dura: float = 0.7
@export var parry_stagger_duration: float = 1.2

@export var invertControls:float = 1

var TimeSinceDmg:float = 0
var DmgTime:float = 1
var block_animation_started := false
var	bodies_hit_this_swing: Array[Node3D] = []

func _ready() -> void:
	cameraC.start()
	resolveC.start()
	healthC.start()
	healthC.died.connect(onDeath)
	blockC.blocking_started.connect(_on_blocking_started)
	blockC.blocking_ended.connect(_on_blocking_ended)
	
func _process(delta: float) -> void:
	inputC.update(delta)
	var can_block := not _weapon_is_attacking() and not staggerC.is_staggered
	blockC.update(
		inputC.block_held and can_block,
		inputC.block and can_block,
		delta
	)
	if inputC.upgrade_menu:
		upgradeMenu.toggle_menu()
	inventoryC.isEquip = inputC.interact
	inventoryC.isAttack = inputC.attack
	inventoryC.update(resolveC, anim, canStagger, canCombo, canCrit)
	cameraC.update(self, delta)
	resolveC.update(delta)
	healthC.update(delta)
	
func _physics_process(delta: float) -> void:
	TimeSinceDmg += delta
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	if staggerC.is_staggered:
		velocity.x = Vector3.ZERO.x
		velocity.z = Vector3.ZERO.y
		return
	if !staggerC.is_staggered:
		movementC.physics_update(delta, Vector3(inputC.dir.x, 0, inputC.dir.y) * invertControls, self)
		if inputC.dir != Vector2.ZERO:
			animC.process(delta, true)
		else:
			animC.process(delta, false)
	else:
		print("staggered")
	move_and_slide()
	
func take_hit(damage: int, hit_stagger_duration: float = 0.8, hit_direction:Vector3 = Vector3.LEFT, attacker: Node3D = null, hit_collider: Node3D = null) -> void:
	var impact_time = float(Time.get_ticks_usec()) / 1_000_000.0
	var was_blocking_at_impact = blockC.is_blocking
	await get_tree().create_timer(blockC.late_parry_window).timeout
	await get_tree().process_frame
	
	if not is_inside_tree():
		return
		
	if blockC.check_parry_press(impact_time):
		resolveC.gainResolve(blockC.resolve_on_parry)
		if is_instance_valid(attacker):
			var enemy_stagger = attacker.get_node_or_null("StaggerComponent") as StaggerComponent
			if enemy_stagger:
				enemy_stagger.apply_stagger(parry_stagger_duration)
		HitStop.request(0.1, 0.3)
		_spawn_parry_spark(attacker)
		cameraC.shake(0.16, 0.12)
		print ("parried")
		return
		
	if was_blocking_at_impact and blockC.spend_for_block():
		print("blocked")
		return
		
	var final_damage = roundi(damage * loadPenaltyC.damage_taken_mult())
		
	healthC.take_damage(final_damage)
	cameraC.shake(0.12, 0.18)
	staggerC.apply_stagger(hit_stagger_duration)
	print(hit_direction)
	velocity = hit_direction
	
func _spawn_parry_spark(target: Node3D) -> void:
	var spark = PARRY_SPARK.instantiate() as GPUParticles3D
	get_tree().current_scene.add_child(spark)
	
	if is_instance_valid(target):
		spark.global_position = (
			global_position.lerp(target.global_position, .5) + Vector3.UP * 0.8
		)
	else:
		spark.global_position = global_position + Vector3.UP
	spark.restart()
	
func _on_blocking_started() -> void:
	anim.play("Block")
	
func _on_blocking_ended() -> void:
	if anim.current_animation == "Block":
		anim.play("Unblock")
		
func _weapon_is_attacking() -> bool:
	return is_instance_valid(inventoryC.cWeapon) and inventoryC.cWeapon.isAttacking
	
func onDeath():
	queue_free()
	print("Wow ma so bad you are")
	print("daeth")
	print("changed")
	get_tree().change_scene_to_packed(load("uid://o73v2cty65b6"))
