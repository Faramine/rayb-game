class_name Orb
extends Node3D

var spawn_position;

@onready var animationplayer = $AnimationPlayer

func _ready() -> void:
	spawn_position = position
	animationplayer.play("Orb_floating")

func _process(delta: float) -> void:
	position = position.lerp(spawn_position, delta)
