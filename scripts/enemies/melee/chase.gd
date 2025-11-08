extends State

var parent : EnemyMelee

# Armature and animation nodes
@onready var animationTree = get_parent().get_parent().get_node("AnimationTree");

@export var load_attack_state : State
@export var misled_state : State
@export var take_hit_state : State
@export var dead_state : State

func apply_transition(transition) -> State:
	match transition:
		"within_attack_range":
			return load_attack_state
		"godray_entered":
			return misled_state
		"got_hit":
			return take_hit_state
		"dead":
			return dead_state
	return null

func enter():
	# Setting up the animation parameters for the animation tree
	animationTree["parameters/conditions/is_walking"] = true;
	animationTree["parameters/conditions/is_idle"] = false;
	animationTree["parameters/conditions/is_bracing"] = false;
	animationTree["parameters/conditions/is_slamming"] = false;
	parent.animationTree2.walk()

	if parent.player.is_in_godray:
		fsm.apply_transition("godray_entered")

func exit():
	pass

func process(delta: float) -> void:
	follow_player(parent.speed, delta)
	check_attack_range(parent.attack_range)

func follow_player(speed, delta):
	var distance = parent.global_position.distance_to(parent.player.global_position)
	var target_position = parent.player.global_position + parent.player.velocity * distance/30
	
	parent.update_target_position(target_position)
	parent.move_toward_target(speed, delta)
	
func check_attack_range(_range):
	var distance = parent.global_position.distance_to(parent.player.global_position)
	if distance < _range:
		fsm.apply_transition("within_attack_range")
