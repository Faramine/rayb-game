extends CharacterBody3D

@onready var armature = $Armature  # Character armature

@onready var controller = $".."

@export var speed = 15
@export var friction : float = 13
var acceleration : Vector3 = Vector3.ZERO
var dash_speed = 150
var dash_time = 0
var dashpos = Vector3()
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
		if Input.is_action_pressed("move_right"):
			# TODO: change to non-hardcoded, normalized vector alternative
			# Smoothly sets the player model direction
			armature.rotation.y = lerp_angle(armature.rotation.y, PI, lerp_smoothstep);
		if Input.is_action_pressed("move_left"):
			# TODO: change to non-hardcoded, normalized vector alternative
			# Smoothly sets the player model direction
			armature.rotation.y = lerp_angle(armature.rotation.y, 0.0, lerp_smoothstep);

		if Input.is_action_pressed("move_down"):
			# TODO: change to non-hardcoded, normalized vector alternative
			# Smoothly sets the player model direction
			armature.rotation.y = lerp_angle(armature.rotation.y, PI/2.0, lerp_smoothstep);

		if Input.is_action_pressed("move_up"):
			# TODO: change to non-hardcoded, normalized vector alternative
			# Smoothly sets the player model direction
			armature.rotation.y = lerp_angle(armature.rotation.y, -PI/2.0, lerp_smoothstep);
	else:
		dash_time += delta
		dashpos.y = position.y
		if (position-dashpos).length() < 0.5 || dash_time >0.3:
			# Si le dash est fini
			movable = true
			dash_time = 0
			velocity = Vector3.ZERO
		else:
			velocity = (dashpos - position).normalized() * dash_speed
	if not is_on_floor():
		velocity.y -= gravity
	move_and_slide()

func input_move(delta):
	var direction = controller.move_vector()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * friction)
		velocity.z = lerp(velocity.z, 0.0, delta * friction)
