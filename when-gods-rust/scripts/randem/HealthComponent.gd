class_name HealthComponent
extends Node

signal health_changed(current: int, maximum: int)
signal died

@export var max_health: int = 100
@export var current_health: int
@export var healthBar:ProgressBar
func start() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)
	if is_instance_valid(healthBar):
		healthBar.max_value = max_health
		healthBar.value = max_health
func update():
	if is_instance_valid(healthBar):
		healthBar.max_value = max_health
		healthBar.value = current_health
func take_damage(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return
	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health, max_health)
	if current_health == 0:
		died.emit()
func heal(amount: int) -> void:
	if amount <= 0 or current_health <= 0:
		return
	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)
	
	if current_health == 0:
		died.emit()
