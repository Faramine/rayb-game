extends State

var parent : EnemyMelee

# Armature and animation nodes
@onready var animationTree = get_parent().get_parent().get_node("AnimationTree");

@export var chase_state : State
@export var misled_state : State

@onready var launch_attack_duration : Timer = $LaunchAttackDuration
@onready var impact_stun_duration : Timer = $ImpactStunDuration

func apply_transition(transition) -> State:
	match transition:
		"launch_attack_end":
			return chase_state
	return null

func enter():
		# Setting up the animation parameters for the animation tree
	animationTree["parameters/conditions/is_walking"] = false;
	animationTree["parameters/conditions/is_idle"] = false;
	animationTree["parameters/conditions/is_bracing"] = false;
	animationTree["parameters/conditions/is_slamming"] = true;
	parent.animationTree2.slam()
	
	var tween = create_tween()
	tween.tween_property(parent.mesh, "scale", Vector3.ONE, 0.05)
	launch_attack_duration.start()

func exit():
	launch_attack_duration.stop()
	impact_stun_duration.stop()

func process(_delta: float) -> void:
	#$Target.global_position = launch_target
	var weight = (launch_attack_duration.wait_time - launch_attack_duration.time_left)/launch_attack_duration.wait_time
	parent.global_position = lerp(parent.launch_origin, parent.launch_target, weight)

func _on_launch_attack_duration_timeout() -> void:
	$"../../AttackImpactParticles".restart()
	parent.room.world.camera.add_trauma(0.25)
	parent.velocity = Vector3.ZERO
	impact_stun_duration.start()
	$"../../HitBox/MeleeAttackCollision".disabled = false

func _on_impact_stun_duration_timeout() -> void:
	$"../../HitBox/MeleeAttackCollision".disabled = true
	fsm.apply_transition("launch_attack_end")
