extends State

var parent : RangedEnemy

@onready var laser_timer : Timer = $LaserTimer

@onready var laser = $"../../Laser"

@export var take_hit_state : State
@export var idle_state : State

func _ready() -> void:
	laser_timer.timeout.connect(on_end)

func apply_transition(transition) -> State:
	match transition:
		"take_hit":
			return take_hit_state
		"idle":
			return idle_state
	return null

func enter():
	parent.animation_tree.laser_shoot()
	laser.emiter_on()
	laser.beam_on()
	laser_timer.start()

func exit():
	laser.emiter_off()
	laser.beam_off()
	laser_timer.stop()

func process(delta: float) -> void:
	pass

func on_end():
	fsm.apply_transition("idle")
	parent.animation_tree.idle()
