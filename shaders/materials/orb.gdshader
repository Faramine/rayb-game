shader_type spatial;
render_mode unshaded, world_vertex_coords, cull_disabled;
uniform float frequency = 3.0;
uniform float minimum_light = 0.5;
uniform float intensity = 5.0;

varying float dot_value; 
void vertex() {
	// Called for every vertex the material is visible on.
	vec3 camera_dir = CAMERA_POSITION_WORLD - VERTEX;
	
	dot_value = dot(normalize(NORMAL), normalize(camera_dir));
}

void fragment() {
	// Called for every pixel the material is visible on.
	SPECULAR = 0.0;
	ALBEDO = (vec3(0.0,0.0,0.0) + vec3(1.0,1.0,1.0) * pow(( 1.0 - abs(dot_value)),2) * (pow(((cos((TIME*PI)/frequency))+1.0)/2.0,2) + minimum_light)) * intensity;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
