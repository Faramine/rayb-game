class_name MapGen
extends Node

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
@onready var _orb = preload("res://scenes/rooms/elements/interactables/orb.tscn")

@onready var _start_layouts : Array = [preload("res://scenes/rooms/layouts/start_room_layout_1.tscn")]
@onready var _base_layouts : Array = [
	preload("res://scenes/rooms/layouts/base_room_layout.tscn"),
	preload("res://scenes/rooms/layouts/test_room_layout_1.tscn"),
	preload("res://scenes/rooms/layouts/test_room_layout_2.tscn")
	]
@onready var _preboss_layouts : Array = [
	preload("res://scenes/rooms/layouts/base_preboss_room_layout.tscn")
	]
@onready var _orbs_layouts : Array = [
	preload("res://scenes/rooms/layouts/orb_room_layout.tscn")
	]
@onready var _boss_layouts : Array = [
	preload("res://scenes/rooms/layouts/base_preboss_room_layout.tscn")
	]

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
	if DebugTools.debug:
		_generate_debug_level_matrix()
	else:
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

func _generate_debug_level_matrix():
	_init_level_matrix()
	_place_debug_start_room()
	_place_debug_rooms()

func _place_debug_start_room():
	_start_room = Vector2i(0,0)
	_level_matrix[_start_room.x][_start_room.y] = START_ROOM

func _place_debug_rooms():
	for x in range(1,_dimension.x):
		for y in range(1,_dimension.y):
			_level_matrix[x][y] = BASE_ROOM
	_level_matrix[0][1] = ORB_ROOM
	_level_matrix[0][2] = ORB_ROOM
	_level_matrix[0][3] = ORB_ROOM
	_preboss_room = Vector2i(0,4)
	_level_matrix[0][4] = PREBOSS_ROOM
	_boss_room = Vector2i(0,5)
	_level_matrix[0][5] = BOSS_ROOM
	_generate_room_list()
	for room in _room_list:
		var room_instance : Room = _room_base.instantiate()
		room_instance.position.x = 26.5 * (room.x-_start_room.x)
		room_instance.position.z = 39 * (room.y-_start_room.y)
		room_instance.coords = room
		_world.add_child(room_instance)
		room_instance.set_world(_world)
		match _level_matrix[room.x][room.y]:
			START_ROOM:
				room_instance.populate(_start_layouts[0].instantiate())
			BASE_ROOM:
				room_instance.populate(_base_layouts[
					((room.x - 1) + (room.y - 1) * (_dimension.y - 1))% _base_layouts.size()
					].instantiate())
			ORB_ROOM:
				room_instance.populate(_orbs_layouts[room.x % _orbs_layouts.size()].instantiate())
				var orb = _orb.instantiate()
				room_instance.add_child(orb)
				orb.position = room_instance.orb_position
				_world.connect_orb(orb)
			PREBOSS_ROOM:
				room_instance.populate(_preboss_layouts[0].instantiate())
		room_instance.open_wall(room+Vector2i.UP)
		room_instance.open_wall(room+Vector2i.DOWN)
		room_instance.open_wall(room+Vector2i.LEFT)
		room_instance.open_wall(room+Vector2i.RIGHT)
		_room_index.set(room,room_instance)
	

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
				room_instance.populate(_base_layouts[randi_range(0,_base_layouts.size()-1)].instantiate())
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
