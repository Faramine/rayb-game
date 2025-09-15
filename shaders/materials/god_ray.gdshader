shader_type spatial;
uniform sampler2D noise : repeat_enable;
uniform sampler2D gradient;
render_mode unshaded, depth_prepass_alpha;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the mateial is visible on.
	vec2 uva = UV;
	uva.x += TIME/100.0;
	uva.y = TIME/100.0;

	vec2 uva2 = UV;
	uva2.x = UV.y;
	uva2.y = 1.0;
	
	ALBEDO = vec3(1.0,1.0,0.85);
	//fadeformula
	//ALPHA = (5.0*(UV.y*UV.y))*(max(texture(noise, uva).a - texture(gradient, uva2).a, 0.2) )/ 2.0;
	ALPHA = (max(texture(noise, uva).a - texture(gradient, uva2).a, 0.2) )/ 2.0;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
