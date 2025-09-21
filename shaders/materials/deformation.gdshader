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

/*vec2 uv2screen_uv(vec2 uv, vec2center){
	
}*/

void fragment() {
	// Called for every pixel the material is visible on.
	//float ratiovp = VIEWPORT_SIZE.x/VIEWPORT_SIZE.y;
	//vec2 offset = object_center_uv-vec2(0.5,0.5);
	//float ratio = distance(SCREEN_UV,object_center_uv)/distance(UV,vec2(0.5));
	//vec2 uv = UV;
	//vec2 billboard = SCREEN_UV-offset - vec2(0.5);
	//billboard.x = billboard.x * ratiovp;
	
	float intensity = distance(UV,vec2(0.5));
	float i = ((0.5/distance(UV,vec2(0.5)))-1.0)*0.5;
	float r = 0.3*2.0;
	if(intensity> 0.5 || intensity < 0.3) discard;
	intensity = (smoothstep(0.0,1.0,1.0-abs(((clamp(intensity * 2.0,r,1.0) - r)/(1.0-r))*2.0-1.0)));
	//intensity = i-smoothstep(0.0,i,intensity);
	
	float scale = intensity*i+1.0;
	vec2 displaced_uv = scale_around_uv(SCREEN_UV,object_center_uv,vec2((scale)));
	//displaced_uv = SCREEN_UV;
	ALPHA = intensity;//(0.5 - abs(dot_value))*2.0;
	ALBEDO = texture(screen,displaced_uv).xyz;
	//if(0.3 < intensity && intensity < 0.4) ALBEDO = vec3(1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
