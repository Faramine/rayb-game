class_name RangedEnemy
extends Enemy

##Class representing Ranged Enemies.
##
##This Enemy stays immobile and cast various ranged attack on the player.[br]
##If the player enters a god ray, the enemy enters idle state.

#region Node_Tree_References
##[StateMachine] controlling the enemy's behavior.
@onready var state_machine : StateMachine = $StateMachine
##[Shockwave] Node used to handle the animation and the logique of the shockwave attack.
@onready var shockwave : Shockwave = $Shockwave
##[Area3D] Representing the trigger for the shockwave.
@onready var shockwave_zone : Area3D = $ShockwaveTrigger
##[AnimationTree] of the enemy.
@onready var animation_tree : AnimationTree = $AnimationTree
##[AnimationTree] of the enemy.
@onready var health : Health = $Health
#endregion

#region Node_Tree_References
func _ready() -> void:
	player.godray_entered.connect(_on_player_enter_godray)
	player.godray_exited.connect(_on_player_exit_godray)
	player.dead.connect(_on_player_dead)
	shockwave.shockwave_ended.connect(on_shockwave_end)
	#state_machine.state_changed.connect(_on_state_changed)
	animation_tree.animation_started.connect(_on_state_changed)
	shockwave_zone.area_entered.connect(on_shockwave_range)
	state_machine.init(self)
#endregion

#region Control_Methods
##Function handling the hurtbox behavior.
##
##Required by [HurtBox]
func take_damage(hitbox : HitBox):
	health.damage_cache = hitbox.damage
	state_machine.apply_transition("got_hit")
	print("hurt")
#endregion

#region Signal_Handlers
##Called upon when the room get activated.
func on_room_activated():
	super.on_room_activated()
	await get_tree().create_timer(0.3).timeout
	if(room.is_active):
		state_machine.apply_transition("activate")
		
##Called upon when the player enter a godray.
func _on_player_enter_godray():
	state_machine.apply_transition("godray_entered")
	
##Called upon when the player exit a godray.
func _on_player_exit_godray():
	state_machine.apply_transition("godray_exited")
	
##Called upon when the player dies.
func _on_player_dead():
	print("player dead")
	state_machine.apply_transition("godray_entered")
	
##Called upon when the state machine changes state, used for debug.
func _on_state_changed(state_name) -> void:
	$Label3D.text = state_name
	
##Called upon when the player enter the range of the shockwave.
func on_shockwave_range(area3d: Area3D):
	if area3d.is_in_group("Player"):
		state_machine.apply_transition("shockwave")
		
##Called upon when the shockwave animation is over.
func on_shockwave_end():
	state_machine.apply_transition("idle")
#endregion
