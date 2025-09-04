extends RigidBody3D

var velocity = Vector3()
var v0 = Vector3()
var speed = 10
var dash_speed = 100
var dashpos = Vector3()
var movable = true
var hidden = false

var click_position = Vector2()

func dash(dashpos: Vector3):
	movable = false
	self.dashpos = dashpos
	dashpos.y = 0
	

func _process(delta):
	
	velocity = Vector3()
	var pos = Vector3()
	
	if movable:
		if Input.is_action_pressed("ui_right"):
			velocity.z += -1
		if Input.is_action_pressed("ui_left"):
			velocity.z += 1
		if Input.is_action_pressed("ui_down"):
			velocity.x += 1
		if Input.is_action_pressed("ui_up"):
			velocity.x += -1
		velocity = velocity.normalized() * speed * delta
	else:
		pos = position
		pos.y = 0
		if (pos-dashpos).length() < 1:
			movable = true
		else:
			velocity = (dashpos - position).normalized() * dash_speed * delta
	
	move_and_collide(velocity)
	
	
