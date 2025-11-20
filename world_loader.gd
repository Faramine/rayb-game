extends Node3D

@onready var game = $".."
var world : World
@onready var camera : = %Camera

var world_scene = preload("res://scenes/world.tscn")

func start():
	if world : unload_world()
	load_world(true)
	world.boss_room_entered.connect(boss_world)
	$"../CanvasLayer/GameMenu".visible = false

func load_world(_boss_world : bool):
	world = world_scene.instantiate()
	world.boss_world = _boss_world
	world.camera = camera
	add_child.call_deferred(world)
	world.player_died.connect(on_death)

func boss_world():
	unload_world()
	load_world(true)

func unload_world():
	world.queue_free()

func on_death():
	$"../CanvasLayer/GameMenu".visible = true
