class_name EnemyDummy
extends Enemy

var state = STATE_IDLE

const STATE_IDLE = 0
const STATE_FOLLOW = 1

func _process(delta):
	if not is_on_floor():
		velocity.y -= gravity
	if(state != STATE_IDLE):
		follow_player()
	move_and_slide()

#func _ready():
	#self.speed = 5

func follow_player():
	var distance = self.global_position.distance_to(self.player.global_position)
	var target_position = self.player.global_transform.origin + self.player.velocity * distance/30
	update_target_position(target_position)
	move_toward_target()

func on_room_activated():
	super.on_room_activated()
	await get_tree().create_timer(0.3).timeout
	if(room.is_active):
		state = STATE_FOLLOW

func on_room_deactivated():
	super.on_room_deactivated()
	state = STATE_IDLE
	
