class_name Orb
extends Node3D

var inv = false
var inv_timer = 0.0

var spawn_position
var strength = 2.0

@onready var outer_mesh : MeshInstance3D = $MeshInstance3D/MeshInstance3D2
@onready var inner_mesh : MeshInstance3D = $MeshInstance3D

@onready var velocity = Vector3(0.0,0.0,0.0)

@onready var animationplayer = $AnimationPlayer

func _ready() -> void:
	spawn_position = position
	animationplayer.play("Orb_floating")

func take_damage(hitbox : HitBox):
	var tween = create_tween()
	var tween2 = create_tween()
	var albedo = outer_mesh.mesh.material.albedo_color
	
	var direction = (spawn_position - hitbox.global_position).normalized()
	var interpolated_position = spawn_position + direction * strength
	var interpolated_position2 = spawn_position + direction * strength / 2
	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self,"global_position",interpolated_position,1.0)
	
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self,"global_position",interpolated_position2,0.75)
	
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(self,"global_position",spawn_position,2)
	
	tween2.set_ease(Tween.EASE_OUT)
	tween2.set_trans(Tween.TRANS_QUAD)
	tween2.tween_property(outer_mesh.mesh.material,"albedo_color",Color(10,10,10),0.1)
	
	tween2.set_ease(Tween.EASE_OUT)
	tween2.set_trans(Tween.TRANS_QUAD)
	tween2.tween_property(outer_mesh.mesh.material,"albedo_color",albedo,0.3)
