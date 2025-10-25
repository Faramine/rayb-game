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

func change_room(room:Vector2i):
	reveal_room(room)
	current_room = room
	target = Vector2()
	target.x = (current_room.y)*21 - mapcontrol.size.x/2 + 240
	target.y = -((current_room.x)*21 - mapcontrol.size.y/2) - 10
	var tween = create_tween()
	tween.tween_property(mapcontrol, "position", target, 0.5)
	tween.play()

func display_map(room_list: Array):
	for k in room_list:
		place_room(k,Color.GRAY, hide_mode)

func display_special_rooms(startroom:Vector2i,preroom:Vector2i,bossroom:Vector2i):
	self.pre = preroom
	self.start = startroom
	self.boss = bossroom
	place_room(startroom,Color.GREEN, hide_mode)
	place_room(preroom,Color.BLUE, hide_mode)
	place_room(bossroom,Color.RED, hide_mode)

func reveal_room(coords:Vector2i):
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
	var direction = Vector2i.UP
	for i in 4:
		if rooms.keys().has(coords+direction):
			soft_reveal(coords+direction)
		direction = Vector2i(direction.y,-direction.x)
		
func soft_reveal(coords):
	var square = rooms.get(coords)
	if !square.visible:
		square.visible = true
		square.color = Color.DIM_GRAY

func place_room(coords:Vector2i,color:Color, hiden = false):
	var square
	square = ColorRect.new()
	square.color = color
	square.size.x = 20
	square.size.y = 20
	square.position.x = -coords.y * 21
	square.position.y = coords.x * 21
	square.visible = !hiden
	rooms.set(coords,square)
	mapcontrol.add_child(square)
