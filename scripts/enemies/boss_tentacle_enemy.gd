class_name BossTentacleEnemy
extends Enemy

##Class BossTentacle Ranged Enemies.
##
##This Enemy stays immobile and hit the player when close

#region Node_Tree_References
##[StateMachine] controlling the enemy's behavior.
@onready var state_machine : StateMachine = $StateMachine
##[Shockwave] Node used to handle the animation and the logique of the shockwave attack.
##[AnimationTree] of the enemy.
@onready var animation_tree : AnimationTree = $AnimationTree
##[AnimationTree] of the enemy.
@onready var health : Health = $Health
##[DecisionParameters] of the enemy.
#@onready var rdparam : RangedDecisionParameters = $DecisionParameters
##[DecisionParameters] of the enemy.
@onready var armature = $Armature
#endregion

var rotation_target = 0.0
#region Node_Tree_References
func _ready() -> void:
	player.godray_entered.connect(_on_player_enter_godray)
	player.godray_exited.connect(_on_player_exit_godray)
	player.dead.connect(_on_player_dead)
	state_machine.state_changed.connect(_on_state_changed)
	animation_tree.animation_started.connect(on_animation_started)
	animation_tree.animation_finished.connect(on_animation_ended)
	state_machine.init(self)
	#rdparam.apply_starting_parameters()
#endregion

func _process(delta: float) -> void:
	velocity = Vector3.ZERO
	state_machine.process(delta)
	velocity.y = 0
	rotation.y = rotate_toward(rotation.y,rotation_target,delta)
	move_and_slide()



#region Control_Methods
##Function handling the hurtbox behavior.
##
##Required by [HurtBox]
func take_damage(hitbox : HitBox):
	if hitbox.owner is Player:
		health.damage_cache = hitbox.damage
		state_machine.apply_transition("got_hit")

func move_away_from(target ,_speed, delta):
	var new_velocity = -(global_position.direction_to(target).normalized()) * _speed
	velocity = velocity.move_toward(new_velocity, delta * 100)

##Move the enemy toward its [member Enemy.target_node].
func move_toward_target(_speed, delta):
	var next_location = nav.get_next_path_position()
	var current_location = global_transform.origin
	var new_velocity = (next_location - current_location).normalized() * _speed
	velocity = velocity.move_toward(new_velocity, delta * 100)

func look_at_player():
	var flatened_pos = Vector2(global_position.x, global_position.z)
	var flatened_pos_player = Vector2(player.global_position.x, player.global_position.z)
	var dir = flatened_pos_player - flatened_pos
	rotation_target = atan2(dir.x,dir.y) + PI/2.0
	
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
	
func on_animation_started(animation_name):
	pass

func on_animation_ended(animation_name):
	if	(
		animation_name == "Slam-hit" or
		animation_name == "Hit"
		):
		state_machine.apply_transition("idle")
		print(animation_name)
	
#endregion
