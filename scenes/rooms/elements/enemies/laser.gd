extends "res://laser.gd"

@onready var enemy : RangedEnemy = $".."

@onready var target : Vector3 = position

func _process(delta: float) -> void:
	super._process(delta)
	var adjusted_player_pos = enemy.player.position
	adjusted_player_pos.y = global_position.y
	target = lerp(target, global_position.direction_to(adjusted_player_pos),delta)
	position = target.normalized()
	look_at(enemy.to_global(position*2))
	rotation_degrees.x = 90
