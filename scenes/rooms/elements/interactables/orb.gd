class_name Orb
extends Node3D

var inv = false
var inv_timer = 0.0

var spawn_position
@onready var velocity = Vector3(0.0,0.0,0.0)

@onready var animationplayer = $AnimationPlayer

func _ready() -> void:
	spawn_position = position
	animationplayer.play("Orb_floating")

func _process(delta: float) -> void:
	position = position.lerp(spawn_position , delta) + velocity
	velocity = velocity.lerp(Vector3.ZERO,delta)
	inv_timer += delta
	if inv_timer >= 4.0:
		inv = false

func add_velocity(velocity : Vector3):
	self.velocity += velocity
	self.inv = true
	self.inv_timer = 0.0

func take_damage(damage):
	add_velocity(Vector3(0.1,0.0,0.1))
