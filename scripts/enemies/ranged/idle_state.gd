extends State

var parent : RangedEnemy

@export var disable : State
@export var take_hit_state : State
@export var prepare_sw_state : State
@export var prepare_l_state : State
@export var prepare_b_state : State

@onready var decision_timer : Timer = $DecisionTimer

func _ready() -> void:
	decision_timer.timeout.connect(on_decision)

func apply_transition(transition) -> State:
	match transition:
		"disable":
			return disable
		"got_hit":
			return take_hit_state
		"prepare_sw":
			return prepare_sw_state
		"prepare_l":
			return prepare_l_state
		"prepare_b":
			return prepare_b_state
	return null
	
func enter():
	decision_timer.start()
	
func exit():
	decision_timer.stop()

func process(delta: float) -> void:
	pass

func on_decision():
	match randi_range(0,2):
		0:
			fsm.apply_transition("prepare_sw")
		1:
			fsm.apply_transition("prepare_l")
		2:
			fsm.apply_transition("prepare_b")
