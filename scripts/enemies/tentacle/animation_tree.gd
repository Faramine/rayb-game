extends AnimationTree

var activate = false
var brace = false
var hiting = false
var got_hit = false
var dead = false

func spawn():
	activate = true

func bracing():
	brace = true

func hit():
	hiting = true

func idle():
	brace = false
	hiting = false
	got_hit = false

func get_hit():
	got_hit = true

func die():
	dead = true
