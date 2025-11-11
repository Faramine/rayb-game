extends State

var parent : RangedEnemy

@onready var shockwave = $"../../Shockwave"
@export var take_hit_state : State
@export var idle_state : State

func apply_transition(transition) -> State:
	match transition:
		"got_hit":
			return take_hit_state
		"idle":
			return idle_state
	return null

func enter():
	parent.animation_tree.shoot_shockwave()

func exit():
	pass

func process(_delta: float) -> void:
	pass
