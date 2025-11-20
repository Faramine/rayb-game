class_name Laser
extends RayCast3D

@onready var beam : MeshInstance3D = $BeamMesh
@onready var emiter : MeshInstance3D = $EmiterMesh
@onready var skeleton : Skeleton3D = $beam_armature/Skeleton3D
@onready var armature : Node3D = $beam_armature
@onready var debug_contact: =$debug
func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	var contactPoint
	
	force_raycast_update()
	
	if is_colliding():
		contactPoint = get_collision_point()
		
		$HitBox/CollisionShape3D.position = to_local(contactPoint)
		var bone_target = skeleton.find_bone("beam_target")
		skeleton.set_bone_pose_position(bone_target,skeleton.to_local(contactPoint))
		debug_contact.global_position = contactPoint
		
	else:
		beam.mesh.height = -100
		beam.position.y = -50

func emiter_on():
	emiter.visible = true

func beam_on():
	#beam.visible = true
	armature.visible = true
	

func emiter_off():
	emiter.visible = false

func beam_off():
	#beam.visible = false
	armature.visible = false

func turn_on():
	emiter_on()
	beam_on()
	$HitBox.set_deferred("monitorable", true)

func turn_off():
	emiter_off()
	beam_off()
	$HitBox.set_deferred("monitorable", false)
