class_name World
extends Node3D

@onready var player : Player = $Player_controller.get_node("Player")
var rooms : Dictionary = Dictionary()
var room_list = Array()
var room_start
var map = Array()
var active_room : Room
@export var map_size = 11
var map_center = map_size/2

func _init() -> void:
	map.resize(map_size)
	for i in range(0,map_size):
		map[i] = Array()
		map[i].resize(map_size)
		for j in range(0,map_size):
			map[i][j] = 0

func _ready() -> void:
	var room
	generate_map()
	get_node("Map/Map_element/Map_control").display_map(map)

func generate_map() -> void:
	
	var room_scene = load("res://room_base.tscn")
	
	var list
	var new_room : Room
	
	var map_closed = false
	var map_opened = false
	
	map[map_center][map_center] = 1
	room_list.push_back([map_center,map_center])
	
	while !map_closed:
		map_opened = false
		
		list = room_list.duplicate()
		for k in list:
			if k[0]+1 < map_size && map[k[0]+1][k[1]] == 0:
				map_opened = true
				if randf() < -1*float(list.size())/10+11/10:
					map[k[0]+1][k[1]] = 1
					room_list.push_back([k[0]+1,k[1]])
				else:
					map[k[0]+1][k[1]] = -1
			if k[0]-1 >= 0 && map[k[0]-1][k[1]] == 0:
				map_opened = true
				if randf() < -1*float(list.size())/10+11/10:
					map[k[0]-1][k[1]] = 1
					room_list.push_back([k[0]-1,k[1]])
				else:
					map[k[0]-1][k[1]] = -1
			if k[1]+1 < map_size && map[k[0]][k[1]+1] == 0:
				map_opened = true
				if randf() < -1*float(list.size())/10+11/10:
					map[k[0]][k[1]+1] = 1
					room_list.push_back([k[0],k[1]+1])
				else:
					map[k[0]][k[1]+1] = -1
			if k[1]-1 >= 0 && map[k[0]][k[1]-1] == 0:
				map_opened = true
				if randf() < -1*float(list.size())/10+11/10:
					map[k[0]][k[1]-1] = 1
					room_list.push_back([k[0],k[1]-1])
				else:
					map[k[0]][k[1]-1] = -1
					
		map_closed = !map_opened
		
	for k in room_list:
		
		new_room = room_scene.instantiate()
		new_room.position.x = 26.5 * (k[0]-map_center)
		new_room.position.z = 26.5 * (k[1]-map_center)
		new_room.coords = k
		new_room.set_world(self)
		rooms.set(k, new_room)
		add_child(new_room)
		
func change_room(coords):
	get_node("Map/Map_element/Map_control").change_room(coords)
	activate_room(rooms.get(coords))
	
func activate_room(next_room : Room):
	if(self.active_room): self.active_room.deactivate_room()
	next_room.activate_room()
	self.active_room = next_room
