extends State

var parent : EnemyMelee

@export var chase_state : State

@onready var launch_attack_duration = $LaunchAttackDuration

func apply_transition(transition) -> State:
	match transition:
		"hit_taken":
			return chase_state
	return null

func enter():
	parent.velocity = Vector3.ZERO
	parent.mesh.scale = Vector3.ONE
	$"../../AnimationPlayer".play("hit")

func exit():
	pass

func process(delta: float) -> void:
	pass

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hit":
		fsm.apply_transition("hit_taken")
