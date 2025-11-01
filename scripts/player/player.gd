class_name Player
extends CharacterBody3D
# Nodes #
@export var world : World
@onready var controller = $Player_controller
@onready var dash_ability : DashAbility = $Dash
# Armature and animation nodes
@onready var armature = $Armature;
@onready var skeleton = $Armature/Skeleton3D;
@onready var bone_idx : int = skeleton.find_bone("head");

@onready var animationTree = $AnimationTree;
@onready var headMarker = $Armature/Head_marker;
@onready var lookAtModifier = $Armature/Skeleton3D/LookAtModifier3D;
# Player properties #
@export var speed = 15
@export var friction : float = 13
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

const lerp_smoothstep = 10; # Smoothness of the rotation animation on movement direction change

var is_in_godray = false
var intent_direction = Vector3(0,1,0)
@onready var last_position = global_position
var is_charged = true : set = _set_charged
var is_dead = false

signal godray_entered
signal godray_exited
signal dead

func _ready() -> void:
	self.is_charged = true;

func _process(delta):
	if is_dead: return
	if dash_ability.is_dashing:
		($DashMotionRibbon).visible = true;
		dash_ability.process_dash(delta)
	else:
		($DashMotionRibbon).visible = false;
		process_move(delta)
	if not is_on_floor():
		velocity.y -= gravity
	sword_collisions_length()
	last_position = global_position
	move_and_slide()

func dash(dash_target_pos: Vector3):
	dash_ability.dash(dash_target_pos)

func process_move(delta):
	var direction = controller.move_vector();
	
	lookAtModifier.target_node = world.cursor.get_path();
	var cursor_pos : Vector3 = world.cursor.global_position;
	var local_bone_transform : Transform3D = skeleton.get_bone_global_pose(bone_idx);
	var global_bone_pos : Vector3 = skeleton.to_global(local_bone_transform.origin);
	var lookAt : Vector3 = cursor_pos - global_bone_pos;
	lookAt = lookAt.normalized();
	var lookAtDot : float = lookAt.dot(direction);
		
	if direction:
		intent_direction = direction
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
		if lookAtDot > 0:
			animationTree["parameters/conditions/is_walking"] = true;
			animationTree["parameters/conditions/is_backing"] = false;
			self.rotation.y = lerp_angle(self.rotation.y, intent_direction.signed_angle_to(Vector3(0,0,1),Vector3(0,-1,0)), lerp_smoothstep * delta)
		else:
			animationTree["parameters/conditions/is_backing"] = true;
			animationTree["parameters/conditions/is_walking"] = false;
			self.rotation.y = lerp_angle(self.rotation.y, intent_direction.signed_angle_to(Vector3(0,0,-1),Vector3(0,-1,0)), lerp_smoothstep * delta)
			intent_direction = -intent_direction
		animationTree["parameters/conditions/is_idle"] = false;
	else:
		velocity.x = lerp(velocity.x, 0.0, delta * friction);
		velocity.z = lerp(velocity.z, 0.0, delta * friction);
		animationTree["parameters/conditions/is_backing"] = false;
		animationTree["parameters/conditions/is_walking"] = false;
		animationTree["parameters/conditions/is_idle"] = true;
		self.rotation.y = lerp_angle(self.rotation.y, intent_direction.signed_angle_to(Vector3(0,0,1),Vector3(0,-1,0)), lerp_smoothstep * delta)
	

func take_damage(hitbox : HitBox):
	if not $DamageCooldown.is_stopped(): return
	$Health.take_damage(1)
	if $Health.is_dead():
		is_dead = true
		$"Armature/Skeleton3D/Cylinder_002".get_active_material(0).emission = Color.from_rgba8(0,0,0)
		dash_ability.dash_cooldown.stop()
		dash_ability.prejuice_timer.stop()
		dead.emit()
		$SubViewport/Control/Label.text = "Dead"
		is_in_godray = true
		self.process_mode = Node.PROCESS_MODE_DISABLED
	else:
		is_charged = false
		$"Armature/Skeleton3D/Cylinder_002".get_active_material(0).emission = Color.from_rgba8(100,100,100)
		dash_ability.dash_cooldown.start()
		dash_ability.prejuice_timer.start()
	$DamageCooldown.start()
	
func _on_area_entered(area: Area3D) -> void:
	if area.is_in_group("Camera_zone"):
		world.change_room(area.owner.coords)
	if area.is_in_group("Godray"):
		dash_ability.regain_dash()
		is_in_godray = true
		godray_entered.emit()

func _on_area_3d_area_exited(area: Area3D) -> void:
	if area.is_in_group("Godray"):
		is_in_godray = false
		godray_exited.emit()

func sword_direction(_start : Vector3, _finish : Vector3):
	$SwordHitbox.start = _start
	$SwordHitbox.finish = _finish

func sword_collisions(activate):
	$SwordHitbox/LeftSwordCollision.disabled = !activate
	$SwordHitbox/RightSwordCollision.disabled = !activate

func sword_collisions_length():
	var length = global_position.distance_to(last_position)
	$SwordHitbox/LeftSwordCollision.shape.size.z = 1 + length
	$SwordHitbox/LeftSwordCollision.position.z = -length/2
	$SwordHitbox/RightSwordCollision.shape.size.z = 1 + length
	$SwordHitbox/RightSwordCollision.position.z = -length/2

func _set_charged(charged):
	is_charged = charged
	$SubViewport/Control/Label.text = "Chargééé" if charged else "faible"
	$Health.current_health = 2 if charged else 1
