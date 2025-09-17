extends State

var parent : EnemyMelee

@export var chase_state : State

func apply_transition(transition) -> State:
	return null

func enter():
	parent.dead.emit()
	parent.velocity = Vector3.ZERO
	parent.mesh.scale = Vector3.ONE
	parent.add_collision_exception_with(parent.player)
	$"../../AnimationPlayer".play("dead")

func exit():
	pass

func process(delta: float) -> void:
	pass

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "dead":
		# queue free
		pass
