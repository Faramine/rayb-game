extends Node3D

@onready var animation_tree = $AnimationTree
@onready var door_csg = $Obstacle/CollisionShape3D

var world : World
var room : Room

func connect_room(_room : Room):
	room = _room
	world = _room.world
	_room.room_cleared.connect(_on_room_cleared)

func _on_room_cleared(_boss):
	animation_tree.open()
	door_csg.set_deferred("disabled", true)
