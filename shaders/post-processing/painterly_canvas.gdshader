shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

uniform sampler2D NOISE_TEXTURE: repeat_enable;
//uniform float strength: hint_range(0.0, 5, 0.1) = 1.0;
//uniform float uv_scaling: hint_range (0.0, 10.0, 0.05) = 1.0;
uniform vec2 movement_direction = vec2(1, 0);
uniform float movement_speed: hint_range (0.0, 0.5, 0.01) = 0.1;

varying vec2 screen_pixel_size; //Initialized in the fragment shader

float random(vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) *
            42758.5453523);
}

vec2 random2(vec2 uv) {
	return vec2(fract(sin(dot(uv.xy,
		vec2(12.9898,78.233))) * 43758.5453123));
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
    int octaves = 4;
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

vec4 blendOver(vec4 a, vec4 b) {
    float newAlpha = mix(b.w, 1.0, a.w);
    vec3 newColor = mix(b.w * b.xyz, a.xyz, a.w);
    float divideFactor = (newAlpha > 0.001 ? (1.0 / newAlpha) : 1.0);
    return vec4(divideFactor * newColor, newAlpha);
}

vec2 pixel_to_screen_uv(vec2 pixel){
	return vec2(pixel.x*screen_pixel_size.x,pixel.y*screen_pixel_size.y);
}

vec2 screen_uv_to_pixel(vec2 uv){
	return vec2(uv.x/screen_pixel_size.x,uv.y/screen_pixel_size.y);
}

float distance_to_color(vec2 pixel, vec3 color, int range){
	float min_dist = 100000000.0;
	
	// TODO : this can be optimized by using a spiral
	for(int x = int(pixel.x)-range; x<=int(pixel.x)+range; x++ ){
		for(int y = int(pixel.y)-range; y<=int(pixel.y)+range; y++ ){
			vec2 sample_uv = pixel_to_screen_uv(vec2(float(x),float(y)));
			vec4 sample = texture(screen_texture, sample_uv);
			if(sample.xyz == color){
				float dist = distance(pixel,vec2(float(x),float(y)));
				if(dist<min_dist){
					min_dist = dist;
				}
			}
		}
	}
	return min_dist;
}

void vertex() {}

void fragment() {
	screen_pixel_size = SCREEN_PIXEL_SIZE; //Initialize screen pixel size
	vec2 uv = SCREEN_UV;
	float ratio = (1.0/SCREEN_PIXEL_SIZE.x)/(1.0/SCREEN_PIXEL_SIZE.y);
	vec2 uv_normalized = vec2(uv.x, uv.y/ratio);
	vec2 pixel_coords = vec2(uv.x/SCREEN_PIXEL_SIZE.x,uv.y/SCREEN_PIXEL_SIZE.y);
	vec4 screen_color = texture(screen_texture, uv);

	vec2 movement_factor = movement_direction * movement_speed * TIME;

	//uv += noise_value * VIEWPORT_SIZE * strength;

	float strength_map = 1.0;
	float range = 20.0;
	float distance_to_salient = distance_to_color(pixel_coords, vec3(1.0), int(range));
	//if(distance_to_salient < 100.0)
		//strength_map = 0.0;
	strength_map = distance_to_salient/range;
	strength_map = clamp(strength_map,0.0,1.0);

	vec4 colorSum = vec4(0.0,0.0,0.0,1.0);
	//colorSum += texture(screen_texture, UV);
	int passNumber = 10;
	float global_strength_min = 0.004;
	float global_strength_max = 0.01;
	float uv_scaling = 40.0;
	for (int i = 0; i < passNumber; i++){
		float noise_value_x = fbm(uv_normalized*uv_scaling + vec2(float(i)*0.1+random(vec2(8582.561+float(i)))*5242.588)) - 0.5;
		float noise_value_y = fbm(uv_normalized*uv_scaling + vec2(float(i)*0.1+random(vec2(5438.51+float(i))))) - 0.5;
		vec2 sample_uv = uv;
		float strength = global_strength_min + (global_strength_max-global_strength_min)*strength_map;
		sample_uv.x += noise_value_x*strength;
		sample_uv.y += noise_value_y*strength;
		vec4 sample = texture(screen_texture, sample_uv);
		sample.a *= 0.2;
		colorSum = blendOver(sample,colorSum);

		COLOR.xyz = vec3(noise_value_x,noise_value_y,0.0);
	}

	COLOR.xyz = colorSum.xyz;
	//COLOR.xyz = vec3(strength_map);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
