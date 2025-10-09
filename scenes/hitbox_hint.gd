extends MeshInstance3D

@onready var r = 0

func _process(delta: float) -> void:
	global_rotation.y = r + delta * 0.25
	r = global_rotation.y
