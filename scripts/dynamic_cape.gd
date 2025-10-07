extends Node3D

# Armature and animation nodes
@onready var skeleton = $Skeleton3D;
# @onready var bone_idx : int = skeleton.find_bone("head");

# Hook array
var hook_grid;
var hook_velocity_grid;
var hook_position_grid;
const grid_width = 5;
const grid_height = 3;

const spring_stiffness = 100.0;
const hook_weight = 10.0;

func hook_global(hook_id : int):
	var local_pos : Transform3D = skeleton.get_bone_global_pose(hook_id);
	var global_pos : Vector3 = skeleton.to_global(local_pos.origin);
	return global_pos;
	
func hook_global_rest(hook_id : int):
	var local_pos : Transform3D = skeleton.get_bone_global_rest(hook_id);
	var global_pos : Vector3 = skeleton.to_global(local_pos.origin);
	return global_pos;

func _ready() -> void:
	# Filling up the 
	hook_grid = [];
	hook_velocity_grid = [];
	hook_position_grid = [];
	for i in grid_width:
		hook_grid.append([])
		hook_velocity_grid.append([])
		hook_position_grid.append([])
		for j in grid_height:
			hook_grid[i].append(
				skeleton.find_bone(str("cape_hook_", i, "_", j))
			);
			hook_velocity_grid[i].append(Vector3(0.0,0.0,0.0));
			hook_position_grid[i].append(hook_global(hook_grid[i][j]));

func _process(delta):
	for i in grid_width:
		for j in grid_height:
			#get the hook's global position
			
			if j == 0:
				hook_velocity_grid[i][j] = Vector3(0.0, 0.0, 0.0);
				hook_position_grid[i][j] = hook_global_rest(hook_grid[i][j]);
				
				var new_local_pos : Vector3 = skeleton.to_local(hook_position_grid[i][j]) ;
				skeleton.set_bone_pose_position(hook_grid[i][j], new_local_pos);
			else:
				var spring_force_sum : Vector3 = Vector3(0.0,0.0,0.0);
				for k in range(i-1,i+1):
					for l in range(j-1,j+1):
						if k in range(0,grid_width-1) and l in range(0,grid_height-1):
							var spring_length : float = hook_global(hook_grid[i][j]).distance_to(hook_global(hook_grid[i][0]));
							var spring_rest_length : float = hook_global_rest(hook_grid[i][j]).distance_to(hook_global_rest(hook_grid[i][0]));
							var spring_force_magnitude : float = -spring_stiffness * (spring_length - spring_rest_length); 
							var spring_force_direction : Vector3 = (hook_global(hook_grid[i][j])-hook_global(hook_grid[i][0])).normalized();
							var spring_force_vector = spring_force_direction * spring_force_magnitude;
							
							spring_force_sum += spring_force_vector;
				
				var shape_force = -spring_stiffness * (- hook_global_rest(hook_grid[i][j]) + hook_global(hook_grid[i][j]));
				
				var gravity_force_vector = Vector3(0, -9.81, 0) * hook_weight;
				
				hook_velocity_grid[i][j] *= 0.96
				hook_velocity_grid[i][j] += (spring_force_sum+gravity_force_vector+shape_force) * delta;
				hook_position_grid[i][j] += hook_velocity_grid[i][j] * delta;
				
				#return to local coords and set the new bone position
				var new_local_pos : Vector3 = skeleton.to_local(hook_position_grid[i][j]) ;
				skeleton.set_bone_pose_position(hook_grid[i][j], new_local_pos);
