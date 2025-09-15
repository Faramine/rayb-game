extends State

@export var load_attack_state : State
@export var misled_state : State
var parent : EnemyMelee

signal within_attack_range

func apply_transition(transition) -> State:
	match transition:
		"within_attack_range":
			return load_attack_state
		"godray_entered":
			return misled_state
	return null

func enter():
	pass

func exit():
	pass

func process(delta: float) -> void:
	follow_player(parent.speed)
	check_attack_range(parent.attack_range)

func follow_player(speed):
	var distance = parent.global_position.distance_to(parent.player.global_position)
	var target_position = parent.player.global_position + parent.player.velocity * distance/30
	parent.update_target_position(target_position)
	parent.move_toward_target(speed)
	
func check_attack_range(range):
	var distance = parent.global_position.distance_to(parent.player.global_position)
	if distance < range:
		within_attack_range.emit()
