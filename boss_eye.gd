extends Node3D

@onready var target = $Target
@onready var animation_tree = $AnimationPlayer

var world : World
var room : Room

func _physics_process(_delta: float) -> void:
	if world:
		target.global_position = world.player.global_position

func connect_room(_room : Room):
	room = _room
	world = _room.world
	_room.room_cleared.connect(_on_room_cleared)

func _on_room_cleared(_boss):
	animation_tree.die()
