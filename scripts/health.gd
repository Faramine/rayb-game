class_name Health
extends Node

@export var max_health = 10
var current_health = max_health
var last_damage = 0
var damage_buffer = 0
var damage_cache = 0

signal out_of_health

func take_damage(damage):
	last_damage = damage
	current_health -= damage
	if current_health <= 0:
		current_health = 0
		out_of_health.emit()

func buffer_damage(damage):
	damage_buffer += damage

func apply_buffered_damage():
	take_damage(damage_buffer)
	damage_buffer = 0

func health_percent():
	return current_health / max_health * 100

func is_dead():
	return current_health <= 0
