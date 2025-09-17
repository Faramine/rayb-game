shader_type spatial;
//uniform sampler2D noise : repeat_enable;
//uniform sampler2D gradient;
render_mode unshaded, depth_prepass_alpha, world_vertex_coords;

varying float y_model;

void vertex() {
	y_model = VERTEX.y / 25.0 ;
}

void fragment() {
	// Called for every pixel the mateial is visible on.
	ALBEDO = vec3(0.85,0.85,1.0)*25.0;
	ALPHA = max(0.15,(1.0-SCREEN_UV.y)*8.0-7.0) * 0.1;//(max(pow(SCREEN_UV.y,2) + pow(1.0-SCREEN_UV.y,2),0.1))*0.3;
	
	
	//ALBEDO = vec3(0.8,0.8,1.0);
	////fadeformula
	////ALPHA = (5.0*(UV.y*UV.y))*(max(texture(noise, uva).a - texture(gradient, uva2).a, 0.2) )/ 2.0;
	//ALPHA = (max(texture(noise, uva).a - texture(gradient, uva2).a, 0.2) )/ 2.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
