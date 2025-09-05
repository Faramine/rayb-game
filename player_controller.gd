extends Node3D

var mouse = Vector2()
const DIST = 1000
var player
var cursor
var cursor_pos
var current_room

func _ready() -> void:
	player = get_node("Player")
	cursor = get_node("Cursor")
	
func _process(delta: float) -> void:
		if cursor_pos:
			cursor.visible = true
			cursor.target = cursor_pos
		else:
			cursor.visible = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse = event.position
		cursor_pos = get_mouse_world_pos(get_viewport().get_mouse_position())
	if event is InputEventMouseButton:
		if event.pressed == false and event.button_index == MOUSE_BUTTON_LEFT:
			if cursor_pos:
				player.dash(cursor_pos)
			
func get_mouse_world_pos(mouse: Vector2):
	var space = get_world_3d().direct_space_state
	var start = get_viewport().get_camera_3d().project_ray_origin(mouse)
	var end = get_viewport().get_camera_3d().project_position(mouse, DIST)
	var params = PhysicsRayQueryParameters3D.new()
	params.collision_mask = 2
	params.from = start
	params.to = end
	var result = space.intersect_ray(params)
	if !result.is_empty():
		if result.get("collider").owner == current_room:
			return result.get("position")
	return null


func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group("Camera_zone"):
		current_room = area.get_parent().get_parent()
