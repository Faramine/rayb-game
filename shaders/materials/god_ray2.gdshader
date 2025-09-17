shader_type spatial;
//uniform sampler2D noise : repeat_enable;
render_mode unshaded, depth_prepass_alpha;
void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALPHA = max(0.05,(1.0-SCREEN_UV.y)*1.0-0.8);
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
