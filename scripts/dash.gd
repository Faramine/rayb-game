class_name DashAbility
extends Node3D

@onready var player : Player = $".."
@onready var dash_cooldown : Timer = $DashCooldown

var is_dashing = false
var dash_speed = 150
var dash_time = 0
var dash_target_pos = Vector3()

func dash(dash_target_pos: Vector3):
	if dash_cooldown.is_stopped():
		is_dashing = true
		dash_target_pos.y = 0
		self.dash_target_pos = dash_target_pos
		$DashParticles.global_position = player.global_position
		$DashParticles.restart()
		$"../Armature/Skeleton3D/Cylinder_002".get_active_material(0).emission = Color.from_rgba8(100,100,100)
		player.world.camera.add_trauma(0.25)
	
func process_dash(delta):
	dash_time += delta
	dash_target_pos.y = player.position.y
	player.animationTree["parameters/conditions/is_dashing"] = true;
	if (player.position-dash_target_pos).length() < 0.5 || dash_time >0.3:
		# Si le dash est fini
		is_dashing = false
		dash_time = 0
		player.velocity = Vector3.ZERO
		player.animationTree["parameters/conditions/is_dashing"] = false;
		end_dash_juice()
	else:
		var dash_direction = (dash_target_pos - player.position).normalized();
		player.armature.rotation.y = lerp_angle(player.armature.rotation.y,
		 dash_direction.signed_angle_to(Vector3(0.0,0.0,1.0),Vector3(0.0,-1.0,0.0)), player.lerp_smoothstep);
		player.velocity = dash_direction * dash_speed;

func end_dash_juice():
	dash_cooldown.start()
	$"../OmniLight3D".light_energy = 0
	var tween = create_tween()
	tween.set_ease(tween.EASE_OUT)
	tween.tween_property($"../OmniLight3D", "light_energy", 1, dash_cooldown.wait_time)
	tween.play()
	await get_tree().create_timer(dash_cooldown.wait_time - $DashRecoverParticles.lifetime - 0.25).timeout
	$DashRecoverParticles.restart()
	var tween_cape = create_tween()
	tween_cape.set_ease(tween.EASE_OUT)
	tween_cape.tween_property($"../Armature/Skeleton3D/Cylinder_002".get_active_material(0),
	 "emission", Color.WHITE, 0.5)
	tween_cape.play()

func recover_dash_juice():
	$"../Armature/Skeleton3D/Cylinder_002".get_active_material(0).emission = Color.WHITE
	var tween = create_tween()
	tween.tween_property($"../OmniLight3D", "light_energy", 30, 0.05)
	tween.parallel().tween_property($"../OmniLight3D", "omni_range", 10, 0.05)
	tween.tween_property($"../OmniLight3D", "light_energy", 1, 0.1)
	tween.parallel().tween_property($"../OmniLight3D", "omni_range", 4, 0.1)
	tween.play()
	player.world.camera.add_trauma(0.15)

func _on_dash_cooldown_timeout() -> void:
	recover_dash_juice()
