extends Node3D

# Armature and animation nodes
@onready var skeleton = $Skeleton3D;
# @onready var bone_idx : int = skeleton.find_bone("head");

# Hook array
var hook_grid;
var hook_velocity_grid;
var hook_position_grid;
var hook_position_local_grid;
const grid_width = 9;
const grid_height = 5;

const spring_stiffness = 500.0;
const shape_stiffness = 300.0;
const hook_weight = 10.0;
const spring_friction = 0.9;
const body_friction = 0.0;

const reaction_radius : float = 1.0;

func hook_local(hook_id : int):
	var local_pos : Transform3D = skeleton.get_bone_global_pose(hook_id);
	return local_pos.origin;

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
	hook_position_local_grid = [];
	for i in grid_width:
		hook_grid.append([])
		hook_velocity_grid.append([])
		hook_position_grid.append([])
		hook_position_local_grid.append([])
		for j in grid_height:
			hook_grid[i].append(
				skeleton.find_bone(str("cape_hook_", i, "_", j))
			);
			hook_velocity_grid[i].append(Vector3(0.0,0.0,0.0));
			hook_position_grid[i].append(hook_global(hook_grid[i][j]));
			hook_position_local_grid[i].append(hook_local(hook_grid[i][j]));
	print(hook_grid)

func _process(delta):
	var new_hook_velocity_grid = [];
	var new_hook_position_grid = [];
	for i in grid_width:
		new_hook_velocity_grid.append([])
		new_hook_position_grid.append([])
		for j in grid_height:
			new_hook_velocity_grid[i].append(Vector3(0.0,0.0,0.0));
			new_hook_position_grid[i].append(Vector3(0.0,0.0,0.0));
	
	if true:
		for i in grid_width:
			for j in grid_height:
				#get the hook's global position
				if j in range(0,2) :
					print(i,'-',j)
					new_hook_velocity_grid[i][j] = Vector3(0.0, 0.0, 0.0);
					hook_velocity_grid[i][j] = Vector3(0.0, 0.0, 9.0);
					new_hook_position_grid[i][j] = hook_global_rest(hook_grid[i][j]);
					hook_position_grid[i][j] = hook_global_rest(hook_grid[i][j]);
					
					var new_local_pos : Vector3 = skeleton.to_local(new_hook_position_grid[i][j]) ;
					skeleton.set_bone_pose_position(hook_grid[i][j], new_local_pos);
				else:
					
					if false:
						var new_local_position = hook_local(hook_grid[i][j]);
						var new_flattened_position = Vector2(new_local_position.x, new_local_position.z);
						var old_local_position = hook_position_local_grid[i][j];
						var old_flattened_position = Vector2(old_local_position.x,old_local_position.z);
						var intersection_param_0 : float = Geometry2D.segment_intersects_circle(
							old_flattened_position,
							new_flattened_position,
							Vector2(0.0,0.0),
							reaction_radius);
						if intersection_param_0 == -1:
							# -1 returned and nothing is in the radius, there are no intersections
							pass; # Do nothing
						elif intersection_param_0 != -1:
							# Compute the intersection with the cylinder in local space
							var hit_position_local : Vector3 = old_local_position + (new_local_position-old_local_position)*intersection_param_0;
							var hit_position_global : Vector3 = skeleton.to_global(hit_position_local)# Convert to global
							hook_velocity_grid[i][j] = Vector3(0.0,0.0,0.0); # NULLIFY velocity
							hook_position_grid[i][j] = hit_position_global;
							
						var repulsion_vector_local = (1.0-(new_flattened_position.length()/reaction_radius))*new_flattened_position.normalized();
						var repulsion_force = skeleton.to_global(Vector3(repulsion_vector_local.x,0.0,repulsion_vector_local.y))*100.0;
						
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
					
					var shape_force = -shape_stiffness * (- hook_global_rest(hook_grid[i][j]) + hook_global(hook_grid[i][j]));
					
					var reaction_force : Vector3;
					
					# Flattened position of the current hook in local space
					var hook_local_flattened_position = hook_local(hook_grid[i][j]);
					hook_local_flattened_position.y = 0.0;
					
					var hook_local_velocity = skeleton.to_local(hook_velocity_grid[i][j]);
					hook_local_velocity.y = 0.0;
					
					var hook_global_position = skeleton.to_global(hook_local_flattened_position);
					var center_global_position = skeleton.to_global(Vector3(0.0,0.0,0.0));
					var hook_global_distance_to_center : float = hook_global_position.distance_to(center_global_position);
					var reaction_magnitude : float = 0.0;
					if hook_global_distance_to_center < reaction_radius:
						reaction_magnitude = reaction_radius-hook_global_distance_to_center;
					var reaction_global_direction = (hook_global_position-center_global_position).normalized();
					reaction_force = -reaction_global_direction * reaction_magnitude;
					
					var tangent = hook_local_flattened_position.rotated(Vector3(0.0,1.0,0.0),PI/2.0).normalized();
					var coeff = Vector3(tangent).dot(hook_local_velocity) / Vector3(tangent).dot(tangent);
					var friction_vector_local = Vector3(tangent.x, 0.0, tangent.z) * coeff;
					
					var normal = hook_local_flattened_position.normalized();
					var relevant_forces = spring_force_sum+shape_force;
					relevant_forces = skeleton.to_local(relevant_forces);
					var normal_force = Vector3(normal).dot(relevant_forces) / Vector3(normal).dot(normal);
					var tangent_force = Vector3(tangent).dot(relevant_forces) / Vector3(tangent).dot(tangent);
					var tangent_force_vector = tangent * tangent_force;
					var friction_force = body_friction*normal_force * tangent_force_vector.normalized();
					if hook_global_distance_to_center > reaction_radius:
						friction_force*=0.0
					friction_force = skeleton.to_global(friction_force);
					
					var gravity_force_vector = Vector3(0, -9.81, 0) * hook_weight;
					
					
					# Final velocity computation
					# [TODO ?] We compute a velocity vector for each applied force. This is where we implicitly apply friction forces.
					new_hook_velocity_grid[i][j] = hook_velocity_grid[i][j] * spring_friction
					new_hook_velocity_grid[i][j] += (spring_force_sum+gravity_force_vector+shape_force) * delta;
					
					# Position computation
					var starting_position : Vector3 = hook_position_grid[i][j];
					var ending_position : Vector3 = hook_position_grid[i][j] + new_hook_velocity_grid[i][j] * delta;
					new_hook_position_grid[i][j] = ending_position;
					
					# Handling collisions
					# The character's hitbox is represented by a cylinder centered at the origin in local space
					# We check for collisions by flattening all the coordinates first
					var starting_position_local = skeleton.to_local(starting_position);
					var ending_position_local = skeleton.to_local(ending_position);
					var starting_position_flattened = Vector2(starting_position_local.x, starting_position_local.z);
					var ending_position_flattened = Vector2(ending_position_local.x, ending_position_local.z);
					var direction_local = (ending_position_local - starting_position_local).normalized();
					var direction_flattened = (ending_position_flattened - starting_position_flattened).normalized();
					# Checking intersection with the hitbox cylinder's cross-section circle
					var intersection_param : float = Geometry2D.segment_intersects_circle(
						starting_position_flattened,
						ending_position_flattened,
						Vector2(0.0,0.0),
						reaction_radius);
					var start_in_radius : bool = starting_position_flattened.length() < reaction_radius;
					var end_in_radius : bool = ending_position_flattened.length() < reaction_radius;
					
					if true:
						pass;
					elif intersection_param == -1 and !start_in_radius and !end_in_radius:
						# -1 returned and nothing is in the radius, there are no intersections
						pass; # Do nothing
					elif intersection_param != -1:
						# Compute the intersection with the cylinder in local space
						var hit_position_local : Vector3 = starting_position_local + (ending_position_local-starting_position_local)*intersection_param;
						var hit_position_global : Vector3 = skeleton.to_global(hit_position_local)# Convert to global
						new_hook_velocity_grid[i][j] = Vector3(0.0,0.0,0.0); # NULLIFY velocity
						new_hook_position_grid[i][j] = hit_position_global;
					elif start_in_radius or end_in_radius:
						var ip : float = Geometry2D.segment_intersects_circle(
						starting_position_flattened,
						starting_position_flattened - direction_flattened*100.0,
						Vector2(0.0,0.0),
						reaction_radius);
						if ip == -1:
							push_error();
						var hit_position_local : Vector3 = starting_position_local + (Vector3(direction_flattened.x,0.0,direction_flattened.y)*100.0)*ip;
						var hit_position_global : Vector3 = skeleton.to_global(hit_position_local)# Convert to global
						new_hook_velocity_grid[i][j] = Vector3(0.0,0.0,0.0); # NULLIFY velocity
						#new_hook_position_grid[i][j] = hit_position_global;
						new_hook_position_grid[i][j] = hook_position_grid[i][j] ;
						
					hook_position_local_grid[i][j] = ending_position_local;
					
		for i in grid_width:
			for j in grid_height:
				#store the computed positions and velocities for the next tick
				hook_velocity_grid[i][j] = new_hook_velocity_grid[i][j];
				hook_position_grid[i][j] = new_hook_position_grid[i][j];
				
				#return to local coords and set the new bone position
				var new_local_pos : Vector3 = skeleton.to_local(hook_position_grid[i][j]) ;
				skeleton.set_bone_pose_position(hook_grid[i][j], new_local_pos);
