class_name Player
extends CharacterBody3D
# Nodes #
@export var world : World
@onready var armature = $Armature;
@onready var animationTree = $AnimationTree;
@onready var controller = $Player_controller
@onready var dash_cooldown : Timer = $DashCooldown
# Player properties #
@export var speed = 15
@export var friction : float = 13
var dash_speed = 150
var dash_time = 0
var dash_target_pos = Vector3()
var is_dashing = false
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
const lerp_smoothstep = 0.5; # Smoothness of the rotation animation on movement direction change

func _process(delta):
	if is_dashing:
		process_dash(delta)
	else:
		process_move(delta)
	if not is_on_floor():
		velocity.y -= gravity
	move_and_slide()

func dash(dash_target_pos: Vector3):
	if dash_cooldown.is_stopped():
		is_dashing = true
		dash_target_pos.y = 0
		self.dash_target_pos = dash_target_pos
		$DashParticles.global_position = self.global_position
		$DashParticles.restart()
		$Armature/Skeleton3D/Cylinder_002.get_active_material(0).emission = Color.from_rgba8(100,100,100)
	
func process_dash(delta):
	dash_time += delta
	dash_target_pos.y = position.y
	animationTree["parameters/conditions/is_dashing"] = true;
	if (position-dash_target_pos).length() < 0.5 || dash_time >0.3:
		# Si le dash est fini
		is_dashing = false
		dash_time = 0
		velocity = Vector3.ZERO
		animationTree["parameters/conditions/is_dashing"] = false;
		end_dash_juice()
	else:
		var dash_direction = (dash_target_pos - position).normalized();
		armature.rotation.y = lerp_angle(armature.rotation.y, dash_direction.signed_angle_to(Vector3(0.0,0.0,1.0),Vector3(0.0,-1.0,0.0)), lerp_smoothstep);
		velocity = dash_direction * dash_speed;

func end_dash_juice():
	dash_cooldown.start()
	$OmniLight3D.light_energy = 0
	var tween = create_tween()
	tween.set_ease(tween.EASE_OUT)
	tween.tween_property($OmniLight3D, "light_energy", 1, dash_cooldown.wait_time)
	tween.play()
	await get_tree().create_timer(dash_cooldown.wait_time - $DashRecoverParticles.lifetime - 0.25).timeout
	$DashRecoverParticles.restart()

func recover_dash_juice():
	$Armature/Skeleton3D/Cylinder_002.get_active_material(0).emission = Color.WHITE
	var tween = create_tween()
	tween.tween_property($OmniLight3D, "light_energy", 30, 0.05)
	tween.parallel().tween_property($OmniLight3D, "omni_range", 10, 0.05)
	tween.tween_property($OmniLight3D, "light_energy", 1, 0.1)
	tween.parallel().tween_property($OmniLight3D, "omni_range", 4, 0.1)
	tween.play()

func process_move(delta):
	var direction = controller.move_vector()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		armature.rotation.y = lerp_angle(armature.rotation.y, direction.signed_angle_to(Vector3(0.0,0.0,1.0),Vector3(0.0,-1.0,0.0)), lerp_smoothstep);
		animationTree["parameters/conditions/is_walking"] = true;
		animationTree["parameters/conditions/is_idle"] = false;
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * friction);
		velocity.z = lerp(velocity.z, 0.0, delta * friction);
		animationTree["parameters/conditions/is_walking"] = false;
		animationTree["parameters/conditions/is_idle"] = true;

func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("Camera_zone"):
		world.change_room(area.owner.coords)

func _on_dash_cooldown_timeout() -> void:
	recover_dash_juice()
