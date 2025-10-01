extends State

var parent : EnemyMelee

# Armature and animation nodes
@onready var armature = $Armature;
@onready var skeleton = $Armature/Skeleton3D;
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

func exit():
	pass

func process(delta: float) -> void:
	pass
