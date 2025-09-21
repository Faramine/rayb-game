class_name MapGen
extends Node

@export var map_size = 11

@onready var start_layout = preload("res://scenes/rooms/layouts/start_room_layout_1.tscn")
@onready var preboss_layout = preload("res://scenes/rooms/layouts/base_preboss_room_layout.tscn")
@onready var layout = [preload("res://scenes/rooms/layouts/base_room_layout.tscn"),
preload("res://scenes/rooms/layouts/test_room_layout_1.tscn"), preload("res://scenes/rooms/layouts/test_room_layout_2.tscn")]
@onready var orb = preload("res://scenes/rooms/elements/interactables/orb.tscn")

func generate_map(world : World):
	var room_list = Array()
	var map = Array()
	var map_center = map_size/2
	
	map.resize(map_size)
	for i in range(0,map_size):
		map[i] = Array()
		map[i].resize(map_size)
		for j in range(0,map_size):
			map[i][j] = 0
	
	var room_scene = load("res://scenes/room_base.tscn")
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
			map_opened = verify_room_placements(k,map,list,room_list)
		
		map_closed = !map_opened
		
	#Placing the rooms
	
	for k in room_list:
		new_room = room_scene.instantiate()
		new_room.position.x = 26.5 * (k[0]-map_center)
		new_room.position.z = 26.5 * (k[1]-map_center)
		new_room.coords = k
		new_room.set_world(world)
		world.rooms.set(k, new_room)
		add_child(new_room)
		for r in room_list:
			new_room.open_wall(r)
	
	world.start_room = world.rooms.get([map_center,map_center])
	
	var bossable_room = Array()
	
	#placing the boss room
	for k in room_list:
		if k[0]-1 >= 0 && map[k[0]-1][k[1]] == -1:
			bossable_room.push_back(k)
	
	var preboss = bossable_room[randi_range(0,bossable_room.size()-1)]
	world.preboss_room = world.rooms.get(preboss)
	room_list.push_back([preboss[0]-1,preboss[1]])
	world.preboss_room.open_wall([preboss[0]-1,preboss[1]])
	
	new_room = room_scene.instantiate()
	new_room.position.x = 26.5 * (preboss[0]-1-map_center)
	new_room.position.z = 26.5 * (preboss[1]-map_center)
	new_room.coords = [preboss[0]-1,preboss[1]]
	new_room.set_world(world)
	world.rooms.set([preboss[0]-1,preboss[1]], new_room)
	world.boss_room = new_room
	add_child(new_room)
	new_room.open_wall(preboss)

	#placing the layouts
	list = room_list.duplicate()
	list.erase(preboss)
	list.erase([preboss[0]-1,preboss[1]])
	list.erase([map_center,map_center])
	
	world.start_room.populate(start_layout.instantiate())
	world.preboss_room.populate(preboss_layout.instantiate())
	
	list = room_list.duplicate()
	list.erase(preboss)
	list.erase([preboss[0]-1,preboss[1]])
	list.erase([map_center,map_center])
	
	for k in list:
		world.rooms.get(k).populate(layout[randi_range(0,layout.size()-1)].instantiate())
	#placing the orbs
	list = room_list.duplicate()
	list.erase(preboss)
	list.erase([preboss[0]-1,preboss[1]])
	list.erase([map_center,map_center])
		
	var key
	var room
	var orbi : Orb
	for i in range(0,3):
		key = list[randi_range(0,list.size()-1)]
		list.erase(key)
		room = world.rooms.get(key)
		orbi = orb.instantiate()
		orbi.position = room.orb_position
		room.add_child(orbi)
		world.connect_orb(orbi)
	
func verify_room_placements(k,map,list,room_list):
	var map_opened = false
	if k[1]-1 >= 0 && map[k[0]][k[1]-1] == 0:
		map_opened = true
		if place_room(k[0],k[1]-1,map,list) == 1:
			room_list.push_back([k[0],k[1]-1])
	if k[1]+1 <= map.size() && map[k[0]][k[1]+1] == 0:
		map_opened = true
		if place_room(k[0],k[1]+1,map,list) == 1:
			room_list.push_back([k[0],k[1]+1])
	if k[0]-1 >= 0 && map[k[0]-1][k[1]] == 0:
		map_opened = true
		if place_room(k[0]-1,k[1],map,list) == 1:
			room_list.push_back([k[0]-1,k[1]])
	if k[0]+1 <= map.size() && map[k[0]+1][k[1]] == 0:
		map_opened = true
		if place_room(k[0]+1,k[1],map,list) == 1:
			room_list.push_back([k[0]+1,k[1]])
	return map_opened
	
func place_room(x,y,map,list):
	if randf() < -float(list.size())/10.0+11.0/10.0:
		map[x][y] = 1
	else:
		map[x][y] = -1
	return map[x][y]
