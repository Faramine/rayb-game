extends AnimationTree

var walking : bool = false
var bracing : bool = false
@onready var mesh : MeshInstance3D = $"../armature/Skeleton3D/monster_0"

var death_tween : Tween

func _ready() -> void:
	self.animation_finished.connect(on_animation_end)

func walk():
	walking = true

func idle():
	walking = false

func brace():
	bracing = true

func slam():
	bracing = false

func death():
	if death_tween:
		death_tween.kill()
	death_tween = create_tween()
	death_tween.tween_method(set_surface_parameter, 0.0, 1.0, 10);

func on_animation_end(animation):
	if animation == "Slam":
		pass

func set_surface_parameter(animation : float):
	mesh.get_active_material(0).set_shader_parameter("animation", animation)
