shader_type spatial;
render_mode unshaded;

uniform sampler2D ENV_TEXTURE: source_color;

// Global inputs
global uniform vec3 current_room_position;
global uniform vec4 palette_color_base;
global uniform vec4 palette_color_dark;

varying vec3 vertex_position;
varying vec3 world_position;
varying vec3 world_normal;

varying mat4 normal_matrix;

varying vec2 reflected_vector;

float random(float v) {
    return fract(sin(dot(vec2(v),
        vec2(12.9898,78.233))) *
            42758.5453523);
}

vec2 random2(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
}

vec3 random3(vec3 uv) {
	return vec3(fract(sin(dot(uv.xyz,
		vec3(12.9898,78.233,85.215))) * 43758.5453123));
}

vec3 rgb2hsv(vec3 c){
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));

    float d = q.x - min(q.w, q.y);
    float e = 1.0e-10;
    return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c){
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

vec3 overlay(vec3 A, vec3 B, float factor){
	vec3 overlay = hsv2rgb(rgb2hsv(A) * vec3(1.0,1.5,10.0));
	return mix(A, overlay, factor);
}

vec3 hash( vec3 x )
{
	x = vec3( dot(x,vec3(127.1,311.7, 74.7)),
			  dot(x,vec3(269.5,183.3,246.1)),
			  dot(x,vec3(113.5,271.9,124.6)));

	return fract(sin(x)*43758.5453123);
}

// returns closest, second closest, and cell id
vec3 voronoi( in vec3 x, out vec3 pos)
{
    vec3 p = floor( x );
    vec3 f = fract( x );

	float id = 0.0;
    vec2 res = vec2( 100.0 );
    for( int k=-1; k<=1; k++ )
    for( int j=-1; j<=1; j++ )
    for( int i=-1; i<=1; i++ )
    {
        vec3 b = vec3( float(i), float(j), float(k) );
        vec3 r = b + hash( p + b ) - f;
		vec3 k = b + hash( p + b ); // voronoi cell kernel position
		vec3 k_abs = k + p; // kernel's absolute position
        float d = dot( r, r );

        if( d < res.x )
        {
			id = dot( p+b, vec3(1.0,57.0,113.0 ) );
			pos = k_abs;
            res = vec2( d, res.x );
        }
        else if( d < res.y )
        {
            res.y = d;
        }
    }

    return vec3( sqrt( res ), abs(id) );
}

float fbm(vec3 pos, float seed) {
    int octaves = 3;
    float amplitude = 0.5;
    float frequency = 0.1;
	float value = 0.0;

    for(int i = 0; i < octaves; i++) {
        value += amplitude * random3(frequency * pos + vec3(seed)).x;
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value;
}

float map(float v, float a, float b){
	return clamp((v-a)/(b-a),0.0,1.0);
}

void vertex() {
	vertex_position = VERTEX.xyz;
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	world_normal = (MODEL_MATRIX * vec4(NORMAL.xyz, 0.0)).xyz;
	
	normal_matrix = transpose(inverse(MODELVIEW_MATRIX));
}

void fragment() {
	
	vec3 to_camera = -normalize(CAMERA_POSITION_WORLD - vertex_position);
	vec3 reflected = normalize(reflect(to_camera,world_normal));
	vec3 n = reflected;
    float len = sqrt (n.x *n.x + n.z*n.z);
    float s = acos( n.x / len);

    if (n.z < 0.0) {
        s = 2.0 * PI - s;
    }

    s = s / (2.0 * PI);

    reflected_vector = vec2(s , ((asin(n.y) * -2.0 / PI ) + 1.0) * 0.5);
	
	//vec3 color_dark = vec3(0.059, 0.075, 0.08)*0.8;
	//vec3 color_dark = vec3(0.145, 0.188, 0.306)*0.5;
	//vec3 color_base = vec3(0.145, 0.188, 0.306)*0.5;

	vec3 color_base;
	if(true){
		color_base = rgb2hsv(palette_color_base.xyz);
		float voronoi_size = 0.5;
		vec3 pos;
		
		vec3 noisy_offset = vec3(
			fbm(world_position, 5134.1379),
			fbm(world_position, 2344.7829),
			fbm(world_position, 7523.5278)
		);
		vec3 noisy_position = world_position + noisy_offset;
		
		float voronoi_id = voronoi(noisy_position * voronoi_size, pos).b;
		
		color_base.x += (random(voronoi_id + 6568.0)*0.5-0.0)*0.05;
		color_base.y += (random(voronoi_id + 8921.0)*0.5-0.0)*0.02;
		color_base.z += (random(voronoi_id + 9822.0)*0.5-0.0)*0.15;
		color_base = clamp(color_base, vec3(0.0), vec3(1.0));
		color_base = hsv2rgb(color_base);
	}

	float brightness = 0.8;
	vec3 color_brighter = brightness * vec3(1.0,0.95,0.9) * 0.5;
	vec3 color_darker = brightness * 0.2 * vec3(1.0,0.95,0.9);

	float height_parameter = vertex_position.y;
	height_parameter = map(height_parameter, 1.0, -1.0);
	
	color_base = mix(color_brighter,color_darker,height_parameter);

	float global_illumination = 0.0;
	vec3 light_color = vec3(1.0,1.0,1.0);

	vec3 light_drection = normalize(vec3(0.0,1.0,0.0));
	{
		float light_intensity = 10.0;
		float illumination = clamp(dot(world_normal,light_drection),0.0,1.0) * light_intensity;
		global_illumination += illumination;
	}

	vec3 reflected_color = texture(ENV_TEXTURE, reflected_vector).xyz;

	float glitter = 0.0;
	{
		float glitter_intensity = 60.0;
		float glitter_density = 0.1;
		float voronoi_size = 12.0;
		vec3 voronoi_position;
		float voronoi_id = voronoi(world_position * voronoi_size, voronoi_position).b;
		float voronoi_mask = (random3(voronoi_position).x < glitter_density)?1.0:0.0;
		
		
		
		float y_mask = world_position.y - 4.0;
		y_mask = clamp(y_mask,0.0,1.0);
		
		float nomal_mask = (dot(world_normal,normalize(vec3(0.0,1.0,0.0)))-0.6)*50.0;
		nomal_mask = clamp(nomal_mask,0.0,1.0);
		
		float glitter_albedo = sin(TIME*random3(voronoi_position).x*1.0 + random3(voronoi_position).y * 100.0)-0.99;
		glitter_albedo = clamp(glitter_albedo,0.0,1.0);
		
		glitter = glitter_intensity * voronoi_mask * y_mask * glitter_albedo * nomal_mask;
		//glitter = voronoi_position.y;
	}

	//vec3 final_color = overlay(color_base, light_color, global_illumination);
	vec3 final_color = overlay(color_base, reflected_color, 0.1);
	final_color = mix(reflected_color, final_color, 0.1);
	final_color = overlay(final_color, reflected_color, 0.1);
	//final_color = reflected_color;
	final_color += glitter;
	ALBEDO = final_color;
}
