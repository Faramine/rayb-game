extends State

var parent : RangedEnemy

@onready var bullet_loading_timer : Timer = $BulletLoadingTimer

@onready var laser = $"../../Laser"

@export var take_hit_state : State
@export var bullet_state : State

func _ready() -> void:
	parent.animation_tree.animation_started.connect(on_loaded)

func apply_transition(transition) -> State:
	match transition:
		"take_hit":
			return take_hit_state
		"bullet":
			return bullet_state
	return null

func enter():
	parent.animation_tree.bullet()
	bullet_loading_timer.start()

func exit():
	bullet_loading_timer.stop()

func process(delta: float) -> void:
	pass

func on_loaded(animation):
	if(animation == "bullet")
		fsm.apply_transition("bullet")
