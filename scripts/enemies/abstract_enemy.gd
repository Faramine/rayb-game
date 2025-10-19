class_name Enemy
extends CharacterBody3D

signal dead

@export var nav : NavigationAgent3D
@export var target_node : Node3D
var spawn_point : Vector3
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var speed = 10
var player : Player
var room : Room

func _process(delta):
	pass

func on_room_activated():
	self.global_position = spawn_point

func on_room_deactivated():
	self.global_position = spawn_point
	velocity = Vector3.ZERO

func move_toward_target(speed, delta):
	var next_location = nav.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * speed
	velocity = velocity.move_toward(new_velocity, delta * 100)
	#velocity = new_velocity * delta * 270
	self.rotation.y = lerp_angle(self.rotation.y, new_velocity.signed_angle_to(Vector3(0,0,1),Vector3(0,-1,0)), 25 * delta);

func update_target_position(target : Vector3):
	nav.target_position = target
	$Target.global_position = target

func set_spawn(spawn_point : Vector3):
	self.spawn_point = spawn_point
	
