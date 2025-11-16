extends State

var parent : BossTentacleEnemy

@export var idle : State
@export var dead : State

func apply_transition(transition) -> State:
	match transition:
		"idle":
			return idle
		"dead":
			return dead
	return null

func enter():
	if parent.health.is_dead():
		apply_transition(dead)
	else :
		parent.animation_tree.get_hit()

func exit():
	parent.animation_tree.idle()

func process(_delta: float) -> void:
	pass
