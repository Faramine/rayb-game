class_name Player
extends CharacterBody3D
# Nodes #
@export var world : World
@onready var armature = $Armature;
@onready var animationTree = $AnimationTree;
@onready var controller = $Player_controller
@onready var dash_ability : DashAbility = $Dash
# Player properties #
@export var speed = 15
@export var friction : float = 13
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const lerp_smoothstep = 0.5; # Smoothness of the rotation animation on movement direction change

func _process(delta):
	if dash_ability.is_dashing:
		dash_ability.process_dash(delta)
	else:
		process_move(delta)
	if not is_on_floor():
		velocity.y -= gravity
	move_and_slide()

func dash(dash_target_pos: Vector3):
	dash_ability.dash(dash_target_pos)

func process_move(delta):
	var direction = controller.move_vector()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		armature.rotation.y = lerp_angle(armature.rotation.y, direction.signed_angle_to(Vector3(0.0,0.0,1.0),Vector3(0.0,-1.0,0.0)), lerp_smoothstep);
		animationTree["parameters/conditions/is_walking"] = true;
		animationTree["parameters/conditions/is_idle"] = false;
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * friction);
		velocity.z = lerp(velocity.z, 0.0, delta * friction);
		animationTree["parameters/conditions/is_walking"] = false;
		animationTree["parameters/conditions/is_idle"] = true;

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("Camera_zone"):
		world.change_room(area.owner.coords)
