extends State

var parent : RangedEnemy

@onready var bullet_interval_timer : Timer = $BulletIntervalTimer

@onready var laser = $"../../Laser"

@export var take_hit_state : State
@export var idle_state : State

@export var number : int
@onready var n = 0

func _ready() -> void:
	bullet_interval_timer.timeout.connect(on_interval)

func apply_transition(transition) -> State:
	match transition:
		"take_hit":
			return take_hit_state
		"idle":
			return idle_state
	return null

func enter():
	bullet_interval_timer.start()

func exit():
	bullet_interval_timer.stop()

func process(delta: float) -> void:
	pass

func on_interval():
	if n < number:
		n = n + 1
		var direction = parent.global_position.direction_to(parent.player.global_position)
		Bullet.create_bullet(parent.global_position,direction,parent.room)
	if n >= number:
		n = 0
		fsm.apply_transition("idle")
	else:
		bullet_interval_timer.start()
