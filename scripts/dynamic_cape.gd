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

const spring_stiffness = 100.0;
const shape_stiffness = 100.0;
const hook_weight = 1.0;
const spring_friction = 0.90;
const body_friction = 0.0;

const wind_force = Vector3(-00.0,0.0,0.0);

const reaction_radius : float = 1.15;
const reaction_height : float = 3.0;

func hook_local(hook_id : int):
	var local_pos : Transform3D = skeleton.get_bone_global_pose(hook_id);
	return local_pos.origin;
	
func hook_local_rest(hook_id : int):
	var local_pos : Transform3D = skeleton.get_bone_global_rest(hook_id);
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
			hook_position_grid[i].append(hook_global_rest(hook_grid[i][j]));
			hook_position_local_grid[i].append(hook_local(hook_grid[i][j]));

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
				#if j in range(0,1) or (( i == 0 or i == 8) and j in range(0,3)):
				if j in range(0,1) :
					new_hook_velocity_grid[i][j] = Vector3(0.0, 0.0, 0.0);
					hook_velocity_grid[i][j] = Vector3(0.0, 0.0, 9.0);
					new_hook_position_grid[i][j] = hook_global_rest(hook_grid[i][j]);
					hook_position_grid[i][j] = hook_global_rest(hook_grid[i][j]);
					
					var new_local_pos : Vector3 = skeleton.to_local(new_hook_position_grid[i][j]) ;
					skeleton.set_bone_pose_position(hook_grid[i][j], new_local_pos);
				else:
					
					var new_local_position = hook_local(hook_grid[i][j]);
					var new_flattened_position = Vector2(new_local_position.x, new_local_position.z);
					var old_local_position = hook_position_local_grid[i][j];
					var old_flattened_position = Vector2(old_local_position.x,old_local_position.z);
					var rest_local_position = hook_local_rest(hook_grid[i][j]);
					var rest_flattened_position = Vector2(rest_local_position.x,rest_local_position.z);
					#var intersection_param_0 : float = Geometry2D.segment_intersects_circle(
						#old_flattened_position,
						#new_flattened_position,
						#Vector2(0.0,0.0),
						#reaction_radius);
						
					if old_flattened_position.length() < reaction_radius:
						var correction_ray = (rest_flattened_position - old_flattened_position) * 2.0;
						
						
						var intersection_param : float = Geometry2D.segment_intersects_circle(
						old_flattened_position,
						old_flattened_position + correction_ray,
						Vector2(0.0,0.0),
						reaction_radius);
						
						if intersection_param == -1:
							breakpoint; #Failure  case
						
						# var corrected_position_flattened = old_flattened_position.normalized() * reaction_radius
						var corrected_position_flattened = old_flattened_position + correction_ray * intersection_param;
						
						var corrected_position_local = Vector3(corrected_position_flattened.x, old_local_position.y, corrected_position_flattened.y);
						hook_position_grid[i][j] = skeleton.to_global(corrected_position_local);
						
					#if intersection_param_0 == -1:
						## -1 returned and nothing is in the radius, there are no intersections
						#pass; # Do nothing
					#elif intersection_param_0 != -1:
						## Compute the intersection with the cylinder in local space
						#var hit_position_local : Vector3 = old_local_position + (new_local_position-old_local_position)*intersection_param_0;
						#var hit_position_global : Vector3 = skeleton.to_global(hit_position_local)# Convert to global
						#hook_velocity_grid[i][j] = Vector3(0.0,0.0,0.0); # NULLIFY velocity
						#hook_position_grid[i][j] = hit_position_global;
						
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
					new_hook_velocity_grid[i][j] += (spring_force_sum+gravity_force_vector+shape_force+wind_force) * delta;
					
					# Position computation
					var starting_position : Vector3 = hook_position_grid[i][j];
					var ending_position : Vector3 = hook_position_grid[i][j] + new_hook_velocity_grid[i][j] * delta;
					new_hook_position_grid[i][j] = ending_position;
					
					# Handling collisions
					# The character's hitbox is represented by a cylinder centered at the origin in local space
					# We check if the computed velocity vector intersects the cylinder. If so, we "truncate" it
					# so that it ends on the cylinder's surface. Friction and reaction upon impact is disregarded.
					var starting_position_local = skeleton.to_local(starting_position);
					var ending_position_local = skeleton.to_local(ending_position);
					var velocity_local = ending_position_local - starting_position_local;
					var velocity_direction = velocity_local.normalized();
					
					# REMOVE
					var starting_position_flattened = Vector2(starting_position_local.x, starting_position_local.z);
					var ending_position_flattened = Vector2(ending_position_local.x, ending_position_local.z);
					
					var cylinder_intersection_result : PackedVector3Array = Geometry3D.segment_intersects_cylinder(
						starting_position_local,
						ending_position_local,
						reaction_height,
						reaction_radius);
					
					if cylinder_intersection_result.is_empty():
						# No collisions detected, and the hypothesis that the starting position is outside or on the cylinder
						# means that no collision has occurred.
						pass;
					else:
						# Collision detected. Compute bounce
						var intersection_point : Vector3 = cylinder_intersection_result[0];
						var intersection_normal : Vector3 = cylinder_intersection_result[0];
						
						var reflected_direction : Vector3 = 2.0 * intersection_normal.dot(velocity_direction) * intersection_normal - velocity_direction;
						var intersection_segment = starting_position_local - intersection_point;
						var reflected_magnitude = intersection_segment.length();
						var reflected_vector = reflected_direction * reflected_magnitude;
						
						new_hook_velocity_grid[i][j] = skeleton.to_global(reflected_vector); # NULLIFY velocity
						new_hook_position_grid[i][j] = skeleton.to_global(intersection_point + reflected_vector);
					
		for i in grid_width:
			for j in grid_height:
				#store the computed positions and velocities for the next tick
				hook_velocity_grid[i][j] = new_hook_velocity_grid[i][j];
				hook_position_grid[i][j] = new_hook_position_grid[i][j];
				hook_position_local_grid[i][j] = skeleton.to_local(hook_position_grid[i][j]);
				
				#return to local coords and set the new bone position
				var new_local_pos : Vector3 = skeleton.to_local(hook_position_grid[i][j]) ;
				skeleton.set_bone_pose_position(hook_grid[i][j], new_local_pos);
