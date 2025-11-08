extends State

var parent : EnemyMelee

@export var chase_state : State

func apply_transition(_transition) -> State:
	return null

func enter():
	parent.dead.emit()
	parent.velocity = Vector3.ZERO
	parent.mesh.scale = Vector3.ONE
	parent.add_collision_exception_with(parent.player)
	$"../../AnimationPlayer".play("dead")
	parent.remove_child($"../../BodyHitBox")
	parent.animationTree2.death()
	
func exit():
	pass

func process(_delta: float) -> void:
	pass

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "dead":
		# queue free
		pass
