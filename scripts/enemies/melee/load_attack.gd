extends State

@onready var load_attack_timer : Timer = $LoadAttackTimer
@export var launch_attack_state : State
var parent : EnemyMelee

signal load_attack_end

func apply_transition(transition) -> State:
	match transition:
		"load_attack_end":
			return launch_attack_state
	return null

func enter():
	#$Target/MeshInstance3D.get_active_material(0).albedo_color = Color.RED
	parent.launch_origin = parent.global_position
	parent.launch_target = parent.player.global_position
	if( parent.player.velocity.length_squared() > 1 ): parent.launch_target += parent.player.velocity.normalized() * 3
	parent.velocity = Vector3.ZERO
	load_attack_timer.start()
	var tween = create_tween()
	tween.tween_property(parent.mesh, "scale", Vector3(1.5,1.5,1.5), load_attack_timer.wait_time)

func exit():
	load_attack_timer.stop()

func process(delta: float) -> void:
	#$Target.global_position = launch_target
	pass

func _on_load_attack_timer_timeout() -> void:
	load_attack_end.emit()
