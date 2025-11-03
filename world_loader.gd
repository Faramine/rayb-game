extends Node

@onready var game = $".."
var world : World
@onready var camera : = %Camera

var world_scene = preload("res://scenes/world.tscn")

func _ready():
	load_world(false)
	world.boss_room_entered.connect(boss_world)

func load_world(boss_world : bool):
	world = world_scene.instantiate()
	world.boss_world = boss_world
	world.camera = camera
	game.add_child.call_deferred(world)

func boss_world():
	unload_world()
	load_world(true)

func unload_world():
	world.queue_free()
