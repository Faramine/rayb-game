@abstract class_name DecisionParameters extends Node
## Node handling the various parameters that affect a scene.
##
## One of the goal of using this node is to centralise parameters changes from the editor
## and over time.

@export var updating : bool = false

func _process(_delta: float) -> void:
	if updating and process_parameters():
		apply_processed_parameters()

## Apply decision parameters chosen at start.
##
## Should be called by the parent node _ready function.
@abstract func apply_starting_parameters() -> void

## Process decision parameters that may change over time.
##
## Return true if some parameters have changed.
func process_parameters() -> bool:
	return false

## Apply decision parameters that may change over time.
##
## Called when decision parameters have changed.
func apply_processed_parameters() -> void:
	pass
