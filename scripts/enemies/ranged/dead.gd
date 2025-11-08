extends State

var parent : RangedEnemy

func apply_transition(_transition) -> State:
	return null

func enter():
	parent.dead.emit()
	parent.animation_tree.death()
	
func exit():
	pass

func process(_delta: float) -> void:
	pass
