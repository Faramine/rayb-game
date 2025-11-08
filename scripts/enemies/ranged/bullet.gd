extends State

var parent : RangedEnemy

@onready var bullet_interval_timer : Timer = $BulletIntervalTimer

@onready var laser = $"../../Laser"

@export var take_hit_state : State
@export var idle_state : State

var bullet_amount : int
var bullet_speed : float
@onready var n = 0

func _ready() -> void:
	bullet_interval_timer.timeout.connect(on_interval)

func apply_transition(transition) -> State:
	match transition:
		"got_hit":
			return take_hit_state
		"idle":
			return idle_state
	return null

func enter():
	parent.animation_tree.shoot_bullet()

func exit():
	bullet_interval_timer.stop()
	n = 0

func process(_delta: float) -> void:
	pass

func on_interval():
	if n < bullet_amount:
		n = n + 1
		var direction = parent.global_position.direction_to(parent.player.global_position)
		Bullet.create_bullet(parent.global_position,direction,parent.room,bullet_speed)
	if n >= bullet_amount:
		n = 0
		parent.animation_tree.stop_bullet()
	else:
		bullet_interval_timer.start()
