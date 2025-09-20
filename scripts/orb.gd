class_name Orb
extends Node3D

var inv = false
var dead = false
var inv_timer = 0.0

var spawn_position
var strength = 2.0

@onready var outer_mesh : MeshInstance3D = $MeshInstance3D
@onready var inner_mesh : MeshInstance3D = $MeshInstance3D/MeshInstance3D

@onready var velocity = Vector3(0.0,0.0,0.0)

@onready var animationplayer = $AnimationPlayer

@onready var life = 0

func _ready() -> void:
	spawn_position = global_position
	animationplayer.play("Orb_floating")

func take_damage(hitbox : HitBox):
	var position_tween = create_tween()
	var flashing_tween = create_tween()
	var albedo = outer_mesh.mesh.material.albedo_color
	
	var direction = (spawn_position - hitbox.global_position).normalized()
	var interpolated_position = spawn_position + direction * strength
	var interpolated_position2 = spawn_position + direction * strength / 2
	
	position_tween.set_ease(Tween.EASE_OUT)
	position_tween.set_trans(Tween.TRANS_QUAD)
	position_tween.tween_property(self,"global_position",interpolated_position,1.0)
	
	position_tween.set_ease(Tween.EASE_IN)
	position_tween.set_trans(Tween.TRANS_QUAD)
	position_tween.tween_property(self,"global_position",interpolated_position2,0.75)
	
	position_tween.set_ease(Tween.EASE_OUT)
	position_tween.set_trans(Tween.TRANS_ELASTIC)
	position_tween.tween_property(self,"global_position",spawn_position,2)
	
	flashing_tween.set_ease(Tween.EASE_OUT)
	flashing_tween.set_trans(Tween.TRANS_QUAD)
	flashing_tween.tween_property(outer_mesh.mesh.material,"albedo_color",Color(10,10,10),0.05)
	
	flashing_tween.set_ease(Tween.EASE_OUT)
	flashing_tween.set_trans(Tween.TRANS_QUAD)
	flashing_tween.tween_property(outer_mesh.mesh.material,"albedo_color",albedo,0.05)
	
	life = life +1
	$AudioStreamPlayer3D.pitch_scale = randf_range(0.90,1.1) *  (1 + life / 3.0)
	$AudioStreamPlayer3D.play()
	$ImpactParticles/GPUParticles3D.restart()
	$ImpactParticles/GPUParticles3D2.restart()
	
	if life > 3 && not dead:
		dead = true
		animationplayer.play("Orb_empty")
