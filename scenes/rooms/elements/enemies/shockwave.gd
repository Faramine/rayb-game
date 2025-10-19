extends Node3D

signal shockwave_ended
var expension_tween : Tween
var fading_tween : Tween
@onready var material : StandardMaterial3D = $MeshInstance3D.mesh.material

func launch():
	visible = true
	scale = Vector3(0,0,0)
	material.albedo_color.a = 1.0
	expension_tween = create_tween()
	fading_tween = create_tween()
	expension_tween.tween_property(self,"scale",Vector3(5,5,5),0.25)
	fading_tween.tween_interval(0.2)
	fading_tween.tween_property(material,"albedo_color:a",0,0.05)
	fading_tween.tween_callback(end)

func end():
	shockwave_ended.emit()
	visible = false
