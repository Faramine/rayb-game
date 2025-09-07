extends Control

var target

var current_room = [0,0]
var map_size = 5

func change_room(room: Array):
	current_room = room
	target = Vector2()
	target.x = (current_room[1])*21 - size.x/2 + 30
	target.y = -((current_room[0])*21 - size.y/2) - 10
	var tween = create_tween()
	tween.tween_property(self, "position", target, 0.5)
	tween.play()
	

func display_map(map: Array):
	var square
	map_size = map.size()
	for i in map_size:
		for j in map_size:
			if map[i][map_size-1-j] == 1:
				square = ColorRect.new()
				square.color = Color.GRAY
				square.size.x = 20
				square.size.y = 20
				square.position.x = (j) * 21
				square.position.y = (i) * 21
				add_child(square)
