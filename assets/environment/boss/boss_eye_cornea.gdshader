shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest_mipmap;

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

vec3 object_to_world (vec3 p){
	return (model_matrix * vec4(p,1.0)).xyz;
}

vec2 world_to_screen_UV (vec3 world_coords){
	vec4 projected = (projection_matrix * view_matrix * vec4(world_coords,1.0));
	vec2 screen = vec2(
		1.0 - projected.x / projected.z ,
		1.0 - projected.y / projected.z
	);
	screen *= 0.5;
	//screen *= 0.4;
	//screen *= 0.5;
	//screen *= vec2(1.0,  1.0 / screen_ratio);
	//screen *= screen_dimensions;
	return screen;
}

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

	vec2 sample_uv = SCREEN_UV;
	vec3 refracted_object_position = object_position;
	//refracted_object_position.x = 0.0;
	vec3 refracted_world_position = object_to_world(refracted_object_position);

	//sample_uv = world_to_screen_UV(refracted_world_position);

	float fresnel = map(-dot(world_normal,to_camera),
	0.2,0.0);

	vec3 sample_color = texture(SCREEN_TEXTURE,sample_uv).xyz * 0.85;
	final_color = sample_color + fresnel;

	//ALBEDO = vec3(SCREEN_UV,0.0);
	//ALBEDO = vec3(object_to_world(object_position));
	//ALBEDO = vec3(sample_uv,0.0);
	//ALBEDO = object_normal;
	ALBEDO = final_color;
	//ALBEDO = vec3(fresnel);
}
