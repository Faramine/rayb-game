extends State

@export var chase_state : State
var parent : EnemyMelee

func apply_transition(transition) -> State:
	match transition:
		"activate":
			return chase_state
	return null

func enter():
	pass

func exit():
	pass

func process(delta: float) -> void:
	pass
