class_name DashAbility
extends Node3D

@onready var player : Player = $".."
@onready var dash_cooldown : Timer = $DashCooldown
@onready var prejuice_timer : Timer = $PrejuiceTimer

var is_dashing = false
var dash_speed = 150
var dash_time = 0
var dash_target_dir = Vector3()

var tween_whitecape : Tween = create_tween()
var tween_lightboom : Tween = create_tween()

func _ready():
	prejuice_timer.wait_time = dash_cooldown.wait_time - $DashRecoverParticles.lifetime - 0.25
	# tween_whitecape

	# tween_lightboom


func dash(dash_target_pos: Vector3):
	if dash_cooldown.is_stopped():
		is_dashing = true
		player.animationTree["parameters/conditions/is_dashing"] = true;
		dash_target_pos.y = 0
		self.dash_target_dir = (dash_target_pos - player.position).normalized();
		$DashParticles.global_position = player.global_position
		$DashParticles.restart()
		$"../Armature/Skeleton3D/Cylinder_002".get_active_material(0).emission = Color.from_rgba8(100,100,100)
		player.world.camera.add_trauma(0.25)
	
func process_dash(delta):
	dash_time += delta
	if (dash_time <= 0.075):
		#var dash_direction = (dash_target_pos - player.position).normalized();
		player.armature.rotation.y = lerp_angle(player.armature.rotation.y,
		 dash_target_dir.signed_angle_to(Vector3(0.0,0.0,1.0),Vector3(0.0,-1.0,0.0)), player.lerp_smoothstep);
		player.velocity = dash_target_dir * dash_speed;
	else:
		end_dash()

func end_dash():
	is_dashing = false
	player.animationTree["parameters/conditions/is_dashing"] = false;
	dash_time = 0
	player.velocity = Vector3.ZERO
	dash_cooldown.start()
	end_dash_juice()
	await get_tree().create_timer(.1).timeout
	for area in $"../Area3D".get_overlapping_areas():
		if area.is_in_group("Godray"):
			regain_dash()
	
func end_dash_juice():
	$"../OmniLight3D".light_energy = 0
	prejuice_timer.start()
	
func recover_dash_prejuice():
	$DashRecoverParticles.restart()
	tween_whitecape = create_tween()
	tween_whitecape.set_ease(Tween.EASE_OUT)
	tween_whitecape.tween_property($"../Armature/Skeleton3D/Cylinder_002".get_active_material(0),
	 "emission", Color.WHITE, 0.5)

func recover_dash_juice():
	tween_lightboom = create_tween()
	tween_lightboom.tween_property($"../OmniLight3D", "light_energy", 30, 0.05)
	tween_lightboom.parallel().tween_property($"../OmniLight3D", "omni_range", 10, 0.05)
	tween_lightboom.tween_property($"../OmniLight3D", "light_energy", 1, 0.1)
	tween_lightboom.parallel().tween_property($"../OmniLight3D", "omni_range", 4, 0.1)
	player.world.camera.add_trauma(0.15)

func regain_dash():
	if  dash_cooldown.is_stopped() || is_dashing: return
	dash_cooldown.stop()
	prejuice_timer.stop()
	$"../OmniLight3D".light_energy = 1
	$"../Armature/Skeleton3D/Cylinder_002".get_active_material(0).emission = Color.WHITE

func _on_dash_cooldown_timeout() -> void:
	recover_dash_juice()

func _on_prejuice_timer_timeout() -> void:
	recover_dash_prejuice()
