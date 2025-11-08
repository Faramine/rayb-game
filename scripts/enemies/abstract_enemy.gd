class_name Enemy
extends CharacterBody3D

##Abstract class representing enemies.
##
##Enemies types should inherit this class.
##It contains all the call, pathfinding, and loading mechanics.

#region Signals
##Signal called on enemy death.
@warning_ignore("unused_signal")
signal dead
#endregion

#region Exports
##Navigation Agent used for path finding
@export var nav : NavigationAgent3D
##Node representing target for the path finding
@export var target_node : Node3D
##Mouvement speed
@export var speed : float = 10
#endregion

#region Members
##Spawn point of the enemy, defined at spawn.
var spawn_point : Vector3
##Gravity as defined in ProjectSettings/physics/3d/default_gravity.
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
##Reference to the player.
var player : Player
##Reference to the [Room] the enemy is dependant of.
var room : Room
#endregion

#region Signal_Handlers
##Called upon when the room get activated.
func on_room_activated():
	self.global_position = spawn_point

##Called upon when the room get deactivated.
func on_room_deactivated():
	self.global_position = spawn_point
	velocity = Vector3.ZERO
#endregion

#region Control_Methods
##Move the enemy toward its [member Enemy.target_node].
func move_toward_target(_speed, delta):
	var next_location = nav.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * _speed
	velocity = velocity.move_toward(new_velocity, delta * 100)
	#velocity = new_velocity * delta * 270
	self.rotation.y = lerp_angle(self.rotation.y, new_velocity.signed_angle_to(Vector3(0,0,1),Vector3(0,-1,0)), 25 * delta);

##Update the target position of the [smember Enemy.nav] and [member Enemy.target_node].
func update_target_position(target : Vector3):
	nav.target_position = target
	$Target.global_position = target
#endregion

#region Initialization_Methods
##Set the spawn point(Used when the enemy is initially placed in a room).
func set_spawn(_spawn_point : Vector3):
	self.spawn_point = _spawn_point
#endregion
