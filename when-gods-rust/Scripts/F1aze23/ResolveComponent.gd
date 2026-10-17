class_name ResolveComponent
extends Node

@onready var world_viewport: SubViewport = $Resolve
@onready var world_sprite: Sprite3D = $ResolveSprite
@onready var progress_bar: ProgressBar = $"../CanvasLayer/Control/ResolveBar"
@onready var player: CharacterBody3D
@onready var upgradeC: UpgradeComponent = $"../UpgradeComponent"
@onready var load_marker: ColorRect = $Resolve/LoadMarker

@export var offset: Vector3 = Vector3(0, 1.8, 0)
@export var maxResolve:float = 100.0
@export var cResolve:float = 100.0
@export var resolveBar:ProgressBar
@export var resolveDecay:float = 0.03
@export var followSpeed = 18.0
@export var bar_smoothing_speed: float = 12.0

var canDecay:bool = true 

func _ready() -> void:
	player = get_parent() as CharacterBody3D
	resolveBar.max_value = maxResolve
	resolveBar.value = cResolve
	progress_bar.max_value = 100.0
	progress_bar.value = (cResolve/maxResolve) * 100
	upgradeC.load_changed.connect(_update_load_marker)
	_update_load_marker(upgradeC.get_current_load(), maxResolve)
	
	if is_instance_valid(player):
		world_sprite.global_position = player.global_position + offset
	call_deferred("_assign_viewport_texture")
	
func _process(delta: float) -> void:
	var target_position = player.global_position + offset
	var weight = 1.0 - exp(-followSpeed * delta)
	world_sprite.global_position = world_sprite.global_position.lerp(
		target_position,
		weight
	)
		
func _assign_viewport_texture() -> void:
	world_sprite.texture = world_viewport.get_texture()
	
func start():
	resolveBar.max_value = maxResolve
	resolveBar.value = cResolve
	
func update(delta:float):
	if canDecay:
		cResolve -= resolveDecay
	
	cResolve = clampf(cResolve, 0.0, maxResolve)
	
	var bar_weight = 1.0 - exp(-bar_smoothing_speed * delta)
	var target_percent = (cResolve/maxResolve) * 100.0
	
	if is_instance_valid(resolveBar):
		resolveBar.value = lerpf(resolveBar.value, cResolve, bar_weight)
	if is_instance_valid(progress_bar):
		progress_bar.value = lerpf(progress_bar.value, target_percent, bar_weight)
	
func gainResolve(amt:float):
	cResolve += amt
	canDecay = false
	var timer = Timer.new()
	timer.wait_time = 2
	timer.one_shot = true
	add_child(timer)
	timer.timeout.connect(func():
		canDecay = true
		)
	timer.start()
	print(amt, " Resolve Gained")

func _update_load_marker(current_load: float, max_load: float) -> void:
	if max_load <= 0.0:
		return
	
	var ratio = clampf(current_load / max_load, 0.0, 1.0)
	
	load_marker.anchor_bottom = 1.0
	load_marker.anchor_left = ratio
	load_marker.anchor_right = ratio
	load_marker.anchor_top = 0.0
	load_marker.offset_bottom = 0.0
	load_marker.offset_top = 0.0
	load_marker.offset_right = 1.5
	load_marker.offset_left = -1.5
func useResolve(amt:float):
	cResolve = maxf(cResolve - amt, 0.0)
