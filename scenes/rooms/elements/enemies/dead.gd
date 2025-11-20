extends State

var parent : BossTentacleEnemy

func apply_transition(_transition) -> State:
	return null

func enter():
	parent.animation_tree.die()
	parent.dead.emit()

func exit():
	pass

func process(_delta: float) -> void:
	pass
