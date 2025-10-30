class_name MapGen
extends Node

#region old
#@export var map_size = 11
#@onready var preboss_layout = preload("res://scenes/rooms/layouts/base_preboss_room_layout.tscn")
#
#func generate_map(world : World):
	#var room_list = Array()
	#var map = Array()
	#var map_center = map_size/2
	#
	#map.resize(map_size)
	#for i in range(0,map_size):
		#map[i] = Array()
		#map[i].resize(map_size)
		#for j in range(0,map_size):
			#map[i][j] = 0
	#
	#var room_scene = load("res://scenes/rooms/room_base.tscn")
	#var list
	#var new_room : Room
	#var map_closed = false
	#var map_opened = false
	#
	#map[map_center][map_center] = 1
	#room_list.push_back([map_center,map_center])
	#
	#while !map_closed:
		#map_opened = false
		#list = room_list.duplicate()
		#for k in list:
			#map_opened = verify_room_placements(k,map,list,room_list)
		#
		#map_closed = !map_opened
		#
	##Placing the rooms
	#
	#for k in room_list:
		#new_room = room_scene.instantiate()
		#new_room.position.x = 26.5 * (k[0]-map_center)
		#new_room.position.z = 39 * (k[1]-map_center)
		#new_room.coords = k
		#new_room.set_world(world)
		#world.rooms.set(k, new_room)
		#add_child(new_room)
		#for r in room_list:
			#new_room.open_wall(r)
	#
	#world.start_room = world.rooms.get([map_center,map_center])
	#
	#var bossable_room = Array()
	#
	##placing the boss room
	#for k in room_list:
		#if k[0]-1 >= 0 && map[k[0]-1][k[1]] == -1:
			#bossable_room.push_back(k)
	#
	#var preboss = bossable_room[randi_range(0,bossable_room.size()-1)]
	#world.preboss_room = world.rooms.get(preboss)
	#room_list.push_back([preboss[0]-1,preboss[1]])
	#world.preboss_room.open_wall([preboss[0]-1,preboss[1]])
	#
	#new_room = room_scene.instantiate()
	#new_room.position.x = 26.5 * (preboss[0]-1-map_center)
	#new_room.position.z = 26.5 * (preboss[1]-map_center)
	#new_room.coords = [preboss[0]-1,preboss[1]]
	#new_room.set_world(world)
	#world.rooms.set([preboss[0]-1,preboss[1]], new_room)
	#world.boss_room = new_room
	#add_child(new_room)
	#new_room.open_wall(preboss)
#
	##placing the layouts
	#list = room_list.duplicate()
	#list.erase(preboss)
	#list.erase([preboss[0]-1,preboss[1]])
	#list.erase([map_center,map_center])
	#
	#world.start_room.populate(start_layout.instantiate())
	#world.preboss_room.populate(preboss_layout.instantiate())
	#
	#list = room_list.duplicate()
	#list.erase(preboss)
	#list.erase([preboss[0]-1,preboss[1]])
	#list.erase([map_center,map_center])
	#
	#for k in list:
		#world.rooms.get(k).populate(layout[randi_range(0,layout.size()-1)].instantiate())
	##placing the orbs
	#list = room_list.duplicate()
	#list.erase(preboss)
	#list.erase([preboss[0]-1,preboss[1]])
	#list.erase([map_center,map_center])
		#
	#var key
	#var room
	#var orbi : Orb
	#for i in range(0,3):
		#key = list[randi_range(0,list.size()-1)]
		#list.erase(key)
		#room = world.rooms.get(key)
		#orbi = orb.instantiate()
		#orbi.position = room.orb_position
		#room.add_child(orbi)
		#world.connect_orb(orbi)
	#
#func verify_room_placements(k,map,list,room_list):
	#var map_opened = false
	#if k[1]-1 >= 0 && map[k[0]][k[1]-1] == 0:
		#map_opened = true
		#if place_room(k[0],k[1]-1,map,list) == 1:
			#room_list.push_back([k[0],k[1]-1])
	#if k[1]+1 <= map.size() && map[k[0]][k[1]+1] == 0:
		#map_opened = true
		#if place_room(k[0],k[1]+1,map,list) == 1:
			#room_list.push_back([k[0],k[1]+1])
	#if k[0]-1 >= 0 && map[k[0]-1][k[1]] == 0:
		#map_opened = true
		#if place_room(k[0]-1,k[1],map,list) == 1:
			#room_list.push_back([k[0]-1,k[1]])
	#if k[0]+1 <= map.size() && map[k[0]+1][k[1]] == 0:
		#map_opened = true
		#if place_room(k[0]+1,k[1],map,list) == 1:
			#room_list.push_back([k[0]+1,k[1]])
	#return map_opened
	#
#func place_room(x,y,map,list):
	#if randf() < -float(list.size())/10.0+11.0/10.0:
		#map[x][y] = 1
	#else:
		#map[x][y] = -1
	#return map[x][y]
#endregion

const VOID = 0
const START_ROOM = 1
const BASE_ROOM = 2
const ORB_ROOM = 3
const PREBOSS_ROOM = 4
const BOSS_ROOM = 5

@export var _dimension : Vector2i = Vector2i(20,20)

@export var _critical_path_length : int = 10
@export var _branch_path_number : int = 4
@export var _branch_path_length : int = 4
@export var _orb_room_number : int = 3

var _start_room : Vector2i
var _preboss_room : Vector2i
var _boss_room : Vector2i

var _branch_candidates : Array
var _level_matrix : Array
var _room_list : Array
var _room_index : Dictionary

@onready var _world : World = $".."

@onready var _room_base = load("res://scenes/rooms/room_base.tscn")

@onready var _start_layouts : Array = [preload("res://scenes/rooms/layouts/start_room_layout_1.tscn")]
@onready var _base_layouts = [preload("res://scenes/rooms/layouts/base_room_layout.tscn"),
					preload("res://scenes/rooms/layouts/test_room_layout_1.tscn"),
					preload("res://scenes/rooms/layouts/test_room_layout_2.tscn")]
@onready var _orb_layouts = [preload("res://scenes/rooms/layouts/orb_room_layout.tscn")]
@onready var _preboss_layouts = [preload("res://scenes/rooms/layouts/base_preboss_room_layout.tscn")]

@onready var _orb = preload("res://scenes/rooms/elements/interactables/orb.tscn")

#region Level_Matrix_Generation_Methods
func _init_level_matrix():
	_level_matrix = Array()
	for x in _dimension.x:
		_level_matrix.append([])
		for y in _dimension.y:
			_level_matrix[x].append(VOID)
	_branch_candidates = Array()

func _place_start_room():
	_start_room = Vector2i(_dimension.x/2, _dimension.y/2)
	_level_matrix[_start_room.x][_start_room.y] = START_ROOM

func _generate_room_list():
	_room_list = Array()
	for x in _dimension.x:
		for y in _dimension.y:
			if (_level_matrix[x][y] != VOID):
				_room_list.append(Vector2i(x,y))

func _place_boss_room():
	var preboss_candidates : Array = Array()
	for room in _room_list:
		var room_up = room + Vector2i.LEFT
		if(room_up.x < _dimension.x and room_up.x >= 0
		and room_up.y < _dimension.y and room_up.y >= 0
		and _level_matrix[room_up.x][room_up.y] == VOID):
			preboss_candidates.append(room)
	_preboss_room = preboss_candidates[randi_range(0, preboss_candidates.size()-1)]
	_boss_room = _preboss_room + Vector2i.LEFT
	_level_matrix[_preboss_room.x][_preboss_room.y] = PREBOSS_ROOM
	_level_matrix[_boss_room.x][_boss_room.y] = BOSS_ROOM
	_room_list.append(_preboss_room)
	_room_list.append(_boss_room)

func _generate_path(current_room : Vector2i, length : int, border = 1) -> bool:
	if length == 0:
		return true
	var direction : Vector2i
	match randi_range(0,3):
		0:
			direction = Vector2i.UP
		1:
			direction = Vector2i.RIGHT
		2:
			direction = Vector2i.LEFT
		3:
			direction = Vector2i.DOWN
	for i in 4:
		if(current_room.x + direction.x < _dimension.x - border and current_room.x + direction.x >= border
		and current_room.y + direction.y < _dimension.y - border and current_room.y + direction.y >= border
		and _level_matrix[current_room.x + direction.x][current_room.y + direction.y] == VOID):
			current_room += direction
			_level_matrix[current_room.x][current_room.y] = BASE_ROOM
			_branch_candidates.append(current_room)
			if _generate_path(current_room, length - 1):
				return true
			else:
				_level_matrix[current_room.x][current_room.y] = VOID
				_branch_candidates.erase(current_room)
				current_room -= direction
		direction = Vector2i(direction.y, -direction.x)
	return false

func _trim_branch_candidates(border = 1):
	for room in _branch_candidates:
		var direction = Vector2i.UP
		var open = false
		for i in 4:
			var next_room = room + direction
			if(next_room.x < _dimension.x - border and next_room.x >= border
			and next_room.y < _dimension.y - border and next_room.y >= border
			and _level_matrix[next_room.x][next_room.y] == VOID):
				open = true
			direction = Vector2i(direction.y, -direction.x)
		if not open:
			_branch_candidates.erase(room)

func _generate_branches():
	_trim_branch_candidates()
	for i in _branch_path_number:
		var branch_start = _branch_candidates[randi_range(0,_branch_candidates.size()-1)]
		while not _generate_path(branch_start, _branch_path_length) and _branch_candidates.size() > 0:
			_branch_candidates.erase(branch_start)
			branch_start = _branch_candidates[randi_range(0,_branch_candidates.size()-1)]
		_trim_branch_candidates()

func _place_orb_rooms():
	for i in _orb_room_number:
		var orb_room = _room_list[randi_range(0,_room_list.size()-1)]
		while _level_matrix[orb_room.x][orb_room.y] != BASE_ROOM:
			orb_room = _room_list[randi_range(0,_room_list.size()-1)]
		_level_matrix[orb_room.x][orb_room.y] = ORB_ROOM
#endregion

func _generate_map():
	_generate_level_matrix()
	_instanciate_rooms()
	_update_world()

func _generate_level_matrix():
	_init_level_matrix()
	_place_start_room()
	_generate_path(_start_room, _critical_path_length)
	_generate_branches()
	_generate_room_list()
	_place_orb_rooms()
	_place_boss_room()

func _instanciate_rooms():
	_room_index = Dictionary()
	for room in _room_list:
		var room_instance : Room = _room_base.instantiate()
		room_instance.position.x = 26.5 * (room.x-_start_room.x)
		room_instance.position.z = 39 * (room.y-_start_room.y)
		room_instance.coords = room
		_world.add_child(room_instance)
		room_instance.set_world(_world)
		match _level_matrix[room.x][room.y]:
			START_ROOM:
				room_instance.populate(_start_layouts[randi_range(0,_start_layouts.size()-1)].instantiate())
			BASE_ROOM:
				room_instance.populate(_base_layouts[randi_range(0,_base_layouts.size()-1)].instantiate())
			ORB_ROOM:
				room_instance.populate(_base_layouts[randi_range(0,_orb_layouts.size()-1)].instantiate())
				var orb = _orb.instantiate()
				room_instance.add_child(orb)
				orb.position = room_instance.orb_position
				_world.connect_orb(orb)
			PREBOSS_ROOM:
				room_instance.populate(_preboss_layouts[randi_range(0,_preboss_layouts.size()-1)].instantiate())
		if _level_matrix[room.x][room.y] != BOSS_ROOM:
			for r in _room_list:
				if r != _boss_room:
					room_instance.open_wall(r)
		else:
			room_instance.open_wall(_preboss_room)
		if _level_matrix[room.x][room.y] == PREBOSS_ROOM:
			room_instance.open_wall(_boss_room)
		_room_index.set(room,room_instance)

func _update_world():
	_world.rooms = _room_index
	_world.start_room = _room_index.get(_start_room)
	_world.preboss_room = _room_index.get(_preboss_room)
	_world.boss_room = _room_index.get(_boss_room)

func _print_layer_matrix():
	print("--------------")
	for l in _level_matrix:
		print(l)
