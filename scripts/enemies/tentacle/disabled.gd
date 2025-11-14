extends State

var parent : BossTentacleEnemy

@export var idle : State

func apply_transition(transition) -> State:
	match transition:
		"activate":
			return idle
	return null

func enter():
	pass

func exit():
	pass

func process(_delta: float) -> void:
	pass
