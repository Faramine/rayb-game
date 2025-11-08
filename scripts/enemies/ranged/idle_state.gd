extends State

var parent : RangedEnemy

@export var disable : State
@export var take_hit_state : State
@export var shockwave_state : State
@export var laser_state : State
@export var bullet_state : State

var speed : float = 0
var is_noise_movement : bool
var player_min_range : float = 0
var player_max_range : float = 50

##Arbitrary value of how much previous biais values are important
var decision_memory : float = 0.1

##Arbitrary value of how much the enemy will favor the shockwave attack
var shockwave_base_bias : float = 1.0
##Arbitrary value of how much the enemy will favor the laser attack
var laser_base_bias : float = 1.0
##Arbitrary value of how much the enemy will favor the bullet attack
var bullet_base_bias : float = 1.0

##Arbitrary value of how much the player will influence the shockwave attack bias
var shockwave_player_bias : float = 1.0
##Arbitrary value of how much the player will influence the laser attack bias
var laser_player_bias : float = 1.0
##Arbitrary value of how much the player will influence the bullet attack bias
var bullet_player_bias : float = 1.0

##Arbitrary value of how much the enemy will favor the shockwave attack at this instant
var shockwave_bias : float = 1.0
##Arbitrary value of how much the enemy will favor the laser attack at this instant
var laser_bias : float = 1.0
##Arbitrary value of how much the enemy will favor the bullet attack at this instant
var bullet_bias : float = 1.0

##Shockwave range
var shockwave_range : float = 1

@onready var decision_timer : Timer = $DecisionTimer
@onready var noise_mouvement_timer : Timer = $NoiseMovementTimer

var noise_mouvement : Vector3 = Vector3.ZERO

func _ready() -> void:
	decision_timer.timeout.connect(on_decision)
	noise_mouvement_timer.timeout.connect(on_noise)

func apply_transition(transition) -> State:
	match transition:
		"disable":
			return disable
		"got_hit":
			return take_hit_state
		"shockwave":
			return shockwave_state
		"laser":
			return laser_state
		"bullet":
			return bullet_state
	return null
	
func enter():
	decision_timer.start()
	noise_mouvement_timer.start()
	
func exit():
	decision_timer.stop()
	noise_mouvement_timer.stop()

func process(delta: float) -> void:
	move(delta)
	update_bias_attack()

func move(delta):
	var distance = parent.global_position.distance_to(parent.player.global_position)
	if distance > player_max_range:
		var target_position = parent.player.global_position
	
		parent.update_target_position(target_position)
		parent.move_toward_target(speed, delta)
	elif distance < player_min_range:
		parent.move_away_from(parent.player.global_position , speed, delta)
	if is_noise_movement:
		parent.velocity += noise_mouvement * speed * 10 * delta

func on_decision():
	print(shockwave_bias, " ",laser_bias, " ",bullet_bias)
	match decide():
		0:
			fsm.apply_transition("shockwave")
		1:
			fsm.apply_transition("laser")
		2:
			fsm.apply_transition("bullet")

func on_noise():
	noise_mouvement = (
		Vector3(randf(),0,randf()).normalized() 
		if noise_mouvement == Vector3.ZERO
		else Vector3.ZERO
	)
	noise_mouvement_timer.start((randf()*2.0+0.1))

func decide() -> int:
	update_bias_attack()
	var total = shockwave_bias + laser_bias + bullet_bias
	var random = randf() * total
	if random < shockwave_bias:
		return 0
	elif random < shockwave_bias + laser_bias:
		return 1
	else:
		return 2

func update_bias_attack():
	var _shockwave_bias = shockwave_base_bias
	var _laser_bias = laser_base_bias
	var _bullet_bias = bullet_base_bias
	
	var distance = parent.global_position.distance_to(parent.player.global_position)
	var next_distance = parent.global_position.distance_to(
		parent.player.global_position + parent.player.velocity * 0.016
		)
	var is_aproaching = (distance > next_distance)
		
	_shockwave_bias *= shockwave_player_bias * (
		(2.0 if distance < shockwave_range else 0.1) *
		(1.0 if is_aproaching else 0.1)
	)
	
	_bullet_bias *= bullet_player_bias * (
		(1.0 if distance >= shockwave_range else 0.1)
	)
	
	_laser_bias *= bullet_player_bias * (
		(1.0 if distance > player_max_range else 0.1) 
	)
	
	shockwave_bias = (decision_memory * shockwave_bias + _shockwave_bias) / (decision_memory + 1)
	laser_bias = (decision_memory * laser_bias + _laser_bias) / (decision_memory + 1)
	bullet_bias = (decision_memory * bullet_bias + _bullet_bias) / (decision_memory + 1)
	
