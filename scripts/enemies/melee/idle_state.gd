extends State

var parent : EnemyMelee

# Armature and animation nodes
@onready var animationTree = get_parent().get_parent().get_node("AnimationTree");

@export var chase_state : State
@export var take_hit_state : State
@export var dead_state : State

func apply_transition(transition) -> State:
	match transition:
		"activate":
			return chase_state
		"got_hit":
			return take_hit_state
		"dead":
			return dead_state
	return null

func enter():
	# Setting up the animation parameters for the animation tree
	animationTree["parameters/conditions/is_walking"] = false;
	animationTree["parameters/conditions/is_idle"] = true;
	animationTree["parameters/conditions/is_bracing"] = false;
	animationTree["parameters/conditions/is_slamming"] = false;
	parent.animationTree2.idle()

func exit():
	pass

func process(_delta: float) -> void:
	pass
