shader_type spatial;
render_mode unshaded;
render_mode cull_disabled ; // disable backface culling, since those are the faces we want to render

uniform float animation: hint_range (0.0, 1.0, 0.01) = 1.0;

varying vec3 world_position;
varying float distance_p; // Distance parameter in object-space coordinates. Independent of the actual length of the object.
varying float displacement; // Value of the displacement (computer in the vertex shader) orthogonal to the main axis

float hash(vec2 p){
    p = fract(p * vec2(125.76, 473.82));
    p += dot(p, p + 86.12);
    return fract(p.x * p.y);
}

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

float fbm(vec2 x, float amplitude, float frequency, int iterations){
    float y = 0.0;
    mat2 rot = mat2(vec2(cos(0.87), sin(0.87)), vec2(-sin(0.87), cos(0.87)));
    for(int i=0; i < iterations; i++){
        y += amplitude * noise(x * frequency); // Calculate Noise Layer
        x *= rot;                              // rotate next iteration
        frequency *= 1.4;               // adjust lacunarity for next iteration
        amplitude *= 0.588;                     // adjust gain for next iteration
    }
    return y;
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
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	distance_p = VERTEX.x;
	
	// computing displacement
	{
		float max_width = 0.3;
		float min_width = 0.2;
		
		float time_offset = -TIME * 40.0;
		//float noise = fbm(vec2(distance_p,time_offset), 10.0, 1.0, 1);
		
		float scale = 4.0;
		float beam_p = distance_p / scale + time_offset;
		
		float sine_noise = sin(beam_p - PI/2.0);

		sine_noise += 1.0;
		//sine_noise *= 0.0;
		float periodic_noise = floor(beam_p/(2.0*PI));
		periodic_noise = hash(vec2(periodic_noise));
		periodic_noise = periodic_noise*periodic_noise;
		periodic_noise *= 4.0;
		sine_noise *= periodic_noise;
		displacement = mix(min_width,max_width,(sine_noise));
		
		displacement = max(displacement,0.0);
	}
	
	vec3 displacement_vector;
	{
		vec3 point_on_axis = vec3(distance_p,0.0,0.0);// The position of the closest point on the axis
		vec3 displacement_direction = normalize(VERTEX - point_on_axis);
		displacement_vector = displacement_direction * displacement;
	}
	VERTEX = VERTEX + displacement_vector;
}

void fragment() {
	// This material has a dark outline around its outermost edges. It is meant to be used only on
	// spherical objects

	vec3 to_camera = normalize(CAMERA_POSITION_WORLD - world_position);
	vec3 world_normal = (INV_VIEW_MATRIX * vec4(NORMAL,0.0)).xyz;
	world_normal = normalize(world_normal);
	float d = dot(to_camera,world_normal);
	
	d *= 6.0;
	d -= 2.;
	
	d = clamp(d,0.0,1.0);
	
	ALBEDO = vec3(d);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
