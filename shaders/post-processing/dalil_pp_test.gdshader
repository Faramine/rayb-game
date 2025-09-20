shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

uniform sampler2D NOISE_TEXTURE: repeat_enable;
//uniform float strength: hint_range(0.0, 5, 0.1) = 1.0;
uniform float uv_scaling: hint_range (0.0, 10.0, 0.05) = 1.0;
uniform vec2 movement_direction = vec2(1, 0);
uniform float movement_speed: hint_range (0.0, 0.5, 0.01) = 0.1;

void vertex() {
	// Called for every vertex the material is visible on.
}

vec4 blendOver(vec4 a, vec4 b) {
    float newAlpha = mix(b.w, 1.0, a.w);
    vec3 newColor = mix(b.w * b.xyz, a.xyz, a.w);
    float divideFactor = (newAlpha > 0.001 ? (1.0 / newAlpha) : 1.0);
    return vec4(divideFactor * newColor, newAlpha);
}

void fragment() {
	vec2 uv = SCREEN_UV;
	vec4 screen_color = texture(screen_texture, uv);

	vec2 movement_factor = movement_direction * movement_speed * TIME;

	//uv += noise_value * VIEWPORT_SIZE * strength;

	vec4 colorSum = vec4(0.0,0.0,0.0,0.0);
	int passNumber = 3;
	float strength = 0.008;
	for (int i = 0; i < passNumber; i++){
		float noise_value_x = texture(NOISE_TEXTURE, uv*uv_scaling + vec2(float(i)*0.1+0.74561)).r - 0.5;
		float noise_value_y = texture(NOISE_TEXTURE, uv*uv_scaling + vec2(float(i)*0.1+0.89551)).r - 0.5;
		vec2 sample_uv = uv;
		sample_uv.x += noise_value_x*strength;
		sample_uv.y += noise_value_y*strength;
		vec4 sample = texture(screen_texture, sample_uv);
		sample.a *= 0.1;
		colorSum = blendOver(colorSum,sample);
	}


	COLOR.xyz = colorSum.xyz;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
