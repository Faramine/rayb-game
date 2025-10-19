class_name BossDoor
extends Node3D



func connect_door(world : World):
	world.door_opened.connect(on_door_opened)

func on_door_opened(world : World):
#	opening door animation
	visible = false
	pass
