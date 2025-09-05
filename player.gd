extends RigidBody3D

var velocity = Vector3()
var speed = 10
var acceleration : float
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
		if Input.is_action_pressed("move_right"):
			velocity.z += -1
		if Input.is_action_pressed("move_left"):
			velocity.z += 1
		if Input.is_action_pressed("move_down"):
			velocity.x += 1
		if Input.is_action_pressed("move_up"):
			velocity.x += -1
		velocity = velocity.normalized() * speed * delta
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
	
	
