class_name EnemyMelee
extends Enemy

##Class representing Melee Enemies.
##
##This Enemy goes toward the player and attacks.[br]
##If the player enters a god ray, the enemy enters idle state.

#region Node_Tree_References
##[StateMachine] controlling the enemy's behavior.
@onready var state_machine : StateMachine = $StateMachine

# Armature nodes
##Enemy's armature node, contains the [MeshInstance3D] and [Skeleton3D] of the enemy.
@onready var armature : Node3D = $Armature;
##[Skeleton3D] of the enemy.
@onready var skeleton : Skeleton3D = $Armature/Skeleton3D;
##[AnimationTree] of the enemy.
@onready var animationTree : AnimationTree = $AnimationTree;

#Debug Nodes
##Debug [MeshInstance3D]
@onready var mesh : MeshInstance3D = $Mesh
##Debug [AnimationPlayer]
@onready var animation_player : AnimationPlayer = $AnimationPlayer
#endregion

#region Members
##Launch attack starting position.
var launch_origin : Vector3
##Launch attack target position.
var launch_target : Vector3
##attack range
var attack_range : float = 3
#endregion

#region Node_Methods
func _ready() -> void:
	player.godray_entered.connect(_on_player_enter_godray)
	player.godray_exited.connect(_on_player_exit_godray)
	player.dead.connect(_on_player_dead)
	state_machine.init(self)

func _process(delta):
	if not is_on_floor():
		velocity.y -= gravity
	state_machine.process(delta)
	move_and_slide()
#endregion

#region Control_Methods
##Function handling the hurtbox behavior.
##
##Required by [HurtBox]
func take_damage(hitbox : HitBox):
	$Health.damage_cache = hitbox.damage
	state_machine.apply_transition("got_hit")

##Move the enemy toward its [member Enemy.target_node], defined in [Enemy].
func move_toward_target(speed, delta):
	super.move_toward_target(speed, delta);
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
	$SubViewport/Control/Label.text = state_name
#endregion
