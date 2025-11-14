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
	pass

func exit():
	pass

func process(_delta: float) -> void:
	pass
