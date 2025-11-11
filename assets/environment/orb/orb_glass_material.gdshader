shader_type spatial;
render_mode unshaded;

uniform sampler2D NORMAL_TEXTURE: source_color;
uniform sampler2D FRACTURE_TEXTURE: source_color;
uniform sampler2D ENV_TEXTURE: source_color;
varying vec3 world_position;
varying vec3 object_position;
varying vec3 world_normal;

// Global inputs
global uniform vec3 current_room_position;
global uniform vec4 palette_brass_base;
global uniform vec4 palette_brass_light;

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

void vertex() {
	object_position = VERTEX;
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float diplsacment_factor = 0.2;
	vec3 displacement_vector = random3(world_position) * diplsacment_factor;

	//VERTEX = VERTEX + displacement_vector;
}

void fragment() {
	vec3 color_base;
	if(true){
		color_base = rgb2hsv(palette_brass_base.xyz);
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

	float height_parameter = world_position.y / 4.0;
	height_parameter = clamp(height_parameter, 0.0, 1.0);
	// Posterize height parameter to get a painterly effect
	float posterization_n = 100.0;
	height_parameter = floor(height_parameter*posterization_n)/posterization_n;
	vec3 color = palette_brass_base.rgb;

	float room_size = 13.25;
	vec2 level_bounds_start = vec2(12.0,18.25);
	vec2 level_bounds_end = vec2(26.0,26.0);
	float level_bounds_mask = 0.0;
	vec2 level_bounds_coords = world_position.xz;

	level_bounds_mask += clamp(abs(world_position.x - current_room_position.x) - level_bounds_start.x, 0.0, 1.0);
	level_bounds_mask += clamp(abs(world_position.z - current_room_position.z) - level_bounds_start.y, 0.0, 1.0);
	level_bounds_mask = clamp(level_bounds_mask, 0.0, 1.0);
	//ALBEDO = vec3(level_bounds_coords,0.0);
	//ALBEDO = vec3(level_bounds_coords.x);

	// ALBEDO = texture(NORMAL_TEXTURE, UV).rgb;
	vec3 normal_map = (texture(NORMAL_TEXTURE,UV).rgb - 0.5)*2.0;
	normal_map = vec3(normal_map.x,normal_map.z,-normal_map.y);
	normal_map = normalize(normal_map);

	world_normal = (MODEL_MATRIX * vec4(normal_map,0.0)).xyz;
	world_normal = normalize(world_normal);

	float global_illumination = 0.0;
	vec3 light_color = vec3(1.0,1.0,1.0);

	vec3 light_drection = normalize(vec3(0.5,1.0,0.2));
	{
		float light_intensity = 0.2;
		float illumination = clamp(dot(world_normal,light_drection),0.0,1.0) * light_intensity;
		global_illumination += illumination;
	}

	vec3 to_camera = -normalize(CAMERA_POSITION_WORLD - world_position);
	vec3 reflected = normalize(reflect(to_camera,world_normal));
	
	vec3 n = reflected;
    float len = sqrt (n.x *n.x + n.z*n.z);
    float s = acos( n.x / len);

    if (n.z < 0.0) {
        s = 2.0 * PI - s;
    }

    s = s / (2.0 * PI);

    vec2 reflected_vector = vec2(s , ((asin(n.y) * -2.0 / PI ) + 1.0) * 0.5);
	float reflected_light = texture(ENV_TEXTURE, reflected_vector).x;
	
	float specular = clamp(dot(reflected,light_drection),0.0,1.0);
	specular *= specular;
	specular *= specular;
	specular *= specular;
	specular *= specular;
	specular = clamp(specular,0.0,1.0);

	specular = reflected_light;

	float z_mask = world_position.y + 1.0;
	z_mask = clamp(z_mask,0.0,1.0);

	float fresnel = dot(to_camera,world_normal);
	fresnel = -(-fresnel - 0.5)*2.0;

	float inner_mask = distance(object_position, vec3(0.0,6.0,0.0)) * 10.0 - 37.5;
	inner_mask = clamp(inner_mask,0.0,1.0);

	vec3 final_color = overlay(color, light_color, global_illumination);
	final_color = mix(final_color, palette_brass_light.xyz, specular*0.3);
	final_color *= 1.0-level_bounds_mask;
	final_color *= z_mask;
	final_color = vec3(1.0);
	ALBEDO = final_color;
	//ALBEDO = vec3(fresnel);
	
	float final_alpha = fresnel;
	final_alpha += texture(FRACTURE_TEXTURE,UV).r;
	final_alpha *= inner_mask;
	final_alpha = clamp(final_alpha,0.0,1.0);
	ALPHA = final_alpha;
	
	// debug
	//ALBEDO = vec3(inner_mask);
	//ALPHA = 1.0;
}