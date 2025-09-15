class_name EnemyMelee
extends Enemy

@onready var state_machine = $StateMachine

var launch_origin : Vector3
var launch_target : Vector3

@onready var mesh = $Mesh
@onready var animation_player := $AnimationPlayer
var attack_range = 3

func _ready() -> void:
	player.godray_entered.connect(_on_player_enter_godray)
	player.godray_exited.connect(_on_player_exit_godray)
	state_machine.init(self)

func _process(delta):
	if not is_on_floor():
		velocity.y -= gravity
	state_machine.process(delta)
	move_and_slide()

#func _physics_process(delta: float) -> void:
	#if not is_on_floor():
		#velocity.y -= gravity
	#state_machine.process(delta)
	#move_and_slide()

func on_room_activated():
	super.on_room_activated()
	await get_tree().create_timer(0.3).timeout
	if(room.is_active):
		state_machine.apply_transition("activate")

func take_damage(damage):
	state_machine.apply_transition("got_hit")

func _on_player_enter_godray():
	state_machine.apply_transition("godray_entered")

func _on_player_exit_godray():
	state_machine.apply_transition("godray_exited")


func _on_state_changed(state_name) -> void:
	$SubViewport/Control/Label.text = state_name
