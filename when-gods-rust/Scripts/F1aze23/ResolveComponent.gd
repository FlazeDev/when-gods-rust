class_name ResolveComponent
extends Node

@onready var world_viewport: SubViewport = $Resolve
@onready var world_sprite: Sprite3D = $ResolveSprite
@onready var progress_bar: ProgressBar = $"../CanvasLayer/Control/ResolveBar"
@onready var player: CharacterBody3D

@export var offset: Vector3 = Vector3(0, 1.8, 0)
@export var maxResolve:float = 100.0
@export var cResolve:float = 100.0
@export var resolveBar:ProgressBar
@export var resolveDecay:float = 0.03
var canDecay:bool = true 
func _ready() -> void:
	player = get_parent() as CharacterBody3D
	call_deferred("_assign_viewport_texture")
func _process(delta: float) -> void:
	if is_instance_valid(player) and is_instance_valid(world_sprite):
		world_sprite.global_position = player.global_position + offset
func _assign_viewport_texture() -> void:
	world_sprite.texture = world_viewport.get_texture()
func start():
	resolveBar.max_value = maxResolve
	resolveBar.value = cResolve
func update(delta:float):
	if cResolve >= maxResolve:
		cResolve = maxResolve
	elif cResolve <= 0.0:
		cResolve = 0
	resolveBar.value = cResolve
	progress_bar.value = (cResolve / maxResolve) * 100.0
	if canDecay:
		cResolve-=resolveDecay
	progress_bar.value = (cResolve/maxResolve) * 100
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
func useResolve(amt:float):
	cResolve = maxf(cResolve - amt, 0.0)
