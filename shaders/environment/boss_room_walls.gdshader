shader_type spatial;
render_mode unshaded;

uniform sampler2D TEXTURE: source_color;

uniform float speed: hint_range (0.0, 1.0, 0.01) = 1.0;

varying vec3 vertex_world_coordinates;
varying vec3 vertex_object_coordinates;
varying vec3 object_position;
varying vec3 vertex_world_normal;

void vertex() {
	object_position = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vertex_object_coordinates = VERTEX;
	vertex_world_coordinates = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	vertex_world_normal = (MODEL_MATRIX * vec4(NORMAL,0.0)).xyz;
	vertex_world_normal = normalize(vertex_world_normal);

	vec3 offset = vertex_world_normal * sin(TIME * 10.0 + UV.y * 10.0) * 0.2;
	VERTEX += offset;
}

void fragment() {
	vec2 sample_uv = vec2(
		UV.x * 2.0,
		fract(UV.y + TIME * 0.1) * 2.0
	);

	vec3 sampled_texture = texture(TEXTURE,sample_uv).xyz;
	vec3 final_color = sampled_texture;

	ALBEDO = final_color;
}
