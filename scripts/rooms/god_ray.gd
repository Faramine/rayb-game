extends Node3D

@onready var animationplayer : AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	animationplayer.play("opening")
