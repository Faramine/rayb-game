extends State

var parent : BossTentacleEnemy

@export var disable : State
@export var idle : State
@export var take_hit_state : State

func apply_transition(transition) -> State:
	match transition:
		"disable":
			return disable
		"got_hit":
			return take_hit_state
		"idle":
			return idle
	return null

func enter():
	pass

func exit():
	pass

func process(_delta: float) -> void:
	pass
