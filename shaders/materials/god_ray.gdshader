shader_type spatial;
//uniform sampler2D noise : repeat_enable;
uniform sampler2D gradient;
render_mode unshaded, depth_prepass_alpha;

void vertex() {
}

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
    int octaves = 6;
    float amplitude = 0.5;
    float frequency = 10.0;
	float value = 0.0;

    for(int i = 0; i < octaves; i++) {
        value += amplitude * noise(frequency * uv);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value;
}

void voronoise(vec2 uv, float columns, float rows, float variance, float seed,
	out float distance_A, out vec2 position_A, out vec2 index_A,
	out float distance_B, out vec2 position_B, out vec2 index_B
) {
	vec2 ratio = vec2(columns,rows);

	vec2 index_uv = floor(vec2(uv.x * ratio.x, uv.y * ratio.y));
	vec2 fract_uv = fract(vec2(uv.x * ratio.x, uv.y * ratio.y));

	//distance_A = random(index_uv);
	//return;

	float minimum_dist_A = 2.0;
	float true_dist_A;
	vec2 minimum_point_A;
	vec2 minimum_index_A;

	float minimum_dist_B = 2.0;
	vec2 minimum_point_B;
	vec2 minimum_index_B;

	int range = 1;
	for (int y= -range; y <= range; y++) {
		for (int x= -range; x <= range; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			
			vec2 time_offset = vec2(
				fbm(random2(index_uv + neighbor + seed + 42.0) * TIME * 0.01),
				fbm(random2(index_uv + neighbor - seed - 42.0) * TIME * 0.01)
				);
			vec2 point = 0.7 * time_offset + vec2(0.15);
			
			vec2 point_absolute = point / ratio + neighbor / ratio;
			vec2 frag_absolute = fract_uv / ratio;
			vec2 diff = neighbor + point - fract_uv;
			//diff /= ratio;
			float dist = distance(point_absolute, frag_absolute);
			dist = length(diff);
			if(dist < minimum_dist_A) {
				minimum_index_A = neighbor + index_uv;
				minimum_dist_B = minimum_dist_A;
				minimum_point_B = minimum_point_A;
				minimum_dist_A = dist;
				true_dist_A = distance(point_absolute, frag_absolute);
				minimum_point_A = index_uv + neighbor + point ;
			}else if(dist < minimum_dist_B) {
				minimum_dist_B = dist;
				minimum_point_B = index_uv + neighbor + point ;
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

void fragment() {
	// Called for every pixel the mateial is visible on.
	float ratio = VIEWPORT_SIZE.x/VIEWPORT_SIZE.y;
	float alpha = 0.0;
	float screen_y = 0.05;
	
	for(int i = 0; i < 5; i++){
		
		vec2 uv = vec2(
			SCREEN_UV.x * ratio,
			SCREEN_UV.y
			);
			
		uv += vec2(random(vec2(float(i)))  * ratio, random(vec2(float(i))));
			
		float distance_A;
		vec2 position_A;
		
		float distance_B;
		vec2 position_B;
		
		vec2 index_B;
		vec2 index_A;

		
		voronoise(uv, 5.0,5.0, 0.8, float(i), distance_A, position_A,index_A, distance_B, position_B,index_B);
		
		float culling = 1.0;//(random(index_A)>0.01? 1.0: 0.0);
		float ray = ((distance_A<0.01)?1.0:0.0);
		float fadingio = (fbm(index_A+vec2(TIME/10.0 + float(i)))*2.0-0.5);
		
		alpha += clamp(ray*culling*fadingio,0.0,1.0);
		//clamp((1.0-distance_A/0.1),max(0.15,(1.0-SCREEN_UV.y)*8.0-6.0) * 0.2,1.0);//(max(pow(SCREEN_UV.y,2) + pow(1.0-SCREEN_UV.y,2),0.1))*0.3;
	}
	
	ALPHA = max(alpha,screen_y);
	ALBEDO = vec3(1.0);
	//ALBEDO = vec3(0.8,0.8,1.0);
	////fadeformula
	////ALPHA = (5.0*(UV.y*UV.y))*(max(texture(noise, uva).a - texture(gradient, uva2).a, 0.2) )/ 2.0;
	//ALPHA = (max(texture(noise, uva).a - texture(gradient, uva2).a, 0.2) )/ 2.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
