shader_type spatial;
render_mode unshaded;
render_mode cull_disabled ; // disable backface culling, since those are the faces we want to render

uniform float animation: hint_range (0.0, 1.0, 0.01) = 1.0;

varying vec4 origin_viewspace;
varying vec2 origin_screen_coords;
varying vec4 world_position;
varying float screen_ratio;
varying mat4 model_matrix;
varying mat4 view_matrix;
varying mat4 projection_matrix;

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

vec2 distance_to_line(vec2 A, vec2 B, vec2 P)
{
    vec2 D = normalize(B-A);
	float param = dot(P-A, D);
	float dist = distance(P, A + D * param);
    return vec2(param, dist);
}

void vertex() {
	screen_ratio = VIEWPORT_SIZE.x / VIEWPORT_SIZE.y;
	model_matrix = MODEL_MATRIX;
	view_matrix = VIEW_MATRIX;
	projection_matrix = PROJECTION_MATRIX;
	
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0));
	origin_viewspace = VIEW_MATRIX * MODEL_MATRIX * vec4(0.0,0.0,0.0,1.0);
	origin_screen_coords = (PROJECTION_MATRIX * origin_viewspace).xy;
	origin_screen_coords += 1.0;
	origin_screen_coords *= 0.5;
	origin_screen_coords *= vec2(1.0,  1.0 / screen_ratio);
	
	VERTEX.y = max(VERTEX.y,-2.5);
}

vec2 project_to_bb(in vec3 p){

	
	return vec2(0.0);
}

vec2 screen_UV_to_bb_coords (vec2 sUV){
	vec2 factor = (projection_matrix * (vec4(1.0,1.0,0.0,1.0) + view_matrix * model_matrix * vec4(0.0,0.0,0.0,1.0))).xy;
	factor += 1.0;
	factor *= 0.5;
	factor *= vec2(1.0,  1.0 / screen_ratio);
	
	vec2 bb_coords;
	bb_coords = sUV - origin_screen_coords;
	bb_coords /= factor - origin_screen_coords;
	return vec2(bb_coords);
}

vec2 world_to_screen_UV (vec3 world_coords){
	vec2 screen = (projection_matrix * view_matrix * vec4(world_coords,1.0)).xy;
	screen += 1.0;
	screen *= 0.5;
	screen *= vec2(1.0,  1.0 / screen_ratio);
	return screen;
}

float mosaic (vec2 coord, float size) {
    return mod(floor(coord.y / size) + floor(coord.x / size), 2.);
}

void fragment() {
	vec2 screen_coords = vec2(SCREEN_UV.x,  SCREEN_UV.y / screen_ratio);
	float debug;

	vec2 bb_coords = screen_UV_to_bb_coords(screen_coords);
	
	vec3 point_world = vec3(0.5,0.0,0.0);
	vec2 point_screen = world_to_screen_UV(point_world);
	vec2 point_bb_coords = screen_UV_to_bb_coords(point_screen);
	//debug = (abs(bb_coords.x) < 0.001 || abs(bb_coords.y) < 0.001)?1.0:0.0;
	//debug = (distance(point_bb_coords,bb_coords) < 0.1)?1.0:0.0;
	
	vec2 segment_point_A = vec2(0.7, 0.2);
	vec2 segment_point_B = vec2(0.1, 0.1);
	
	if(FRONT_FACING) discard; // discard front facing faces
	ALBEDO = vec3(0.0);

	float noise = map(fbm(screen_coords, 0.15 * animation, 300.0, 1), -1.0, 1.0);
	
	debug = (distance_to_line(segment_point_A,segment_point_B,bb_coords + noise*0.3).y<animation*0.1)?1.0:0.0;
	
	//debug = (distance(origin_screen_coords,screen_coords) < 0.1)?1.0:0.0;
	//debug = (origin_screen_coords.y < 1.0)?1.0:0.0;
	// debug
	ALBEDO = vec3(debug);
	//ALBEDO = vec3(bb_coords,0.0);
	//ALBEDO = vec3(mosaic(bb_coords, 0.1));
}
