extends State

var parent : RangedEnemy

@onready var laser_loading_timer : Timer = $LaserLoadingTimer

@onready var laser = $"../../Laser"

@export var take_hit_state : State
@export var laser_state : State

func _ready() -> void:
	laser_loading_timer.timeout.connect(on_loaded)

func apply_transition(transition) -> State:
	match transition:
		"take_hit":
			return take_hit_state
		"laser":
			return laser_state
	return null

func enter():
	laser.emiter_on()
	laser_loading_timer.start()

func exit():
	laser.emiter_off()
	laser_loading_timer.stop()

func process(delta: float) -> void:
	pass

func on_loaded():
	fsm.apply_transition("laser")
