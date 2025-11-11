extends State

var parent : EnemyMelee

# Armature and animation nodes
@onready var animationTree = get_parent().get_parent().get_node("AnimationTree");

@export var chase_state : State

func apply_transition(transition) -> State:
	match transition:
		"godray_exited":
			return chase_state
	return null

func enter():
	animationTree["parameters/conditions/is_walking"] = false;
	animationTree["parameters/conditions/is_idle"] = true;
	animationTree["parameters/conditions/is_bracing"] = false;
	animationTree["parameters/conditions/is_slamming"] = false;
	parent.animationTree2.idle()
	parent.animationTree2.slam()

func exit():
	pass

func process(delta: float) -> void:
	parent.update_target_position(parent.spawn_point)
	parent.move_toward_target(parent.speed, delta)
