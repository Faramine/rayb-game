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
		"got_hit":
			return take_hit_state
		"idle":
			return idle_state
	return null

func enter():
	parent.animation_tree.shoot_laser()

func exit():
	laser_timer.stop()
	on_end()

func process(delta: float) -> void:
	pass

func on_end():
	laser.turn_off()
	parent.animation_tree.stop_laser()
