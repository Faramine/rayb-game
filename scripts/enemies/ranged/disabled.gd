extends State

var parent : RangedEnemy

@export var idle_state : State

func apply_transition(transition) -> State:
	match transition:
		"activate":
			return idle_state
	return null
	
func enter():
	parent.animation_tree.idle()

func process(delta: float) -> void:
	pass
