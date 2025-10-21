class_name StateMachine
extends Node

##Basic implementation of a state machine
##
##Every states of the machine are to be added in the editor as a [class.State]

signal state_changed

@export var root_state : State
var current_state : State
var States : Array[State]

func init(parent: Node) -> void:
	for child in get_children():
		var state := child as State
		state.parent = parent
		state.fsm = self

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
	state_changed.emit(current_state.name)
	print(current_state.name)
