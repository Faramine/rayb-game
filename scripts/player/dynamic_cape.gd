extends Node3D

# Armature and animation nodes
@onready var skeleton = $Skeleton3D;
# @onready var bone_idx : int = skeleton.find_bone("head");

var rng = RandomNumberGenerator.new()
var noise = FastNoiseLite.new()
@onready var noise_time_start = Time.get_unix_time_from_system();

# Hook array
var hook_grid;
var hook_velocity_grid;
var hook_position_grid;
const grid_width = 25;
const grid_height = 9;

const spring_stiffness = 3000.0;
const shape_stiffness = 000.0;
const hook_weight = 50.0;
const spring_friction = 0.0;
const body_friction = 0.0;

const max_velocity = 200.0;
const max_acceleration = 1900000.0;

const wind_direction = Vector3(0.0,0.0,1.0);
const wind_max_strength = 300.0;
const wind_max_frequency = 20.0;

const drag_max_strength = 1000.0;
const drag_max_frequency = 200.0;

const reaction_radius : float = 1.20;
const reaction_height : float = 20.0;

const toggle_correction : bool = true;
const toggle_collision : bool = true;

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

func flatten(v : Vector3):
	return Vector2(v.x,v.z);

func unflatten(v : Vector2, o : Vector3):
	return Vector3(v.x,o.y,v.y);

func approx(x: float, y: float, e: float):
	return (x > y-e and x < y+e)

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
			hook_position_grid[i].append(hook_global_rest(hook_grid[i][j]));
	
	noise.noise_type = FastNoiseLite.TYPE_VALUE_CUBIC 
	noise.fractal_octaves = 3
	
func _process(delta):
	var noise_time = Time.get_unix_time_from_system() - noise_time_start;

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
				if j == 0 :
					# The hooks on the first row are fixed
					
					new_hook_velocity_grid[i][j] = Vector3(0.0, 0.0, 0.0);
					hook_velocity_grid[i][j] = Vector3(0.0, 0.0, 0.0);
					new_hook_position_grid[i][j] = hook_global_rest(hook_grid[i][j]);
					hook_position_grid[i][j] = hook_global_rest(hook_grid[i][j]);
					
					var new_local_pos : Vector3 = skeleton.to_local(new_hook_position_grid[i][j]) ;
					skeleton.set_bone_pose_position(hook_grid[i][j], new_local_pos);
					
				else:
					if toggle_correction :
						var local_position = skeleton.to_local(hook_position_grid[i][j]);
						var flattened_position = flatten(local_position);
						var rest_local_position = hook_local_rest(hook_grid[i][j]);
						var rest_flattened_position = Vector2(rest_local_position.x,rest_local_position.z);
							
						if flattened_position.length() < reaction_radius:
							var correction_ray = (rest_flattened_position - flattened_position) * 2.0;
							
							var intersection_param : float = Geometry2D.segment_intersects_circle(
							flattened_position,
							flattened_position + correction_ray,
							Vector2(0.0,0.0),
							reaction_radius);
							if intersection_param == 1.0:
								breakpoint; #Failure  case
								
							if intersection_param == -1:
								breakpoint; #Failure  case
							
							var corrected_position_flattened = flattened_position + correction_ray * intersection_param + correction_ray.normalized() * 0.01;
							
							var corrected_position_local = unflatten(corrected_position_flattened, local_position);
							hook_position_grid[i][j] = skeleton.to_global(corrected_position_local);
					
					if flatten(skeleton.to_local(hook_position_grid[i][j])).length() < reaction_radius:
						var debug = flatten(skeleton.to_local(hook_position_grid[i][j])).length();
						breakpoint; #Failure case: The intersection point is supposed to be on the surface of the cylinder
					
					# Computing spring forces between neighboring hooks
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
					
					if i == 0 or i == grid_width-1 or j == 0 or j == grid_height-1:
						spring_force_sum *= 3;
					
					# Computing spring forces between the hook and its original position
					var shape_force = -shape_stiffness * (- hook_global_rest(hook_grid[i][j]) + hook_global(hook_grid[i][j]));
					
					# Computing weight
					var gravity_force_vector = Vector3(0, -9.81, 0) * hook_weight;
					
					# Computing wind
					var wind_force_vector = wind_direction * noise.get_noise_2d(noise_time * wind_max_frequency,0.0) * wind_max_strength;
					
					# Compute air drag
					var air_drag_intensity = hook_velocity_grid[i][j].length() / 50.0;
					
					var air_drag_vector = Vector3(0.0,0.0,0.0)
					air_drag_vector += Vector3(1.0,0.0,0.0) * noise.get_noise_2d(noise_time * drag_max_frequency + 68846 * (i),j) * drag_max_strength;
					air_drag_vector += Vector3(0.0,0.0,1.0) * noise.get_noise_2d(noise_time * drag_max_frequency + 12686 * (i),j) * drag_max_strength;
					air_drag_vector += Vector3(0.0,5.5,0.0) * noise.get_noise_2d(noise_time * drag_max_frequency + 51468 * (i),j) * drag_max_strength;
					air_drag_vector *= air_drag_intensity;
					
					# Final force sum and velocity computation
					# [TODO ?] We compute a velocity vector for each applied force. This is where we implicitly apply friction forces.
					new_hook_velocity_grid[i][j] = hook_velocity_grid[i][j] * spring_friction
					
					var acceleration_vector = Vector3(0.0,0.0,0.0);
					acceleration_vector += spring_force_sum;
					acceleration_vector += gravity_force_vector;
					acceleration_vector += shape_force;
					acceleration_vector += wind_force_vector;
					acceleration_vector += air_drag_vector;
					
					# Capping the acceleration
					if acceleration_vector.length() > max_acceleration:
						acceleration_vector = acceleration_vector.normalized() * max_acceleration;
					
					new_hook_velocity_grid[i][j] += acceleration_vector * delta;
					
					# Capping the velocity
					if new_hook_velocity_grid[i][j].length() > max_velocity:
						new_hook_velocity_grid[i][j] = new_hook_velocity_grid[i][j].normalized() * max_velocity;
					
					# Position computation
					var starting_position : Vector3 = hook_position_grid[i][j];
					var ending_position : Vector3 = hook_position_grid[i][j] + new_hook_velocity_grid[i][j] * delta;
					new_hook_position_grid[i][j] = ending_position;
					
					if toggle_collision:
						# Handling collisions
						# The character's hitbox is represented by a cylinder centered at the origin in local space
						# We check if the computed velocity vector intersects the cylinder.
						var starting_position_local = skeleton.to_local(starting_position);
						var ending_position_local = skeleton.to_local(ending_position);
						var velocity_local = ending_position_local - starting_position_local;
						var velocity_direction = velocity_local.normalized();
						
						var intersection_param : float;
						
						if flatten(starting_position_local).length() < reaction_radius:
								var debug = flatten(starting_position_local).length();
								breakpoint; #Failure case: The intersection point is supposed to be on the surface of the cylinder
						
						var cylinder_intersection_result : PackedVector3Array = Geometry3D.segment_intersects_cylinder(
							starting_position_local,
							ending_position_local,
							reaction_height,
							reaction_radius);
						
						if true:
							intersection_param = Geometry2D.segment_intersects_circle(
								flatten(starting_position_local),
								flatten(ending_position_local),
								Vector2(0.0,0.0),
								reaction_radius);
								
							if intersection_param == -1:
								cylinder_intersection_result = PackedVector3Array();
							else :
								var intersection_point_flattened : Vector2 = flatten(starting_position_local) + (flatten(ending_position_local) - flatten(starting_position_local)) * intersection_param
								var intersection_normal_flattened : Vector2 = intersection_point_flattened.normalized()
								var intersection_point : Vector3 = starting_position_local + (ending_position_local - starting_position_local) * intersection_param
								var intersection_normal : Vector3 = unflatten(intersection_normal_flattened,Vector3(0.0,0.0,0.0))
								cylinder_intersection_result = PackedVector3Array([intersection_point,intersection_normal]);
								if not approx(intersection_point_flattened.length(), reaction_radius, 0.1):
									var debug = intersection_point_flattened.length();
									breakpoint; #Failure case: The intersection point is supposed to be on the surface of the cylinder
						
						if cylinder_intersection_result.is_empty():
							# No collisions detected, and the hypothesis that the starting position is outside or on the cylinder
							# means that no collision has occurred.
							pass;
						else:
							# Collision detected. Compute bounce
							var intersection_point : Vector3 = cylinder_intersection_result[0];
							var intersection_point_flattened : Vector2 = Vector2(intersection_point.x, intersection_point.z);
							var intersection_normal : Vector3 = cylinder_intersection_result[1];
							
							if not approx(intersection_point_flattened.length(), reaction_radius, 0.1):
								var debug = intersection_point_flattened.length();
								breakpoint; #Failure case: The intersection point is supposed to be on the surface of the cylinder
							
							var reflected_direction : Vector3 = velocity_direction.normalized() - (2.0 * intersection_normal.normalized().dot(velocity_direction.normalized()) * intersection_normal.normalized());
							reflected_direction = reflected_direction.normalized();
							var incident_vector = intersection_point - starting_position_local;
							var intersecting_vector = ending_position_local - intersection_point;
							
							var reflected_magnitude = intersecting_vector.length();
							var reflected_vector = reflected_direction * reflected_magnitude + reflected_direction.normalized()*0.01;
							var new_end_position_local = intersection_point + reflected_vector;
							
							if flatten(intersection_point + reflected_vector).length() < reaction_radius:
								var debug = flatten(intersection_point + reflected_vector).length();
								breakpoint; #Failure case: The intersection point is supposed to be on the surface of the cylinder
							 
							if false:
								if i == 1 and j == 5:
									print(
										"\n",
										#"starting_position=", starting_position, "|",
										"starting_position_local=", starting_position_local,  "|",
										#"starting_position_flatten=", flatten(starting_position_local),  "|",
										#"ending_position=", ending_position, "|",
										"ending_position_local=", ending_position_local,  "|",
										#"ending_position_flatten=", flatten(ending_position_local),  "|",
										"velocity_direction=", velocity_direction,  "|",
										#"reaction_radius=", reaction_radius,  "|",
										#"intersection_param=", intersection_param,  "|",
										"intersection_point=", intersection_point,  "|",
										#"intersection_point_flattened=", intersection_point_flattened,  "|",
										"intersection_normal=", intersection_normal,  "|",
										"incident_vector=", incident_vector,  "|",
										"intersecting_vector=", intersecting_vector,  "|",
										#"reflected_magnitude=", reflected_magnitude,  "|",
										"reflected_vector=", reflected_vector,  "|",
										)
							
							new_hook_velocity_grid[i][j] = skeleton.to_global(reflected_vector);
							new_hook_velocity_grid[i][j] = skeleton.to_global(Vector3(0.0,0.0,0.0));
							
							new_hook_position_grid[i][j] = skeleton.to_global(new_end_position_local);
							
					hook_velocity_grid[i][j] = new_hook_velocity_grid[i][j];
					#if hook_velocity_grid[i][j].length() < 100.0:
						#hook_velocity_grid[i][j] *= 0.0;
					hook_position_grid[i][j] = new_hook_position_grid[i][j];
					var new_local_pos : Vector3 = skeleton.to_local(hook_position_grid[i][j]) ;
					skeleton.set_bone_pose_position(hook_grid[i][j], new_local_pos);
					
		#for i in grid_width:
			#for j in grid_height:
				##store the computed positions and velocities for the next tick
				#hook_velocity_grid[i][j] = new_hook_velocity_grid[i][j];
				#hook_position_grid[i][j] = new_hook_position_grid[i][j];
				#
				##return to local coords and set the new bone position
				#var new_local_pos : Vector3 = skeleton.to_local(hook_position_grid[i][j]) ;
				#skeleton.set_bone_pose_position(hook_grid[i][j], new_local_pos);
