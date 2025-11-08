extends State

var parent : RangedEnemy

@export var idle_state : State
@export var dead_state : State

@onready var health = $"../../Health"

func apply_transition(transition) -> State:
	match transition:
		"idle":
			return idle_state
		"dead":
			return dead_state
	return null

func process(_delta: float) -> void:
	if health.is_dead():
		fsm.apply_transition("dead")

func enter():
	health.take_damage(health.damage_cache)
	parent.animation_tree.trigger_hit()

func exit():
	pass
