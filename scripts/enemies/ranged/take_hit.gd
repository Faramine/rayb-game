extends State

var parent : RangedEnemy

@export var idle_state : State
@export var dead_state : State

@onready var health = $"../../Health"

func apply_transition(transition) -> State:
	match transition:
		"hit_taken":
			return idle_state
		"dead":
			return dead_state
	return null

func enter():
	health.take_damage(health.damage_cache)
	if health.is_dead():
		fsm.apply_transition("dead")
	fsm.apply_transition("hit_taken")
	parent.animation_tree.take_hit()

func exit():
	pass

func process(delta: float) -> void:
	pass
