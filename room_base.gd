class_name Room
extends Node3D

var coords = [0,0]
var world : World
var is_active : bool = false

@onready var enemies : Array[Enemy] = [$Enemy]

func set_world(world : World):
	self.world = world

func activate_room():
	is_active = true
	print("activate : " + str(coords))

func deactivate_room():
	is_active = false
	print("deactivate : " + str(coords))

func _process(delta: float) -> void:
	if(is_active):
		for enemy in enemies:
			enemy.target_position(self.world.player.global_transform.origin)
	else:
		for enemy in enemies:
			enemy.back_to_spawnpoint()
