@tool
class_name EnemySpawner
extends MeshInstance3D

@export var enemyType: int = 1 :
	set(value):
		enemyType = value
		_create_mesh()
		print("My resource just changed!")

func _create_mesh():
	if(enemyType == 1):
		mesh = CapsuleMesh.new()
		mesh.material = StandardMaterial3D.new()
		mesh.material.albedo_color = Color(0.2,0.0,0.0,0.0)
	elif(enemyType == 2):
		mesh = BoxMesh.new()
		mesh.material = StandardMaterial3D.new()
		mesh.material.albedo_color = Color(0.0,0.0,1.0,1.0)
	else:
		mesh = BoxMesh.new()
		mesh.material = StandardMaterial3D.new()
		mesh.material.albedo_color = Color(1.0,0.0,0.0,1.0)
