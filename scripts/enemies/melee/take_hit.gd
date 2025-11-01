extends State

var parent : EnemyMelee

@export var chase_state : State
@export var dead_state : State

@onready var health = $"../../Health"

func apply_transition(transition) -> State:
	match transition:
		"hit_taken":
			return chase_state
		"dead":
			return dead_state
	return null

func enter():
	health.take_damage(health.damage_cache)
	parent.velocity = Vector3.ZERO
	parent.mesh.scale = Vector3.ONE
	$"../../AnimationPlayer".play("hit")

func exit():
	pass

func process(delta: float) -> void:
	if health.is_dead():
		fsm.apply_transition("dead")

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "hit":
		fsm.apply_transition("hit_taken")
