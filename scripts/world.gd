class_name World
extends Node3D

@export var minimap : Control
@export var generator : MapGen

@onready var player : Player = $Player
@onready var camera : Camera = $Camera
@onready var cursor = $Cursor

# Dictionnaire Coord/Room
var rooms : Dictionary = Dictionary() #room
var start_room : Room
var preboss_room : Room
var boss_room : Room
var active_room : Room

func _ready() -> void:
	generator.generate_map(self)
	minimap.display_map(rooms.keys())

func change_room(coords):
	minimap.change_room(coords)
	activate_room(rooms.get(coords))
	camera.track(active_room.camera_posistion)
	
func activate_room(next_room : Room):
	if(self.active_room): self.active_room.deactivate_room()
	next_room.activate_room()
	self.active_room = next_room
