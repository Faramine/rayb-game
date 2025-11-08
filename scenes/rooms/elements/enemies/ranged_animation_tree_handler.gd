extends AnimationTree

var bullet : bool = false
var shockwave : bool = false
var laser : bool = false
var hit : bool = false
var dead : bool = false
var death_tween : Tween
@onready var mesh : MeshInstance3D = $"../Armature/Skeleton3D/monster_1"

func shoot_bullet():
	bullet = true

func stop_bullet():
	bullet = false

func shoot_shockwave():
	shockwave = true

func stop_shockwave():
	shockwave = false

func shoot_laser():
	laser = true

func stop_laser():
	laser = false

func trigger_hit():
	hit = true

func stop_hit():
	hit = false

func death():
	dead = true
	if death_tween:
		death_tween.kill()
	death_tween = create_tween()
	death_tween.tween_method(set_surface_parameter, 0.0, 1.0, 5);

func set_surface_parameter(animation : float):
	mesh.get_active_material(1).set_shader_parameter("animation", animation)
