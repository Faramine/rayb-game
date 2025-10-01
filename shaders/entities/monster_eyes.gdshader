shader_type spatial;
render_mode unshaded;
varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	// This material has a dark outline around its outermost edges. It is meant to be used only on
	// spherical objects

	vec3 to_camera = normalize(CAMERA_POSITION_WORLD - world_position);
	vec3 world_normal = (INV_VIEW_MATRIX * vec4(NORMAL,0.0)).xyz;
	world_normal = normalize(world_normal);
	float d = dot(to_camera,world_normal);
	
	d *= 6.0;
	d -= 2.;
	
	d = clamp(d,0.0,1.0);
	
	ALBEDO = vec3(d);
}
