extends State

var parent : RangedEnemy

func apply_transition(transition) -> State:
	return null

func enter():
	parent.dead.emit()
	
func exit():
	pass

func process(delta: float) -> void:
	pass
