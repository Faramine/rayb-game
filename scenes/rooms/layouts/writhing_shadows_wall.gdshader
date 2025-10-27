shader_type spatial;
render_mode unshaded;

varying vec3 object_position;
const float scale = 1.0;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) *
            42758.5453523);
}

vec2 random2(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
}

float map(float v, float a, float b){
	return clamp((v-a)/(b-a),0.0,1.0);
}

float inv(float x){
	return 2.0-2.0/(x+1.0);
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
    int octaves = 6;
    float amplitude = 0.5;
    float frequency = 3.0;
	float value = 0.0;

    for(int i = 0; i < octaves; i++) {
        value += amplitude * noise(frequency * uv);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value;
}

void voronoise(vec2 uv, float columns, float rows, float variance,
	out float distance_A, out vec2 position_A, out vec2 index_A,
	out float distance_B, out vec2 position_B, out vec2 index_B
) {
	vec2 ratio = vec2(columns,rows);

	vec2 index_uv = floor(vec2(uv.x * ratio.x, uv.y * ratio.y));
	vec2 fract_uv = fract(vec2(uv.x * ratio.x, uv.y * ratio.y));

	//distance_A = random(index_uv);
	//return;

	float minimum_dist_A = 1.0;
	float true_dist_A;
	vec2 minimum_point_A;
	vec2 minimum_index_A;

	float minimum_dist_B = 1.0;
	vec2 minimum_point_B;
	vec2 minimum_index_B;

	int range = 3;
	for (int y= -range; y <= range; y++) {
		for (int x= -range; x <= range; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 index = index_uv + neighbor;
			float speed = clamp(fbm(index_uv + neighbor),0.0,1.0) * 2.0;
			float t = TIME * speed;
			vec2 displacement = vec2(
				fbm(index_uv + neighbor + 68461.5616 + t),
				fbm(index_uv + neighbor + 41345.1675 + t)
			);
			displacement = vec2(inv(displacement.x),inv(displacement.y));
			vec2 point = (vec2(1.0-variance/2.0)) + displacement * variance * float(range);

			float dist = length(neighbor + point - fract_uv);
			if(dist < minimum_dist_A) {
				minimum_dist_B = minimum_dist_A;
				minimum_point_B = minimum_point_A;
				minimum_index_B = minimum_index_A;
				minimum_dist_A = dist;
				minimum_point_A = index_uv + neighbor + point ;
				minimum_index_A = index;
			}else if(dist < minimum_dist_B) {
				minimum_dist_B = dist;
				minimum_point_B = index_uv + neighbor + point ;
				minimum_index_B = index;
			}
		}
	}

	distance_A = minimum_dist_A;
	position_A = minimum_point_A;
	index_A = minimum_index_A;
	distance_B = minimum_dist_B;
	position_B = minimum_point_B;
	index_B = minimum_index_B;

	return;
}

void noise_texture(
	out float distance_A, out vec2 position_A, out vec2 index_A,
	out float distance_B, out vec2 position_B, out vec2 index_B){
	voronoise(object_position.xy * scale, 1.0, 1.0, 0.8, distance_A, position_A, index_A, distance_B, position_B, index_B);
}

void vertex() {
	object_position = VERTEX;
	
	float distance_A;
	vec2 position_A;
	vec2 index_A;
	float distance_B;
	vec2 position_B;
	vec2 index_B;
	noise_texture(distance_A, position_A, index_A, distance_B, position_B, index_B);
	
	float displacement = 1.0 - distance_A*distance_A*distance_A;
	//displacement *=  mix(3.5,5.0,random(index_A));
	displacement *= 3.0;
	displacement += fbm(object_position.xy/20.0 + vec2(0.0,TIME*-1.0)) * 5.0;
	VERTEX = VERTEX + vec3(0.0,0.0,1.0) * displacement;
}

void fragment() {
	float distance_A;
	vec2 position_A;
	vec2 index_A;
	float distance_B;
	vec2 position_B;
	vec2 index_B;
	noise_texture(distance_A, position_A, index_A, distance_B, position_B, index_B);
	
	float displacement = 1.0 - distance_A*distance_A*distance_A;
	displacement *= 5.0;
	
	float eye_mask;
	{
		float eye_radius = mix(0.01,0.4,random(index_A));
		float eye_intensity = map(random(index_A + vec2(516.173)),0.8,0.81);
		eye_mask = map(distance_A, eye_radius+0.01, eye_radius);
		eye_mask += map(distance_A, eye_radius+0.05+0.01, eye_radius+0.05)*0.2;
		eye_mask *= eye_intensity;
	}

	vec3 normal;
	vec3 to_center = normalize(vec3(object_position.xy * scale,displacement) - vec3(position_A,5.0));
	vec3 tangent = vec3(
		cos(PI/2.0)*to_center.x - sin(PI/2.0)*to_center.y,
		sin(PI/2.0)*to_center.x + cos(PI/2.0)*to_center.y,
		0.0
	);
	
	normal = normalize(cross(to_center,tangent));
	
	float luminosity;
	{
		luminosity = dot(vec3(0.0,1.0,0.0),normal);
	}
	
	vec3 base_albedo = mix(
		vec3(0.0),
		vec3(0.035),
		map(luminosity,0.3,0.9)
	);
	
	vec3 color = base_albedo + vec3(eye_mask);
	ALBEDO = color;
	//ALBEDO = vec3();
}