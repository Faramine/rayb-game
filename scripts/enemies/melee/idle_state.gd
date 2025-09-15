extends State

var parent : EnemyMelee

@export var chase_state : State
@export var take_hit_state : State

func apply_transition(transition) -> State:
	match transition:
		"activate":
			return chase_state
		"got_hit":
			return take_hit_state
	return null

func enter():
	pass

func exit():
	pass

func process(delta: float) -> void:
	pass
