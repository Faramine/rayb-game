extends Node

var thread = Thread.new()
@onready var game = $".."

var world_scene = preload("res://scenes/world.tscn")

func _ready():
	load_world()

func _process(delta):
	if thread.is_started() and not thread.is_alive():
		thread.wait_to_finish()

func load_world():
	thread.start(threaded_load)

func threaded_load():
	var world = world_scene.instantiate()
	world.start()
	game.add_child.call_deferred()
