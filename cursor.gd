extends Node3D

var target = Vector3()

func _process(delta: float) -> void:
	global_position = global_position.lerp(target,delta*100)
