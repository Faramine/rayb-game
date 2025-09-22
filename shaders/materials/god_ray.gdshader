shader_type spatial;
//uniform sampler2D noise : repeat_enable;
render_mode unshaded,cull_back;

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
    int octaves = 2;
	float amplitude = 0.5;
    float famplitude = 0.0;
    float frequency = 10.0;
	float value = 0.0;

    for(int i = 0; i < octaves; i++) {
        value += amplitude * noise(frequency * uv);
		famplitude += amplitude;
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value / famplitude;
}

void voronoise(vec2 uv, float size, float variance, float seed, float speed,
	out float distance_A, out vec2 position_A, out vec2 index_A
) {
	vec2 ratio = vec2(size,size);
	vec2 index_uv = floor(vec2(uv.x * ratio.x, uv.y * ratio.y));
	vec2 fract_uv = fract(vec2(uv.x * ratio.x, uv.y * ratio.y));

	float minimum_dist_A = 2.0;
	vec2 minimum_point_A;
	vec2 minimum_index_A;

	int range = 1;
	for (int y= -range; y <= range; y++) {
		for (int x= -range; x <= range; x++) {

			vec2 neighbor = vec2(float(x),float(y));

			vec2 time_offset = vec2(
				fbm(random2(index_uv + neighbor + seed + 42.0) * TIME * speed),
				fbm(random2(index_uv + neighbor - seed - 42.0) * TIME * speed)
				);
			vec2 point = variance * time_offset + vec2((1.0 - variance)*0.5);

			vec2 diff = neighbor + point - fract_uv;
			float dist = length(diff);

			if(dist < minimum_dist_A) {
				minimum_index_A = neighbor + index_uv;
				minimum_dist_A = dist;
				minimum_point_A = index_uv + neighbor + point ;
			}
		}
	}

	distance_A = minimum_dist_A;
	position_A = minimum_point_A;
	index_A = minimum_index_A;

	return;
}

varying vec4 NODE_POSITION_CLIP;

void vertex() {
	VERTEX.z += (fbm(vec2(VERTEX.y - TIME * 0.01)) * 0.3) - 0.15;
	NODE_POSITION_CLIP = (PROJECTION_MATRIX * vec4(NODE_POSITION_VIEW, 1.0));
}

void fragment() {
	//Parametters
	float ratio = VIEWPORT_SIZE.x/VIEWPORT_SIZE.y;
	vec2 local_uv = (SCREEN_UV * 2.0 - 1.0) * NODE_POSITION_CLIP.w - NODE_POSITION_CLIP.xy;
	float screen_y = 0.05;
	float speed = 0.01;
	int layers = 3;
	float size = 0.025;
	float r = 0.7 * size;

	float distance_A;
	vec2 position_A;
	vec2 index_A;
	vec2 uv;

	float culling;
	float ray;
	float fadingio;
	float alpha = 0.0;

	for(int i = 0; i < layers; i++){

		uv = vec2(
			local_uv.x * ratio,
			local_uv.y
			);

		uv += vec2(
			random(vec2(float(i))) * ratio,
			random(vec2(float(i) + 10.0))
			)* NODE_POSITION_CLIP.w;

		voronoise(uv, size, 1.0, float(i), speed,
			 distance_A, position_A, index_A
		);

		culling = (random(index_A + float(i)) > 0.5 ?
			1.0 : 0.0 );

		ray = ((distance_A<r) ?
			1.0 : 0.0 );

		fadingio = ( fbm(index_A + vec2( TIME/20.0 + float(i) ) ) * 2.0 - 0.7 );

		alpha += clamp( ray * culling * fadingio, 0.0, 1.0);
	}
	ALBEDO = vec3(1.0);
	ALPHA = max(alpha, screen_y);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
