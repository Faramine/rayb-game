shader_type spatial;
render_mode unshaded;

uniform sampler2D TEXTURE: source_color;

uniform float speed: hint_range (0.0, 1.0, 0.01) = 1.0;

varying vec3 vertex_world_coordinates;
varying vec3 vertex_object_coordinates;
varying vec3 object_position;
varying vec3 vertex_world_normal;

float map(float v, float a, float b){
	return clamp((v-a)/(b-a),0.0,1.0);
}

void vertex() {
	object_position = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vertex_object_coordinates = VERTEX;
	vertex_world_coordinates = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	
	vertex_world_normal = (MODEL_MATRIX * vec4(NORMAL,0.0)).xyz;
	vertex_world_normal = normalize(vertex_world_normal);
	
	vec3 offset = vertex_world_normal * sin(TIME * 10.0 + UV.y * 10.0) * 0.2;
	//VERTEX += offset;
}

void fragment() {
	vec2 sample_uv = vec2(
		UV.y,
		fract(UV.x - TIME)
	);
	
	vec3 sampled_texture = texture(TEXTURE,sample_uv).xyz;
	vec3 final_color = sampled_texture;
	
	float mask = 1.0;
	mask = map(UV.x,0.3,0.0);
	mask = clamp(mask,0.0,1.0);
	mask *= map(UV.x,1.0,0.8);
	mask = clamp(mask,0.0,1.0);
	
	float edge_mask = (UV.x < 0.15)?1.0:0.0;
	
	ALBEDO = final_color * mask + edge_mask;
}
