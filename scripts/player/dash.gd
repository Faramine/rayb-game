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

func dash(dash_target_pos: Vector3):
	if dash_cooldown.is_stopped() and player.is_charged:
		player.is_charged = false
		is_dashing = true
		player.animationTree["parameters/conditions/is_dashing"] = true;
		dash_target_dir = (dash_target_pos - player.position)
		self.dash_target_dir = Vector3(dash_target_dir.x, 0, dash_target_dir.z).normalized()
		$DashParticles.global_position = player.global_position
		$DashParticles.restart()
		player.world.camera.add_trauma(0.25)
		player.sword_collisions(true)
		var tween_greycape = create_tween()
		tween_greycape.tween_property($"../Armature/Skeleton3D/Cylinder_002".get_active_material(0),
	 		"emission", Color.from_rgba8(100,100,100), 0.1)
		#$"../Armature/Skeleton3D/Cylinder_002".get_active_material(0).emission = Color.from_rgba8(100,100,100)
	
func process_dash(delta):
	dash_time += delta
	if (dash_time <= 0.075):
		player.intent_direction = dash_target_dir
		player.rotation.y = dash_target_dir.signed_angle_to(Vector3(0,0,1),Vector3(0,-1,0))
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
	player.sword_collisions(false)
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
	if  player.is_charged || is_dashing: return
	dash_cooldown.stop()
	prejuice_timer.stop()
	$"../OmniLight3D".light_energy = 1
	var tween_greycape = create_tween()
	tween_greycape.tween_property($"../Armature/Skeleton3D/Cylinder_002".get_active_material(0),
 		"emission", Color.WHITE, 0.1)
	#$"../Armature/Skeleton3D/Cylinder_002".get_active_material(0).emission = Color.WHITE
	player.is_charged = true

func _on_dash_cooldown_timeout() -> void:
	recover_dash_juice()
	player.is_charged = true

func _on_prejuice_timer_timeout() -> void:
	recover_dash_prejuice()
