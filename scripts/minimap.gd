extends Control

@export var hide_mode = true

@export var mapelement : Control
@export var mapcontrol : Control

@onready var rooms = Dictionary()

var start
var pre
var boss

var target

var current_room = [0,0]
var map_size = 5

func change_room(room: Array):
	reveal_room(room)
	current_room = room
	target = Vector2()
	target.x = (current_room[1])*21 - mapcontrol.size.x/2 + 240
	target.y = -((current_room[0])*21 - mapcontrol.size.y/2) - 10
	var tween = create_tween()
	tween.tween_property(mapcontrol, "position", target, 0.5)
	tween.play()

func display_map(room_list: Array):
	var square
	for k in room_list:
		place_room(k,Color.GRAY, hide_mode)

func display_special_rooms(start:Array,pre:Array,boss:Array):
	self.pre = pre
	self.start = start
	self.boss = boss
	place_room(start,Color.GREEN, hide_mode)
	place_room(pre,Color.BLUE, hide_mode)
	place_room(boss,Color.RED, hide_mode)

func reveal_room(coords):
	var square = rooms.get(coords)
	square.visible = true
	if coords == start:
		square.color = Color.GREEN
	elif coords == pre:
		square.color = Color.BLUE
	elif coords == boss:
		square.color = Color.RED
	else:
		square.color = Color.GRAY
	if rooms.keys().has([coords[0],coords[1]+1]):
		soft_reveal([coords[0],coords[1]+1])
	if rooms.keys().has([coords[0],coords[1]-1]):
		soft_reveal([coords[0],coords[1]-1])
	if rooms.keys().has([coords[0]+1,coords[1]]):
		soft_reveal([coords[0]+1,coords[1]])
	if rooms.keys().has([coords[0]-1,coords[1]]):
		soft_reveal([coords[0]-1,coords[1]])
		
func soft_reveal(coords):
	var square = rooms.get(coords)
	if !square.visible:
		square.visible = true
		square.color = Color.DIM_GRAY

func place_room(coords:Array,color:Color, hide = false):
	var square
	square = ColorRect.new()
	square.color = color
	square.size.x = 20
	square.size.y = 20
	square.position.x = -coords[1] * 21
	square.position.y = coords[0] * 21
	square.visible = !hide
	rooms.set(coords,square)
	mapcontrol.add_child(square)
