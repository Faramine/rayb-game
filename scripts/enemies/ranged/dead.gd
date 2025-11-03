extends State

var parent : RangedEnemy

func apply_transition(transition) -> State:
	return null

func enter():
	parent.dead.emit()
	parent.animation_tree.dead = true
	
func exit():
	pass

func process(delta: float) -> void:
	pass
