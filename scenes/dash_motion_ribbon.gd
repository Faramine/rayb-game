extends Node3D

@onready var ribbon_mesh = $RibbonMesh;
@onready var player : Player = $"..";

var camera;

# Mesh Data Tool : 
var mdt = MeshDataTool.new()

# Trajectory buffer:
# This array stores the positions of the player for the n previous ticks.
# We use a round robin iteration to iterate through an array of a fixed size
# The value at the position i is meant to represent the current position of the player
@onready var trajectory_buffer = [];
@onready var direction_buffer = [];
@onready var trajectory_buffer_current_i;
const trajectory_buffer_size = 20;

var material;

func to_viewport(world : Vector3):
	var v = world * camera.get_camera_transform();
	return Vector2(v.x,v.y);

func to_world(coords_viewport : Vector2, origin : Vector3):
	var origin_plane = origin * camera.get_camera_transform();
	var coords_plane = Vector3(coords_viewport.x, coords_viewport.y, origin_plane.z)
	return coords_plane * camera.get_camera_transform().inverse();

func _ready() -> void:
	# Prevent the node from inheriting its parent's transformation
	top_level = true;
	
	trajectory_buffer.resize(trajectory_buffer_size);
	direction_buffer.resize(trajectory_buffer_size);
	trajectory_buffer_current_i = 0
	
	material = ShaderMaterial.new();
	material.set_shader_parameter("Shader", load("res://scenes/dash_smear.gdshader"));
	
	pass;
	
func _process(delta):
	# Registering the player's current position into the buffer 
	#var player_position : Vector3 = player.global_position;
	var player_position : Vector3 = player.to_global(Vector3(0.0,0.0,0.0));
	player_position += Vector3(0.0,1.0,0.0)
	trajectory_buffer[trajectory_buffer_current_i % trajectory_buffer_size] = player_position;
	
	var width : float = 1.0;
	
	camera = get_viewport().get_camera_3d();
	if camera :
		var prev_i = (trajectory_buffer_current_i-1) % trajectory_buffer_size
		
		#print("\n")
		#print(player_position);
		#print(player_position * camera.get_camera_transform());
		#print((player_position * camera.get_camera_transform() + Vector3(1.0,1.0,0.0)) * camera.get_camera_transform().inverse());
		
		if trajectory_buffer[prev_i]:
			var direction = to_viewport(player_position - trajectory_buffer[prev_i])
			var direction_screenspace = Vector2(direction.x,direction.y).normalized()
			direction_buffer[trajectory_buffer_current_i % trajectory_buffer_size] = direction_screenspace;
			#print(direction_screenspace);
		

		var surface_array = []
		surface_array.resize(Mesh.ARRAY_MAX)
		ribbon_mesh.mesh.clear_surfaces();
		var verts = PackedVector3Array()
		var uvs = PackedVector2Array()
		var normals = PackedVector3Array()
		var indices = PackedInt32Array()
		
		for i in range(0,trajectory_buffer_size):
			
			var buffer_i = (trajectory_buffer_current_i - i) % trajectory_buffer_size;
			var buffer_prev_i = (trajectory_buffer_current_i - 1 - i) % trajectory_buffer_size;
			var position = trajectory_buffer[buffer_i]
			var position_prev =  trajectory_buffer[buffer_prev_i]
			if position and position_prev:
				
				var O_pos_screen : Vector2 = to_viewport(position)
				var Oprev_pos_screen : Vector2 = to_viewport(position_prev)
				var tangent_screen = (O_pos_screen - Oprev_pos_screen).normalized();
				var normal_screen = tangent_screen.rotated(PI/2.0).normalized();
				var A_pos_screen : Vector2 = O_pos_screen + normal_screen * width/2.0;
				var B_pos_screen : Vector2 = O_pos_screen - normal_screen * width/2.0;
				var vertex_A_position : Vector3 = to_world(A_pos_screen,position);
				var vertex_B_position : Vector3 = to_world(B_pos_screen,position);
				verts.append(vertex_A_position);
				uvs.append(Vector2(float(i)/float(trajectory_buffer_size),0.0));
				normals.append(Vector3(0.0,1.0,0.0));
				verts.append(vertex_B_position);
				uvs.append(Vector2(float(i)/float(trajectory_buffer_size),1.0));
				normals.append(Vector3(0.0,1.0,0.0));

		for i in range(0,trajectory_buffer_size-1):
			indices.append(i*2)
			indices.append(i*2 + 1)
			indices.append((i+1)*2)

			indices.append((i*2 + 1))
			indices.append((i+1)*2 + 1)
			indices.append((i+1)*2)
			
			indices.append(i*2 + 1)
			indices.append(i*2)
			indices.append((i+1)*2)

			indices.append((i+1)*2 + 1)
			indices.append((i*2 + 1))
			indices.append((i+1)*2)

		surface_array[Mesh.ARRAY_VERTEX] = verts;
		surface_array[Mesh.ARRAY_TEX_UV] = uvs;
		surface_array[Mesh.ARRAY_NORMAL] = normals;
		surface_array[Mesh.ARRAY_INDEX] = indices;

		ribbon_mesh.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_array)
		var surface = ribbon_mesh.get_instance();
		RenderingServer.instance_set_surface_override_material(surface, 0, load("res://scenes/player_controller.tscn::ShaderMaterial_sdupd"))
		# increment the trajectory buffer
		trajectory_buffer_current_i += 1;
