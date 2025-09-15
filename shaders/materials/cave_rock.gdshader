shader_type spatial;
render_mode unshaded;

const vec2 surface_dimensions = vec2(10.0,4.0);

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
	out float distance_A, out vec2 position_A,
	out float distance_B, out vec2 position_B,
) {
	vec2 ratio = vec2(columns,rows);

	vec2 index_uv = floor(vec2(uv.x * ratio.x, uv.y * ratio.y));
	vec2 fract_uv = fract(vec2(uv.x * ratio.x, uv.y * ratio.y));

	//distance_A = random(index_uv);
	//return;

	float minimum_dist_A = 1.0;
	float true_dist_A;
	vec2 minimum_point_A;

	float minimum_dist_B = 1.0;
	vec2 minimum_point_B;

	int range = 1;
	for (int y= -range; y <= range; y++) {
		for (int x= -range; x <= range; x++) {
			vec2 neighbor = vec2(float(x),float(y));
			vec2 point = (vec2(1.0-variance/2.0)) + random2(index_uv + neighbor) * variance;

			vec2 point_absolute = point / ratio + neighbor / ratio;
			vec2 frag_absolute = fract_uv / ratio;
			vec2 diff = neighbor + point - fract_uv;
			//diff /= ratio;
			float dist = distance(point_absolute, frag_absolute);
			dist = length(diff);
			if(dist < minimum_dist_A) {
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
	distance_B = minimum_dist_B;
	position_B = minimum_point_B;

	return;
}

void rockLayerTexture(
	in vec2 uv,
	in vec2 cell_dimensions,
	in float frequency,
	in vec2 height_range,
	
	out vec3 normal,
	out vec3 displacement,
	out vec3 albedo,
	out float alpha){
		
	float distance_A;
	vec2 position_A;
	float distance_B;
	vec2 position_B;

	voronoise(uv-vec2(0.0,0.8), surface_dimensions.x/cell_dimensions.x, surface_dimensions.y/cell_dimensions.y, 0.8, distance_A, position_A, distance_B, position_B);

	float thickness = 0.1;
	thickness *= fbm(uv*0.5)*2.5;

	float thickness_ratio = clamp(random(position_A + position_B),0.0,1.0);
	//thickness *= thickness_ratio;
	float diff = abs(distance_B - distance_A);
	float is_present = (random(position_A) < frequency)?1.0:0.0;
	float high_filter = (position_A.y > 0.0)?1.0:0.0;
	
	float min_height = height_range.x;
	float max_height = height_range.y;
	float height_factor = random(position_A);
	float slope = diff/thickness;
	slope = clamp(slope,0.0,1.0);
	float height = height_factor * (max_height-min_height) + min_height;
	
	float edge_space_width = 0.05;
	float edge_space =  clamp((diff - edge_space_width)*20.0 +0.5,0.0,1.0);
	vec2 edge_xy_normal = normalize(position_B-position_A);
	
	float final_height = height * is_present * high_filter * (edge_space);
	albedo = vec3(diff*is_present);
	//albedo = vec3(position_A.y);
	albedo = vec3(0.03,0.03,0.05)*10.0;

	if(edge_space > 0.0 && edge_space <= 0.9){
		normal = vec3(edge_xy_normal.x, edge_xy_normal.y, 0.0);
	}else if(edge_space > 0.9){
		normal = vec3(0.0,0.0,1.0);
	}else{
		normal = vec3(0.0,0.0,1.0);
	}

	//albedo = vec3(edge_space);
	alpha = high_filter * is_present;
	//displacement = vec3(final_height+diff*0.5*is_present);
	displacement = vec3(final_height);
	return;
	

	vec3 voronoi_normal = normalize(vec3(normalize((position_B-position_A)),1.0));
	//displacement = vec3((is_edge==1.0)?diff*vec3(0.0,0.0,0.0):vec3(0.0,0.0,0.1));
	displacement = vec3(height);

	albedo = vec3(0.01,0.01,0.05);
	albedo = mix(vec3(0.09,0.09,0.09)*0.0,vec3(0.09,0.09,0.12)*1.8,dot(normal,normalize(vec3(0.1,-1.0,1.0))));

	//albedo = vec3(is_edge);
	//albedo = vec3(distance_A);
	//albedo = vec3(thickness_ratio);
	//albedo = vec3(random(position_A + position_B));
	//albedo = vec3(fbm(uv*vec2(10.0,2.0)*0.1));
	//albedo = voronoi_normal;
	return;
}

void blendLayers(
	in vec3 layer_normal,
	in vec3 layer_displacement,
	in vec3 layer_albedo,
	in float layer_alpha,
	
	inout vec3 final_normal,
	inout vec3 final_displacement,
	inout vec3 final_albedo,
	inout float final_alpha
){
	if(layer_displacement.x > final_displacement.x){
		final_normal = layer_normal;
		final_displacement = layer_displacement;
		final_albedo = layer_albedo;
		final_alpha = layer_alpha;
	}

			
	return;
}

void rockTexture(in vec2 uv, out vec3 normal,
	out vec3 displacement,
	out vec3 albedo,
	out float alpha){
		vec3 final_normal;
		vec3 final_displacement;
		vec3 final_albedo;
		float final_alpha;
		{
			vec3 layer_normal;
			vec3 layer_displacement;
			vec3 layer_albedo;
			float layer_alpha;

			rockLayerTexture(uv,
			vec2(10.0,5.0), 0.3, vec2(0.5,0.7),
			layer_normal, layer_displacement, layer_albedo, layer_alpha);
			
			blendLayers(
				layer_normal,
				layer_displacement,
				layer_albedo,
				layer_alpha,
				
				final_normal,
				final_displacement,
				final_albedo,
				final_alpha
			);
		}
		
		if(true){
			vec3 layer_normal;
			vec3 layer_displacement;
			vec3 layer_albedo;
			float layer_alpha;

			rockLayerTexture(uv,
			vec2(10.0,5.0), 1.0, vec2(0.05,0.1),
			layer_normal, layer_displacement, layer_albedo, layer_alpha);
			
			blendLayers(
				layer_normal,
				layer_displacement,
				layer_albedo,
				layer_alpha,
				
				final_normal,
				final_displacement,
				final_albedo,
				final_alpha
			);
		}
		
		normal = final_normal;
		displacement = final_displacement;
		albedo = final_albedo;
		alpha = final_alpha;
	}

void vertex() {
	vec3 normal;
	vec3 displacement;
	vec3 albedo;
	float alpha = 1.0;
	vec2 luv = UV*surface_dimensions;
	rockTexture(luv, normal, displacement, albedo, alpha);

	float is_edge = (UV.x == 0.0 || UV.x == 1.0 || UV.y == 0.0 || UV.y == 1.0)?1.0:0.0;

	vec3 baseNormal = NORMAL;
	vec3 displacementVector = baseNormal * displacement.z * (1.0-is_edge);

	VERTEX = VERTEX + displacementVector;
}

void fragment() {
	vec3 normal;
	vec3 displacement;
	vec3 albedo;
	float alpha = 1.0;
	vec2 luv = UV*surface_dimensions;
	rockTexture(luv, normal, displacement, albedo, alpha);
	/*
	vec3 kernelpos;
	vec3 deltaXpos;
	vec3 deltaYpos;
	const float epsilon = 0.1;
	{
		vec2 deltaXluv = luv+vec2(epsilon,0.0);
		vec3 deltaXdisp;
		rockTexture(deltaXluv, normal, deltaXdisp, albedo, alpha);
		deltaXpos = vec3(deltaXluv.x,deltaXluv.y,deltaXdisp.x);
	}
	{
		vec2 deltaYluv = luv+vec2(0.0,epsilon);
		vec3 deltaYdisp;
		rockTexture(deltaYluv, normal, deltaYdisp, albedo, alpha);
		deltaYpos = vec3(deltaYluv.x,deltaYluv.y,deltaYdisp.x);
	}
	kernelpos = vec3(luv.x,luv.y,displacement.x);
	vec3 computedNormal = normalize(cross(deltaXpos - kernelpos, deltaYpos - kernelpos));*/

	ALBEDO = albedo;
	ALPHA = alpha;
	ALBEDO = albedo * dot(normal, normalize(vec3(0.0,-1.0,0.5)));
	//ALBEDO = computedNormal;
	NORMAL = normal;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
