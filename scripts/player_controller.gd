extends Node3D

@onready var dash_hint = $"../DashHint"
@onready var hitbox_hint = $"../HitBoxHint"
var mouse = Vector2()
const DIST = 1000
var player : Player
var cursor
var cursor_pos
var current_room

func _ready() -> void:
	player = $".."
	cursor = player.world.cursor
	
func _process(delta: float) -> void:
	var cpos
	if not cursor: 
		cursor = player.world.cursor
		return
	if cursor_pos:
		cursor.visible = true
		cursor.target = cursor_pos
		cpos = cursor_pos - player.global_position
		cpos.y = 0
		cpos = cpos.normalized() * 10
		dash_hint.global_position.x = player.global_position.x + cpos.x
		dash_hint.global_position.z = player.global_position.z + cpos.z
	else:
		cursor.visible = false

func move_vector() -> Vector3:
	var v_input = Input.get_vector("move_up", "move_down", "move_right", "move_left")
	return Vector3(v_input.x, 0, v_input.y)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse = event.position
		cursor_pos = get_mouse_world_pos(get_viewport().get_mouse_position())
	if event is InputEventMouseButton:
		mouse = event.position
		cursor_pos = get_mouse_world_pos(get_viewport().get_mouse_position())
		if event.pressed == true and event.button_index == MOUSE_BUTTON_LEFT:
			dash_hint.visible = true
			hitbox_hint.visible = true
		elif event.pressed == false and event.button_index == MOUSE_BUTTON_LEFT:
			dash_hint.visible = false
			hitbox_hint.visible = false
			if cursor_pos:
				player.dash(cursor_pos)

func get_mouse_world_pos(mouse: Vector2):
	var space = get_world_3d().direct_space_state
	var start = get_viewport().get_camera_3d().project_ray_origin(mouse)
	var end = get_viewport().get_camera_3d().project_position(mouse, DIST)
	var params = PhysicsRayQueryParameters3D.new()
	params.collision_mask = 128
	params.from = start
	params.to = end
	var result = space.intersect_ray(params)
	if !result.is_empty() && player.world.active_room != null:
		if result.get("collider").owner.coords == player.world.active_room.coords:
			return result.get("position")
	return null
