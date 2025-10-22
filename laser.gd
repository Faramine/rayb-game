class_name Laser
extends RayCast3D

@onready var beam : MeshInstance3D = $BeamMesh
@onready var emiter : MeshInstance3D = $EmiterMesh

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var contactPoint
	
	force_raycast_update()
	
	if is_colliding():
		contactPoint = to_local(get_collision_point())
		
		beam.mesh.height = contactPoint.y
		beam.position.y = contactPoint.y/2
	else:
		beam.mesh.height = -100
		beam.position.y = -50

func emiter_on():
	emiter.visible = true

func beam_on():
	beam.visible = true

func emiter_off():
	emiter.visible = false

func beam_off():
	beam.visible = false
