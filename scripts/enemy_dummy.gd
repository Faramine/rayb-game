class_name EnemyDummy
extends Enemy

var state = STATE_IDLE
const STATE_IDLE = 0
const STATE_FOLLOW = 1
const STATE_LOAD_ATTACK = 2
const STATE_LAUNCH_ATTACK = 3

var launch_origin : Vector3
var launch_target : Vector3

func _process(delta):
	if not is_on_floor():
		velocity.y -= gravity
	if(state == STATE_FOLLOW):
		follow_player(speed)
		check_attack_range()
	if(state == STATE_LOAD_ATTACK):
		$Target.global_position = launch_target
		pass
	if(state == STATE_LAUNCH_ATTACK):
		$Target.global_position = launch_target
		var weight = ($LaunchAttackDuration.wait_time - $LaunchAttackDuration.time_left)/$LaunchAttackDuration.wait_time
		global_position = lerp(launch_origin, launch_target, weight)
	move_and_slide()

#func _ready():
	#self.speed = 5

func follow_player(speed):
	var distance = self.global_position.distance_to(self.player.global_position)
	var target_position = self.player.global_position + self.player.velocity * distance/30
	update_target_position(target_position)
	move_toward_target(speed)

func check_attack_range():
	var distance = self.global_position.distance_to(self.player.global_position)
	if distance < 3:
		change_state(STATE_LOAD_ATTACK)
		load_attack()

func load_attack():
	$Target/MeshInstance3D.get_active_material(0).albedo_color = Color.RED
	launch_origin = global_position
	launch_target = player.global_position
	if( player.velocity.length_squared() > 1 ): launch_target += player.velocity.normalized() * 3
	velocity = Vector3.ZERO
	$LoadAttackTimer.start()
	var tween = create_tween()
	tween.tween_property($Mesh, "scale", Vector3(1.5,1.5,1.5), $LoadAttackTimer.wait_time)

func launch_attack():
	var tween = create_tween()
	tween.tween_property($Mesh, "scale", Vector3.ONE, 0.05)
	change_state(STATE_LAUNCH_ATTACK)
	$LaunchAttackDuration.start()

func on_room_activated():
	super.on_room_activated()
	await get_tree().create_timer(0.3).timeout
	if(room.is_active):
		change_state(STATE_FOLLOW)

func on_room_deactivated():
	super.on_room_deactivated()
	change_state(STATE_IDLE)
	$LaunchAttackDuration.stop()
	$LoadAttackTimer.stop()
	$Mesh.scale = Vector3.ONE

func _on_load_attack_timer_timeout() -> void:
	launch_attack()

func _on_launch_attack_duration_timeout() -> void:
	$AttackImpactParticles.restart()
	room.world.camera.add_trauma(0.25)
	velocity = Vector3.ZERO
	change_state(STATE_IDLE)
	await get_tree().create_timer(0.3).timeout
	change_state(STATE_FOLLOW)
	$Target/MeshInstance3D.get_active_material(0).albedo_color = Color.YELLOW

func change_state(state):
	self.state = state
	
