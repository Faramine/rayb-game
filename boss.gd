class_name Boss
extends Node3D

var target


func _physics_process(delta: float) -> void:
	if target:
		global_position = global_position.lerp(target.global_position, delta)
