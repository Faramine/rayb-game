class_name World
extends Node3D

signal boss_room_entered

@export var minimap : Control
@export var generator : MapGen

@onready var player : Player = $Player
var camera : Camera
var boss_world : bool
@onready var cursor : Node3D = $Cursor

# Dictionnaire Coord/Room
var rooms : Dictionary = Dictionary() #room
var start_room : Room
var preboss_room : Room
var boss_room : Room
var active_room : Room

var norb = 0

signal door_opened

func _ready() -> void:
	if boss_world:
		generator._generate_boss_map()
	else:
		generator._generate_map()
		minimap.display_map(rooms.keys())
		minimap.display_special_rooms(start_room.coords,preboss_room.coords,boss_room.coords)
		print("hahaha")

#func start():
	#print("generating_map")
	#generator._generate_map()
	#print("map_generated")
	#minimap.display_map(rooms.keys())
	#minimap.display_special_rooms(start_room.coords,preboss_room.coords,boss_room.coords)

func change_room(coords):
	if not boss_world and coords == boss_room.coords: 
		boss_room_entered.emit()
	else:
		if boss_world:
			generator._generate_next_boss_map(coords)
		else:
			minimap.change_room(coords)
		activate_room(rooms.get(coords))
		camera.track(active_room.camera_position)
	
		# Updating the current room position for all shaders
		# Useful for the volumic "vignette" effect on environement textures
		RenderingServer.global_shader_parameter_set("current_room_position", active_room.global_position);
	
func activate_room(next_room : Room):
	if(self.active_room): self.active_room.deactivate_room()
	next_room.activate_room()
	self.active_room = next_room
	
func connect_orb(orb : Orb):
	norb = norb+1
	orb.broken.connect(on_orb_breaking)

func on_orb_breaking(orb : Orb):
	if orb != null:
		norb = norb - 1
		if norb < 1 :
			door_opened.emit(self)
