extends AnimationPlayer

var dead = false
var blinking = false

func _ready() -> void:
	animation_started.connect(_on_animation_started)

func die():
	dead = true

func blink():
	blinking = true

func unblink():
	blinking = false

func _on_animation_started(animation_name):
	if animation_name == "open_up":
		unblink()
