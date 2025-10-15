shader_type spatial;
render_mode unshaded;

varying vec3 world_position;
varying vec3 object_position;
uniform float outer_radius ;
uniform float inner_radius ;
uniform float animation: hint_range (0.0, 1.0, 0.01) = 1.0;

// Calculates Random Number
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
		float s = sin((x.x + noise + TIME/20.0*float(i)) * 2.0 * PI * (frequency.x + float(i) * 2.0)) * amplitude + amplitude;
		s += sin((x.y + noise) * 2.0 * PI * (frequency.y + float(i))) * amplitude + amplitude;
		float amplitude = noise;
		y += s * amplitude;
    }
    return clamp(y,0.0,1.0);
}

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	object_position = VERTEX.xyz;
}


float map(float v, float a, float b){
	return clamp((v-a)/(b-a),0.0,1.0);
}

void fragment() {
	vec2 angular = vec2(0.0,0.0);
	float epsilon = 0.01;
	angular.y = length(object_position.xz);
	angular.x = (atan(object_position.x, object_position.z) / (2.0*PI)) + 0.5;
	
	int layer_n = 1;
	
	float outer_circle_mask = 0.0;
	for (int k = 0; k < layer_n; k++)
	{
		float layer = 0.0;
		float radius = outer_radius * animation;
		float thickness = 0.2;
		//float min_distance_mask = (angular.y - (radius - thickness)) / thickness;
		float min_distance_mask = map(angular.y,radius-thickness, radius-thickness + epsilon);
		float max_distance_mask = map(angular.y,radius + epsilon,radius);
		float inner_mask = (angular.y > inner_radius)?1.0:0.0;
		float painterly_mask = map(fbm2(angular.xy, 0.2, vec2(-10.0,1.0), 8), 0.8, 0.8 + epsilon);
		layer += min_distance_mask * max_distance_mask;
		layer *= inner_mask;
		layer *= painterly_mask;
		outer_circle_mask += clamp(layer,0.0,1.0) / float(layer_n);
	}
	float inner_circle_mask = 0.0;
	{
		float radius = clamp(outer_radius * animation,0.0,inner_radius);
		float thickness = 0.2;
		//float min_distance_mask = (angular.y - (radius - thickness)) / thickness;
		float min_distance_mask = map(angular.y,radius-thickness, radius-thickness + epsilon);
		float max_distance_mask = map(angular.y,radius + epsilon,radius);
		float painterly_mask = map(fbm2(angular.xy, 0.2, vec2(-10,1.0), 8), 0.75, 0.75 + epsilon);
		inner_circle_mask += min_distance_mask * max_distance_mask;
		inner_circle_mask *= painterly_mask;
		inner_circle_mask = clamp(inner_circle_mask,0.0,1.0);
	}
	
	vec3 final_color = vec3(1.0);
	float final_alpha = 0.0;
	final_alpha += outer_circle_mask;
	final_alpha += inner_circle_mask;
	final_alpha = clamp(final_alpha,0.0,1.0);
	
	ALBEDO = final_color;
	ALPHA = final_alpha;
	//DEBUG
	if(false){
		ALBEDO = vec3(final_alpha);
		ALPHA = 1.0;
	}
}