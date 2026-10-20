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
@onready var dodgeC: DodgeComponent = $DodgeComponent
@onready var upgradeC: UpgradeComponent = $UpgradeComponent
@onready var interactC: InteractComponent = $InteractComponent
@onready var campfireMenu: CampfireMenu = $CanvasLayer/CampfireMenu

@onready var label_4: Label = $CanvasLayer/Control/Label4

const PARRY_SPARK = preload("res://Assets/Randemlyy/ParrySpark.tscn")

@export var canCombo:bool = false
@export var canCrit:bool = false
@export var canStagger:bool = false
@export var stagger_dura: float = 0.7
@export var parry_stagger_duration: float = 1.2
@export var invertControlsX:float = 1
@export var invertControlsY:float = 1
@export var SwitchControlAxes:bool = false
@export var max_heals = 4
@export var lock_on_range = 20.0

var lock_on_target: Node3D = null
var TimeSinceDmg:float = 0
var DmgTime:float = 1
var block_animation_started := false
var	bodies_hit_this_swing: Array[Node3D] = []

func _ready() -> void:
	cameraC.start()
	resolveC.start()
	healthC.start()
	healthC.died.connect(onDeath)
	campfireMenu.set_gears_pressed.connect(_on_set_gears_pressed)
	campfireMenu.refill_heals_pressed.connect(_on_refill_heals_pressed)
	blockC.blocking_started.connect(_on_blocking_started)
	blockC.blocking_ended.connect(_on_blocking_ended)
	upgradeMenu.back_pressed.connect(_on_upgrade_back_pressed)
	campfireMenu.exit_pressed.connect(_on_campfire_exit_pressed)
	
func _process(delta: float) -> void:
	inputC.update(delta)

	if inputC.upgrade_menu:
		if campfireMenu.visible:
			campfireMenu.close()
		elif upgradeMenu.visible:
			upgradeMenu.toggle_menu()
			
	inventoryC.isEquip = false
	
	var menu_open = campfireMenu.visible or upgradeMenu.visible
	
	if inputC.interact and not menu_open:
		var handled := interactC.process(delta, true)
		if not handled:
			inventoryC.isEquip = true
				
			for item in iArea.get_overlapping_bodies():
				if item.is_in_group("Gear"):
					upgradeC.pickupGear(item.gearData)
					item.queue_free()
	
	menu_open = campfireMenu.visible or upgradeMenu.visible
	
	var can_block := (
		not menu_open and 
		not _weapon_is_attacking() and
		not staggerC.is_staggered
	)
	
	blockC.update(
		inputC.block_held and can_block,
		inputC.block and can_block,
		delta
	)
	
	inventoryC.isAttack = inputC.attack and not menu_open
	
	inventoryC.update(resolveC, anim, canStagger, canCombo, canCrit)
	if inputC.lock_on and not menu_open:
		if is_instance_valid(lock_on_target):
			_set_lock_on_target(null)
		else:
			_set_lock_on_target(_find_lock_on_target())
	
	if lock_on_target != null:
		if not is_instance_valid(lock_on_target):
			_set_lock_on_target(null)
		elif global_position.distance_to(lock_on_target.global_position) > lock_on_range:
			_set_lock_on_target(null)
	
	
	if not menu_open:
		cameraC.update(self, delta)
		
	resolveC.update(delta)
	healthC.update(delta)
	
	if inputC.dodge and not menu_open:
		dodgeC.dodge()
		
	if inputC.use and not menu_open:
		if inventoryC.Heals > 0:
			healthC.current_health += 25
			inventoryC.UseHeal()
			
	label_4.text = str(inventoryC.Heals)
	
func _physics_process(delta: float) -> void:
	
	if campfireMenu.visible or upgradeMenu.visible:
		velocity = Vector3.ZERO
		return
		
	TimeSinceDmg += delta
	
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
		
	if staggerC.is_staggered:
		velocity.x = Vector3.ZERO.x
		velocity.z = Vector3.ZERO.y
		return
		
	var move_input: Vector2
	
	if not SwitchControlAxes:
		move_input = Vector2(inputC.dir.x * invertControlsX, inputC.dir.y * invertControlsY)
	else:
		move_input = Vector2(inputC.dir.y * invertControlsY, inputC.dir.x * invertControlsX)
		
	var move_dir: Vector3	
	
	if is_instance_valid(lock_on_target):
		var to_target = lock_on_target.global_position - global_position
		to_target.y = 0
		
		if to_target.length_squared() > 0.001:
			var forward = to_target.normalized()
			var right = forward.cross(Vector3.UP).normalized()
			
			move_dir = (right * move_input.x - forward * move_input.y).limit_length(1.0)
		else:
			move_dir = Vector3.ZERO
	else:
		_set_lock_on_target(null)
		move_dir = cameraC.get_move_direction(move_input)
		
	movementC.physics_update(delta, move_dir, self)
	
	if is_instance_valid(lock_on_target):
		var to_target = lock_on_target.global_position - global_position
		to_target.y = 0
		
		if to_target.length_squared() > 0.001:
			var target_yaw := atan2(-to_target.x, -to_target.z)
			rotation.y = rotate_toward(rotation.y, target_yaw, 16.0 * delta)
	
	if inputC.dir != Vector2.ZERO:
		animC.process(true, false)
	else:
		animC.process(false, false)
	
	move_and_slide()
	
func take_hit(damage: int, hit_stagger_duration: float = 0.8, hit_direction:Vector3 = Vector3.LEFT, attacker: Node3D = null, hit_collider: Node3D = null) -> void:
	if dodgeC.isDodging:
		resolveC.gainResolve(10)
		return
	
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
	animC.process(false, true)
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

func open_campfire_menu() -> void:
	campfireMenu.open()

func _on_set_gears_pressed() -> void:
	campfireMenu.close()
	upgradeMenu.toggle_menu()

func _on_refill_heals_pressed() -> void:
	inventoryC.Heals = max_heals
	campfireMenu.close()

func _on_campfire_exit_pressed() -> void:
	campfireMenu.close()

func _on_upgrade_back_pressed() -> void:
	upgradeMenu.toggle_menu()
	campfireMenu.open()

func _set_lock_on_target(target: Node3D) -> void:
	lock_on_target = target
	cameraC.set_lock_on_target(lock_on_target)

func _find_lock_on_target() -> Node3D:
	var closest: Node3D = null
	var closest_distance = lock_on_range
	
	for node in get_tree().get_nodes_in_group("Enemy"):
		if not node is Node3D:
			continue
		
		var candidate = node as Node3D
		var distance = global_position.distance_to(candidate.global_position)
		
		if distance < closest_distance:
			closest = candidate
			closest_distance = distance
	return closest

func onDeath():
	queue_free()
	print("Wow ma so bad you are")
	print("daeth")
	print("changed")
	get_tree().change_scene_to_packed(load("uid://o73v2cty65b6"))
