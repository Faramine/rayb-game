extends Camera3D

var target_position = Vector3()
var tracking = false

func _process(delta: float) -> void:
	if tracking:
		global_position = global_position.lerp(target_position,30*delta)
	

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("Camera_zone"):
		tracking = true
		target_position = area.global_position
