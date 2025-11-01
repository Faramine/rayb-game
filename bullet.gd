class_name Bullet
extends RigidBody3D

@onready var direction = Vector3(0,0,0)
@export_range(0.1,10,0.1) var speed = 1
static var scene = preload("res://scenes/rooms/elements/enemies/bullet.tscn")

func _ready() -> void:
	$LifeTime.timeout.connect(end)

func _process(delta: float) -> void:
	if move_and_collide(direction * delta * speed):
		end()

func start():
	$LifeTime.start()

func end():
	queue_free()



static func create_bullet(pos: Vector3,dir : Vector3, par : Node3D, sp : float = 5):
	var bullet = scene.instantiate()
	par.add_child(bullet)
	bullet.speed = sp
	bullet.global_position = pos
	dir.y = 0
	bullet.direction = dir
	bullet.start()
	return bullet
