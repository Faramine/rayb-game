shader_type spatial;
render_mode unshaded,cull_front;

uniform sampler2D depth_texture : hint_depth_texture;
uniform sampler2D screen_texture : hint_screen_texture;
uniform sampler2D decal_texture;

varying mat4 INV_MODEL_MATRIX;

uniform vec3 scale_mod = vec3(1.0,1.0,1.0);
uniform vec3 cube_half_size = vec3(0.5,0.5,0.5);

void vertex() {
	INV_MODEL_MATRIX = inverse(MODEL_MATRIX);
}

vec3 world_pos_from_depth(float depth, vec2 screen_uv, mat4 inverse_proj, mat4 inverse_view) {
	float z = depth * 2.0 - 1.0;
	vec4 clipSpacePosition = vec4(screen_uv * 2.0 - 1.0, z, 1.0);
	vec4 viewSpacePosition = inverse_proj * clipSpacePosition;
	viewSpacePosition /= viewSpacePosition.w;
	vec4 worldSpacePosition = inverse_view * viewSpacePosition;
	return worldSpacePosition.xyz;
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 world_pos = world_pos_from_depth(depth, SCREEN_UV, INV_PROJECTION_MATRIX, (INV_VIEW_MATRIX));
	vec4 test_pos = (INV_MODEL_MATRIX * vec4(world_pos, 1.0));

	if (abs(test_pos.x) > cube_half_size.x ||
		abs(test_pos.y) > cube_half_size.y ||
		abs(test_pos.z) > cube_half_size.z) {
		discard;
	}

    vec2 NEW_UV = (test_pos.xz * scale_mod.xz) + 0.5;
	
	vec4 screen = texture(screen_texture,SCREEN_UV);
	vec4 stencil = texture(decal_texture,NEW_UV);
	float a = (screen.x + screen.y + screen.z);
	
	EMISSION = vec3(20.0);
	ALBEDO = vec3(0.5)+vec3(25.0)*screen.xyz;
	ALPHA = ( cube_half_size.x - abs(test_pos.x) - 0.1) * ( cube_half_size.z - abs(test_pos.z) - 0.1) * 5.0;
	if(a<0.01||a>2.9)
		ALPHA= 0.0;
}

//void light() {
//}
