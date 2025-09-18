shader_type spatial;
//uniform sampler2D noise : repeat_enable;
render_mode unshaded, depth_prepass_alpha, cull_front;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) *
            42758.5453523);
}

float noise(vec2 uv) {
    vec2 uv_index = floor(uv);
    vec2 uv_fract = fract(uv);

    // Four corners in 2D of a tile
    float a = random(uv_index);
    float b = random(uv_index + vec2(1.0, 0.0));
    float c = random(uv_index + vec2(0.0, 1.0));
    float d = random(uv_index + vec2(1.0, 1.0));

    vec2 blur = smoothstep(0.0, 1.0, uv_fract);

    return mix(a, b, blur.x) +
            (c - a) * blur.y * (1.0 - blur.x) +
            (d - b) * blur.x * blur.y;
}

float fbm(vec2 uv) {
    int octaves = 3;
	float amplitude = 0.5;
    float famplitude = 0.0;
    float frequency = 10.0;
	float value = 0.0;

    for(int i = 0; i < octaves; i++) {
        value += amplitude * noise(frequency * uv);
		famplitude += amplitude;
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value / famplitude;
}

void vertex() {
	VERTEX.z += (fbm(vec2(VERTEX.y - TIME * 0.01)) * 0.5) - 0.25;
	VERTEX.x -= (fbm(vec2(VERTEX.y + TIME * 0.01)) * 0.5) - 0.25;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(1.0);
	ALPHA = max(0.05,(1.0-SCREEN_UV.y)*1.0-0.7);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
