extends State

var parent : EnemyMelee

@export var chase_state : State

@onready var launch_attack_duration = $LaunchAttackDuration

func apply_transition(transition) -> State:
	match transition:
		"godray_exited":
			return chase_state
	return null

func enter():
	pass

func exit():
	pass

func process(delta: float) -> void:
	parent.update_target_position(parent.spawn_point)
	parent.move_toward_target(parent.speed, delta)
