shader_type spatial;
render_mode unshaded,depth_test_disabled;

uniform sampler2D screen : hint_screen_texture, filter_nearest_mipmap;

varying vec2 object_center_uv;

void vertex() {
	vec4 p = PROJECTION_MATRIX * vec4(NODE_POSITION_VIEW,1.0);
	object_center_uv = (p.xy / p.w ) * 0.5 + 0.5;
}

vec2 scale_around_uv(vec2 uv, vec2 center, vec2 scale)
{
	return center + (uv - center) * (vec2(1.0) / scale);
}

void fragment() {
	//center zone
	float center_radius = 0.3;
	//radius to center of fragment
	float radius = distance(UV,vec2(0.5));
	//discard out of effect zone
	if(radius> 0.5 || radius < center_radius) discard;
	//max deformation to stay in effect zone
	float i = ((0.5/distance(UV,vec2(0.5)))-1.0)*0.5;
	float r = 0.3*2.0;
	//shape of deformation  : range [0.0,1.0]
	float shape = ((clamp(radius * 2.0,r,1.0) - r)/(1.0-r));
	//intensity of deformation : range [0.0,1.0]
	float intensity = (smoothstep(0.0,1.0,1.0-abs(shape*2.0-1.0)));
	//intensity of deformation : range [1.0,1.0+i]
	float scaled = intensity*i+1.0;
	vec2 displaced_uv = scale_around_uv(SCREEN_UV,object_center_uv,vec2((scaled)));

	ALPHA = intensity * 2.0;
	ALBEDO = texture(screen,displaced_uv).xyz;
}

//void light() {
//}
