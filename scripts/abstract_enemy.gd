class_name Enemy
extends CharacterBody3D

@onready var nav = $NavigationAgent
@onready var target_mesh = $Target
var spawn_point : Vector3
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed = 10
var player : Player

func _process(delta):
	pass

func on_room_activated():
	self.global_position = spawn_point
	pass

func on_room_deactivated():
	self.global_position = spawn_point

func move_toward_target():
	var next_location = nav.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * speed
	velocity = velocity.move_toward(new_velocity, 0.25)

func update_target_position(target : Vector3):
	nav.target_position = target
	#target_mesh.global_position = target

func set_spawn(spawn_point : Vector3):
	self.spawn_point = spawn_point
