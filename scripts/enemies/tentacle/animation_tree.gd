extends AnimationTree

var activate = false
var brace = false
var hiting = false

func spawn():
	activate = true

func bracing():
	brace = true

func hit():
	hiting = true

func idle():
	brace = false
	hiting = false
