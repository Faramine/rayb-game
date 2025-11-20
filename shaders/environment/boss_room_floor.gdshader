shader_type spatial;
render_mode unshaded, depth_draw_never;

uniform sampler2D screen_texture: hint_screen_texture, filter_linear_mipmap, repeat_disable;
uniform sampler2D DEPTH_TEXTURE: hint_depth_texture, filter_linear_mipmap, repeat_disable;

varying mat4 CAMERA;
varying vec3 global_position;

varying vec3 object_position;
varying vec3 world_position;

void vertex() {
	CAMERA = INV_VIEW_MATRIX;
	object_position = VERTEX;
	world_position = (MODEL_MATRIX * vec4(VERTEX,1.0)).xyz;
}

void fragment() {
	float depth = texture(DEPTH_TEXTURE, SCREEN_UV).x;
  	vec3 depth_ndc = vec3(SCREEN_UV, depth) * 2.0 - 1.0;
	
	vec4 view = INV_PROJECTION_MATRIX * vec4(depth_ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;

 	vec4 sampled_world_vector = CAMERA * INV_PROJECTION_MATRIX * vec4(depth_ndc, 1.0);
 	vec3 sampled_world_position = sampled_world_vector.xyz / sampled_world_vector.w;
	
	float distance_to_sampled = distance(world_position, sampled_world_position);
	
	float edge_mask = (distance_to_sampled <= 0.4)?1.0:0.0;
	
	//ALBEDO = world_position.rgb;
	ALBEDO = sampled_world_position.rgb;
	ALBEDO = vec3(edge_mask);
}