extends Control

@export var mapelement : Control
@export var mapcontrol : Control
var target

var current_room = [0,0]
var map_size = 5

func change_room(room: Array):
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
		place_room(k,Color.GRAY)

func display_special_rooms(start:Array,pre:Array,boss:Array):
	place_room(start,Color.GREEN)
	place_room(pre,Color.BLUE)
	place_room(boss,Color.RED)

func place_room(coords:Array,color:Color):
	var square
	square = ColorRect.new()
	square.color = color
	square.size.x = 20
	square.size.y = 20
	square.position.x = -coords[1] * 21
	square.position.y = coords[0] * 21
	mapcontrol.add_child(square)
