extends CharacterBody3D

@onready var controller = $".."

@export var speed = 0.05
@export var friction : float = 13
var acceleration : Vector3 = Vector3.ZERO
var dash_speed = 100
var dash_time = 0
var dashpos = Vector3()
var movable = true
var click_position = Vector2()

func dash(dashpos: Vector3):
	movable = false
	self.dashpos = dashpos
	dashpos.y = 0

func _process(delta):
	velocity = Vector3()
	var pos = Vector3()
	
	if movable:
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
		acceleration = direction * speed
	else:
		acceleration.x = lerp(acceleration.x, 0.0, delta * friction)
		acceleration.z = lerp(acceleration.z, 0.0, delta * friction)
	velocity += acceleration
