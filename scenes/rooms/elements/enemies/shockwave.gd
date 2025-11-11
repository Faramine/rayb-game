class_name Shockwave
extends Node3D

signal shockwave_ended
var expension_tween : Tween
var fading_tween : Tween
@onready var mesh : MeshInstance3D = $MeshInstance3D
@onready var material : StandardMaterial3D = $MeshInstance3D.mesh.material
@onready var collision : CollisionShape3D = $HitBox/CollisionShape3D
@onready var hitBox : HitBox = $HitBox

func launch():
	visible = true
	mesh.scale = Vector3(0.1,0.1,0.1)
	collision.shape.radius = 5.0
	hitBox.set_deferred("monitorable", true)
	material.albedo_color.a = 1.0
	if expension_tween:
		expension_tween.kill()
	if expension_tween:
		expension_tween.kill()
	expension_tween = create_tween()
	fading_tween = create_tween()
	expension_tween.tween_property(mesh,"scale",Vector3(5,5,5),0.15)
	fading_tween.tween_interval(0.14)
	fading_tween.tween_property(material,"albedo_color:a",0,0.01)
	fading_tween.tween_callback(end)
	

func end():
	collision.shape.radius = 0.1
	hitBox.set_deferred("monitorable", false)
	shockwave_ended.emit()
	visible = false
