class_name EnemyMelee
extends Enemy

@onready var state_machine = $StateMachine

var state = STATE_IDLE
const STATE_IDLE = 0
const STATE_FOLLOW = 1
const STATE_LOAD_ATTACK = 2
const STATE_LAUNCH_ATTACK = 3
const STATE_MISLED = 4

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

func _on_within_attack_range() -> void:
	state_machine.apply_transition("within_attack_range")

func _on_load_attack_end() -> void:
	state_machine.apply_transition("load_attack_end")

func _on_launch_attack_end() -> void:
	state_machine.apply_transition("launch_attack_end")
