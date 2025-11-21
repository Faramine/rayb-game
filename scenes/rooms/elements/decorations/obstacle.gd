extends StaticBody3D

func _ready() -> void:
	$Area3D.area_entered.connect(on_area_entered)
	$Area3D.area_exited.connect(on_area_exited)

func on_area_entered(body : Area3D):
	if body.is_in_group("Player"):
		add_collision_exception_with(body.get_parent())

func on_area_exited(body : Area3D):
	if body.is_in_group("Player"):
		remove_collision_exception_with(body.get_parent())
