extends State

var parent : BossTentacleEnemy

@export var disable : State
@export var idle : State
@export var take_hit_state : State

@export var brace_trigger : Area3D
@export var brace_timer : Timer

var timer = false

func _ready() -> void:
	brace_trigger.area_entered.connect(_on_entered)
	brace_trigger.area_exited.connect(_on_exited)
	brace_timer.timeout.connect(_on_brace_idle)

func apply_transition(transition) -> State:
	match transition:
		"disable":
			return disable
		"got_hit":
			return take_hit_state
		"idle":
			return idle
	return null

func enter():
	brace_timer.start()

func exit():
	brace_timer.stop()
	timer = false

func process(_delta: float) -> void:
	parent.look_at_player()

func _on_brace_idle():
	parent.animation_tree.hit()
	timer = true

func _on_entered(area : Area3D):
	if area and area.is_in_group("Player"):
		if not timer:
			parent.animation_tree.hit()

func _on_exited(area : Area3D):
	if area and area.is_in_group("Player"):
		if not timer:
			parent.animation_tree.bracing()
