extends State

var parent : RangedEnemy

@export var take_hit_state : State
@export var shockwave_state : State

func apply_transition(transition) -> State:
	match transition:
		"take_hit":
			return take_hit_state
		"shockwave":
			return shockwave_state
	return null

func enter():
	parent.animation_tree.shockwave()

func exit():
	pass

func process(delta: float) -> void:
	pass
