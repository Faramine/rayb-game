class_name Bullet
extends RigidBody3D

@onready var direction = Vector3(0,0,0)
@onready var speed = 1
static var scene = preload("res://scenes/rooms/elements/enemies/bullet.tscn")

func _process(delta: float) -> void:
	move_and_collide(direction * delta * speed)

static func create_bullet(pos: Vector3,dir : Vector3, par : Node3D, sp : float = 5):
	var bullet = scene.instantiate()
	par.add_child(bullet)
	bullet.speed = sp
	bullet.global_position = pos
	dir.y = 0
	bullet.direction = dir
	return bullet
