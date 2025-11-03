shader_type spatial;
render_mode unshaded;

uniform sampler2D MASK_TEXTURE: source_color;
varying vec3 world_position;

// Global inputs
global uniform vec3 current_room_position;
global uniform vec4 palette_color_base;
global uniform vec4 palette_color_dark;

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

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	float diplsacment_factor = 0.2;
	vec3 displacement_vector = random3(world_position) * diplsacment_factor;

	//VERTEX = VERTEX + displacement_vector;
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
	vec3 multiply = 2.0 * A * B;
    vec3 screen = 1.0 - (2.0 * (1.0 - A)) * (1.0 - B);

	float gray = (A.r + A.b + A.g) / 3.0;
    float threshold = step(gray, 0.5);
    vec3 overlay = (multiply * (1.0 - threshold)) + (screen * threshold);

	overlay = hsv2rgb(rgb2hsv(overlay) * vec3(1.0,5.0,1.0));
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
vec3 voronoi( in vec3 x )
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
        vec3 r = vec3( b ) - f + hash( p + b );
        float d = dot( r, r );

        if( d < res.x )
        {
			id = dot( p+b, vec3(1.0,57.0,113.0 ) );
            res = vec2( d, res.x );
        }
        else if( d < res.y )
        {
            res.y = d;
        }
    }

    return vec3( sqrt( res ), abs(id) );
}

void fragment() {
	//vec3 color_dark = vec3(0.059, 0.075, 0.08)*0.8;
	vec3 color_dark = vec3(0.145, 0.188, 0.306)*0.2;
	vec3 color_base = vec3(0.145, 0.188, 0.306)*0.5*2.0;

	if(false){
		color_base = rgb2hsv(color_base);
		float voronoi_size = 0.5;
		float voronoi_id = voronoi(world_position * voronoi_size).b;
		color_base.x += (random(voronoi_id + 6568.0)*0.5-0.5)*0.05;
		color_base.y += (random(voronoi_id + 8921.0)*0.5-0.5)*0.2;
		color_base.z += (random(voronoi_id + 9822.0)*0.5-0.5)*0.2;
		color_base = clamp(color_base, vec3(0.0), vec3(1.0));
		color_base = hsv2rgb(color_base);
	}

	float height_parameter = world_position.y / 4.0;
	height_parameter = clamp(height_parameter, 0.0, 1.0);
	// Posterize height parameter to get a painterly effect
	float posterization_n = 100.0;
	height_parameter = floor(height_parameter*posterization_n)/posterization_n;
	vec3 color = mix(color_dark, color_base, height_parameter);

	float level_bounds_start = 4.5;
	float level_bounds_end = 5.0;
	float level_bounds_mask = 0.0;
	vec2 level_bounds_coords = world_position.xz;
	float room_size = 13.25;
	level_bounds_coords.x =  (fract((world_position.x / room_size/2.0)+0.5)-0.5)*2.0*room_size;
	level_bounds_coords.y =  (fract((world_position.z / room_size/2.0)+0.5)-0.5)*2.0*room_size;
	level_bounds_mask += clamp(abs(level_bounds_coords.x)-12.0, 0.0, 1.0);
	level_bounds_mask += clamp(abs(level_bounds_coords.y)-12.0, 0.0, 1.0);
	level_bounds_mask = clamp(level_bounds_mask, 0.0, 1.0);
	//ALBEDO = vec3(level_bounds_coords,0.0);
	//ALBEDO = vec3(level_bounds_coords.x);

	// ALBEDO = texture(NORMAL_TEXTURE, UV).rgb;
	float mask_map = texture(MASK_TEXTURE,UV).r;
	float final_alpha = mask_map * 2.0;

	//vec3 normal = (vec4(normal_map, 0.0) * inverse(MODEL_MATRIX)).xyz;
	//normal = normalize(normal);

	float global_illumination = 0.0;
	vec3 light_color = vec3(1.0,1.0,1.0);

	vec3 final_color = palette_color_dark.xyz;
	ALBEDO = final_color;
	ALPHA = final_alpha;
	//ALBEDO = vec3(illumination);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
