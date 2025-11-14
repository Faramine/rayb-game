extends State

var parent : BossTentacleEnemy

@export var disable : State
@export var brace : State
@export var take_hit_state : State

@export var spawn_timer : Timer
@export var idle_timer : Timer

var spawned = false

func _ready() -> void:
	spawn_timer.wait_time = randi_range(1,5)
	spawn_timer.timeout.connect(_on_spawn_time)
	idle_timer.timeout.connect(_on_brace_time)

func apply_transition(transition) -> State:
	match transition:
		"disable":
			return disable
		"got_hit":
			return take_hit_state
		"brace":
			return brace
	return null

func enter():
	if spawned:
		idle_timer.start()
	else:
		spawn_timer.start()

func exit():
	spawn_timer.stop()
	idle_timer.stop()

func process(_delta: float) -> void:
	parent.look_at_player()

func _on_spawn_time():
	parent.animation_tree.spawn()
	spawned = true
	idle_timer.start()

func _on_brace_time():
	idle_timer.wait_time = randi_range(1,5)
	parent.animation_tree.bracing()
	fsm.apply_transition("brace")
	
