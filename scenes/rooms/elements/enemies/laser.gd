extends "res://laser.gd"

@onready var enemy : RangedEnemy = $".."

@onready var target : Vector3 = position

func _process(delta: float) -> void:
	super._process(delta)
	var adjusted_player_pos = enemy.player.position
	adjusted_player_pos.y = global_position.y
	target = lerp(target, adjusted_player_pos,delta)
	look_at(target)
