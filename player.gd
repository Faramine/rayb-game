extends CharacterBody3D

@onready var armature = $Armature;  # Character armature
@onready var animationTree = $AnimationTree;

@onready var controller = $".."

@export var speed = 15
@export var friction : float = 13
var acceleration : Vector3 = Vector3.ZERO
var dash_speed = 150
var dash_time = 0
var dashpos = Vector3()
var dashDirection = Vector3();
var movable = true
var click_position = Vector2()

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
# Animation variables --------------------
const lerp_smoothstep = 0.5; # Smoothness of the rotation animation on movement direction change

func dash(dashpos: Vector3):
	movable = false
	self.dashpos = dashpos
	dashpos.y = 0

func _process(delta):
	
	if movable:
		input_move(delta)
	else:
		dash_time += delta
		dashpos.y = position.y
		animationTree["parameters/conditions/is_dashing"] = true;
		if (position-dashpos).length() < 0.5 || dash_time >0.3:
			# Si le dash est fini
			movable = true
			dash_time = 0
			velocity = Vector3.ZERO
			animationTree["parameters/conditions/is_dashing"] = false;
		else:
			dashDirection = (dashpos - position).normalized();
			armature.rotation.y = lerp_angle(armature.rotation.y, dashDirection.signed_angle_to(Vector3(0.0,0.0,1.0),Vector3(0.0,-1.0,0.0)), lerp_smoothstep);
			velocity = dashDirection * dash_speed;
			
	if not is_on_floor():
		velocity.y -= gravity
	move_and_slide()

func input_move(delta):
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
