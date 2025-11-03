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
##[AnimationTree] of the enemy.
@onready var animation_tree : AnimationTree = $AnimationTree
##[AnimationTree] of the enemy.
@onready var health : Health = $Health
##[DecisionParameters] of the enemy.
@onready var rdparam : RangedDecisionParameters = $DecisionParameters
##[DecisionParameters] of the enemy.
@onready var laser : Laser = $Laser
@onready var armature = $Armature
#endregion

var laser_rotation : float =  0

#region Node_Tree_References
func _ready() -> void:
	player.godray_entered.connect(_on_player_enter_godray)
	player.godray_exited.connect(_on_player_exit_godray)
	player.dead.connect(_on_player_dead)
	state_machine.state_changed.connect(_on_state_changed)
	animation_tree.animation_started.connect(on_animation_started)
	animation_tree.animation_finished.connect(on_animation_ended)
	state_machine.init(self)
	rdparam.apply_starting_parameters()
#endregion

func _process(delta: float) -> void:
	velocity = Vector3.ZERO
	state_machine.process(delta)
	velocity.y = 0
	armature.rotation_degrees.z = lerp(armature.rotation_degrees.z, laser_rotation, delta * 2)
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
	
func on_animation_ended(animation_name):
	if	(
		animation_name == "bullet_stop" or 
		animation_name == "shockwave_slam" or 
		animation_name == "laser_stop" or
		animation_name == "hit"
	):
		laser_rotation = 0
		state_machine.apply_transition("idle")
	if animation_name == "laser_windup":
		laser.turn_on()
		$StateMachine/Laser/LaserTimer.start()
	if animation_name == "bullet_start":
		$StateMachine/Bullet.on_interval()

func on_animation_started(animation_name):
	if animation_name == "shockwave_slam":
		animation_tree.stop_shockwave()
		shockwave.launch()
	if animation_name == "laser_windup":
		laser_rotation = 45
	if animation_name == "hit":
		animation_tree.stop_hit()
	
#endregion
