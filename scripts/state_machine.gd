class_name StateMachine
extends Node

@export var root_state : State
var current_state : State
var States : Array[State]

func init(parent: Node) -> void:
	for child in get_children():
		child.parent = parent

func _ready() -> void:
	current_state = root_state
	root_state.enter()

func process(delta: float) -> void:
	current_state.process(delta)

func apply_transition(transition):
	var new_state = current_state.apply_transition(transition)
	if new_state == null: return
	current_state.exit()
	current_state = new_state
	current_state.enter()
