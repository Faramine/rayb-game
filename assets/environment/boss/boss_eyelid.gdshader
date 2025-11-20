shader_type spatial;
render_mode unshaded;

varying float screen_ratio;
varying vec2 screen_dimensions;
varying mat4 model_matrix;
varying mat4 view_matrix;
varying mat4 projection_matrix;
varying vec2 object_center_uv;

varying vec3 object_position;
varying vec3 object_normal;
varying vec3 world_position;
varying vec3 world_normal;

float map(float v, float a, float b){
	return clamp((v-a)/(b-a),0.0,1.0);
}

void vertex() {
	screen_ratio = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
	screen_dimensions = VIEWPORT_SIZE.xy;
	model_matrix = MODEL_MATRIX;
	view_matrix = VIEW_MATRIX;
	projection_matrix = PROJECTION_MATRIX;
	
	vec4 p = PROJECTION_MATRIX * vec4(NODE_POSITION_VIEW,1.0);
	object_center_uv = (p.xy / p.w ) * 0.5 + 0.5;
	
	object_position = VERTEX;
	world_position = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
	
	world_normal = (MODEL_MATRIX * vec4(NORMAL.xyz, 0.0)).xyz;
	
	object_normal = NORMAL;
}

void fragment() {
	vec3 final_color;
	vec3 to_camera = -normalize(CAMERA_POSITION_WORLD - world_position);
	vec3 reflected = normalize(reflect(to_camera,world_normal));
	
	float fresnel = map(-dot(world_normal,to_camera),
	0.2,0.0);
	
	ALBEDO = vec3(fresnel);
}