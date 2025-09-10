class_name Camera
extends Camera3D

var target_position = Vector3()
var tracking = false

func _process(delta: float) -> void:
	if tracking:
		global_position = global_position.lerp(target_position,30*delta)

func track(position: Vector3) -> void:
	tracking = true
	target_position = position
