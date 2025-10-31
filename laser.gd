class_name Laser
extends RayCast3D

@onready var beam : MeshInstance3D = $BeamMesh
@onready var emiter : MeshInstance3D = $EmiterMesh
@onready var skeleton : Skeleton3D = $beam_armature/Skeleton3D
@onready var armature : Node3D = $beam_armature
@onready var debug_contact: =$debug
func _ready() -> void:
	pass

func _process(delta: float) -> void:
	var contactPoint
	
	force_raycast_update()
	
	if is_colliding():
		contactPoint = get_collision_point()
		
		beam.mesh.height = contactPoint.y
		beam.position.y = contactPoint.y/2
		var bone_target = skeleton.find_bone("beam_target")
		var bone_origin = skeleton.find_bone("beam_origin")
		#skeleton.set_bone_pose_position(id,skeleton.to_local(contactPoint))
		skeleton.set_bone_pose_position(bone_target,skeleton.to_local(contactPoint))
		debug_contact.global_position = contactPoint
		
	else:
		beam.mesh.height = -100
		beam.position.y = -50

func emiter_on():
	#emiter.visible = true
	pass

func beam_on():
	#beam.visible = true
	armature.visible = true
	

func emiter_off():
	#emiter.visible = false
	pass

func beam_off():
	#beam.visible = false
	armature.visible = false
