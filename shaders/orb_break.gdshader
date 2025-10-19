shader_type spatial;
render_mode unshaded;
uniform sampler2DArray animation;

float random(vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) *
            42758.5453523);
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
    int octaves = 1;
	float amplitude = 0.5;
    float famplitude = 0.0;
    float frequency = 20.0;
	float value = 0.0;

    for(int i = 0; i < octaves; i++) {
        value += amplitude * noise(frequency * uv);
		famplitude += amplitude;
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    return value / famplitude;
}

const float repeat_start = 14.0;
const float repeat_end = 17.0;

varying float frame;
varying float nframe;

void vertex() {
	// Called for every vertex the material is visible on.
	nframe = INSTANCE_CUSTOM.w * 12.0;
	frame = floor(mod((INSTANCE_CUSTOM.y * nframe),nframe));
	nframe -= mod(nframe-27.0,4.0);
	if(frame >= 14.0 && frame < nframe-27.0+17.0)
		frame = 14.0 + mod(frame - 14.0, 4.0);
	else if (frame >= nframe-27.0+17.0)
		frame = 27.0 - (nframe - frame);
	VERTEX.x += ((VERTEX.y) * .25* (VERTEX.x)) + (fbm(vec2(VERTEX.y* 0.01 + TIME * 0.05))-0.5) * 10.0 * (VERTEX.y / 12.5);
}

void fragment() {
	vec2 uv = UV;
	uv.y = uv.y*2.0;
	if (uv.y > 1.0) discard;
	
	ALPHA = texture(animation,vec3(uv,frame)).a;
	ALBEDO = texture(animation,vec3(uv,frame)).xyz;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
