shader_type spatial;
render_mode unshaded;

float hash(vec2 p){
    p = fract(p * vec2(125.76, 473.82));
    p += dot(p, p + 86.12);
    return fract(p.x * p.y);
}

// Perlin Noise
float noise (vec2 st) {
    vec2 i = floor(st); // Index
    vec2 f = fract(st); // Fraction
    float a = hash(i + vec2(0.0, 0.0));
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a)* u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm2(vec2 x, float amplitude, vec2 frequency, int iterations){
    float y = 0.0;
    mat2 rot = mat2(vec2(cos(0.87), sin(0.87)), vec2(-sin(0.87), cos(0.87)));
    for(int i=0; i < iterations; i++){
		float noise = noise(vec2(noise(vec2(float(i)))));
		float s = sin((x.x + noise + 0.0/20.0*float(i)) * 2.0 * PI * (frequency.x + float(i) * 2.0)) * amplitude + amplitude;
		s += sin((x.y + noise) * 2.0 * PI * (frequency.y + float(i))) * amplitude + amplitude;
		float amplitude = noise;
		y += s * amplitude;
    }
    return clamp(y,0.0,1.0);
}

float map(float v, float a, float b){
	return clamp((v-a)/(b-a),0.0,1.0);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(UV,0.0);
	float epsilon = 0.01;
	float streaks_mask = 1.0;
	{
		float coverage = clamp(0.95 + 0.05 * UV.x,0.0,1.0);
		float painterly_mask = map(fbm2(UV.xy, 0.2, vec2(-10.0,0.0), 8), coverage, coverage + epsilon);
		streaks_mask *= painterly_mask;
		streaks_mask = clamp(streaks_mask,0.0,1.0);
	}
	
	vec3 final_color = vec3(1.0);
	float final_alpha = 0.0;
	final_alpha += streaks_mask;
	final_alpha = clamp(final_alpha,0.0,1.0);
	
	ALBEDO = final_color;
	ALPHA = final_alpha;
	//DEBUG
	if(false){
		ALBEDO = vec3(final_alpha);
		ALPHA = 1.0;
	}
}
