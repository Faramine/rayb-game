extends Camera3D

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("Camera_zone"):
		global_position = area.global_position
		print("cac")
