extends CharacterBody3D

@onready var armature = $Armature  # Character armature

@onready var controller = $".."

@export var speed = 15
@export var friction : float = 13
var acceleration : Vector3 = Vector3.ZERO
var dash_speed = 100
var dash_time = 0
var dashpos = Vector3()
var movable = true
var click_position = Vector2()

# Animation variables --------------------
const lerp_smoothstep = 0.5; # Smoothness of the rotation animation on movement direction change

func dash(dashpos: Vector3):
	movable = false
	self.dashpos = dashpos
	dashpos.y = 0

func _process(delta):
	velocity = Vector3()
	var pos = Vector3()
	
	if movable:
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

		input_move2(delta)

	else:
		dash_time += delta 
		pos = position
		pos.y = 0
		if (pos-dashpos).length() < 0.5 || dash_time >0.3:
			movable = true
			dash_time = 0
		else:
			velocity = (dashpos - position).normalized() * dash_speed * delta
	move_and_collide(velocity)

func input_move(delta):
	var traction = controller.move_vector()
	acceleration += traction * acceleration * delta
#	velocity -= velocity * friction * delta

func input_move2(delta):
	var direction = controller.move_vector()
	if direction:
		acceleration = direction * speed * delta
	else:
		acceleration.x = lerp(acceleration.x, 0.0, delta * friction)
		acceleration.z = lerp(acceleration.z, 0.0, delta * friction)
	velocity += acceleration
