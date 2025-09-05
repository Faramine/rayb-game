extends Node3D

var rooms = Dictionary()
var room_list = Array()
var room_start
var map = Array()
var map_size = 11
var map_center = 5

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

func generate_map() -> void:
	
	var room_scene = load("res://room_base.tscn")
	
	var list
	var new_room
	
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
		new_room.neighbors[1] = true
		rooms.set(k, new_room)
		add_child(new_room)
		
