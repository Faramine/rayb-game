class_name RangedDecisionParameters
extends DecisionParameters

@export_category("Movement")
##Movement speed.
@export_range(0,10,0.1) var speed : float = 0
##noise movement speed.
@export var is_noise_movement : bool = false
##Enemy will run away from player if he is closer than this.
@export_range(0,10,0.1) var player_min_range : float = 2
##Enemy will go toward player if he is further than this.
@export_range(0,10,0.1) var player_max_range : float = 10
@export_category("Decision")

##Time between attacks
@export_range(0,10,0.1) var decision_duration : float = 1
##Arbitrary value of how much previous biais values are important
@export_range(0,10,0.1) var decision_memory : float = 0.1

@export_group("Base Biases")
##Arbitrary value of how much the enemy will favor the shockwave attack
@export_range(0,1,0.1) var shockwave_base_bias : float = 1.0
##Arbitrary value of how much the enemy will favor the laser attack
@export_range(0,1,0.1) var laser_base_bias : float = 1.0
##Arbitrary value of how much the enemy will favor the bullet attack
@export_range(0,1,0.1) var bullet_base_bias : float = 1.0

@export_group("Player Influence")
##Arbitrary value of how much the player will influence the shockwave attack bias
@export_range(0,1,0.1) var shockwave_player_bias : float = 1.0
##Arbitrary value of how much the player will influence the laser attack bias
@export_range(0,1,0.1) var laser_player_bias : float = 1.0
##Arbitrary value of how much the player will influence the bullet attack bias
@export_range(0,1,0.1) var bullet_player_bias : float = 1.0


@export_category("Attack")

@export_group("Shockwave")
##Shockwave range
@export_range(0,10,0.1) var shockwave_range : float = 1

@export_group("Laser")
##Laser duration
@export_range(0,10,0.1) var laser_duration : float = 1
##Laser rotation speed in turn per seconds
@export_range(0,1,0.01) var laser_rotation_speed : float = 1

@export_group("Bullet")
##Number of bullet shot per attack
@export_range(0,100,1) var bullet_amount : int = 1
##Number of bullet shot per attack
@export_range(0,10,0.1) var bullet_speed : float = 1
##Time between bullets
@export_range(0,10,0.1) var bullet_interval_duration : float = 1


@export_category("Affected_Nodes")

@export_group("States")

@export var idle_state : State
@export var bullet_state : State

@export_group("Timers")

@export var decision_timer : Timer
@export var laser_timer : Timer
@export var bullet_interval_timer : Timer

## Apply decision parameters chosen at start.
##
## Called on ready.
func apply_starting_parameters() -> void:
	apply_to_idle_state()
	apply_to_bullet_state()
	apply_to_decision_timer()
	apply_to_laser_timer()
	apply_to_bullet_interval_timer()

func apply_to_idle_state():
	idle_state.speed = speed
	idle_state.is_noise_movement = is_noise_movement
	idle_state.player_min_range = player_min_range
	idle_state.player_max_range = player_max_range
	idle_state.decision_memory = decision_memory
	idle_state.shockwave_base_bias = shockwave_base_bias
	idle_state.laser_base_bias = laser_base_bias
	idle_state.bullet_base_bias = bullet_base_bias
	idle_state.shockwave_player_bias = shockwave_player_bias
	idle_state.laser_player_bias = laser_player_bias
	idle_state.bullet_player_bias = bullet_player_bias
	idle_state.shockwave_range = shockwave_range

func apply_to_bullet_state():
	bullet_state.bullet_amount = bullet_amount
	bullet_state.bullet_speed = bullet_speed

func apply_to_decision_timer():
	decision_timer.wait_time = decision_duration
func apply_to_laser_timer():
	laser_timer.wait_time = laser_duration
func apply_to_bullet_interval_timer():
	bullet_interval_timer.wait_time = bullet_interval_duration
