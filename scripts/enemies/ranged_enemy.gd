class_name RangedEnemy
extends Enemy

@onready var state_machine : StateMachine = $StateMachine
@onready var shockwave = $"Shockwave"

func _ready() -> void:
	player.godray_entered.connect(_on_player_enter_godray)
	player.godray_exited.connect(_on_player_exit_godray)
	player.dead.connect(_on_player_dead)
	shockwave.shockwave_ended.connect(on_shockwave_end)
	state_machine.state_changed.connect(_on_state_changed)
	
	state_machine.init(self)
	
func on_room_activated():
	super.on_room_activated()
	await get_tree().create_timer(0.3).timeout
	if(room.is_active):
		state_machine.apply_transition("activate")

func take_damage(hitbox : HitBox):
	$Health.damage_cache = hitbox.damage
	state_machine.apply_transition("got_hit")
	print("hurt")

func _on_player_enter_godray():
	state_machine.apply_transition("godray_entered")

func _on_player_exit_godray():
	state_machine.apply_transition("godray_exited")

func _on_player_dead():
	print("player dead")
	state_machine.apply_transition("godray_entered")

func _on_state_changed(state_name) -> void:
	$Label3D.text = state_name

func on_shockwave_end():
	state_machine.apply_transition("idle")
