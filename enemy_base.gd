class_name Enemy
extends CharacterBody3D

@onready var nav = $NavigationAgent3D
@onready var target_mesh = $Target
var speed = 10
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var spawn_point : Vector3

func _ready() -> void:
	self.spawn_point = self.global_position

func _process(delta):
	if not is_on_floor():
		velocity.y -= gravity
	var next_location = nav.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * speed
	
	velocity = velocity.move_toward(new_velocity, 0.25)
	move_and_slide()

func back_to_spawnpoint():
	if self.spawn_point:
		nav.target_position = self.spawn_point
		target_mesh.global_position = self.spawn_point

func target_position(target : Vector3):
	nav.target_position = target
	target_mesh.global_position = target
