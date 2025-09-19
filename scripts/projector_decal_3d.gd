@tool
extends MeshInstance3D
class_name ProjectorDecal3D

@export var size: Vector3 = Vector3(1,1,1):
	set(value):
		if not mesh:
			_create_mesh()
		size = value
		_update_shader()

@export var texture: Texture2D:
	set(value):
		if not mesh:
			_create_mesh()
		texture = value
		mesh.material.set_shader_parameter("decal_texture", texture)
		update_configuration_warnings()

func _update_shader():
	mesh.size.x = size.x
	mesh.size.y = size.y
	mesh.size.z = size.z
	mesh.material.set_shader_parameter("scale_mod", Vector3(1/size.x,1/size.y,1/size.z))
	mesh.material.set_shader_parameter("cube_half_size", Vector3(size.x/2,size.y/2,size.z/2))
	
func _create_mesh():
	mesh = BoxMesh.new()
	mesh.flip_faces = true
	mesh.material = ShaderMaterial.new()
	mesh.material.shader = preload("res://shaders/materials/decal_test.gdshader")
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_update_shader()
