extends State

var parent : RangedEnemy

@onready var shockwave = $"../../Shockwave"
@export var take_hit_state : State
@export var idle_state : State

func apply_transition(transition) -> State:
	match transition:
		"take_hit":
			return take_hit_state
		"idle":
			return idle_state
	return null

func enter():
	shockwave.launch()

func exit():
	pass

func process(delta: float) -> void:
	pass
