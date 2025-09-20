shader_type canvas_item;

uniform sampler2D screen : hint_screen_texture;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec3 c = vec3(10.0,10.0,10.0)	*  texture(screen,SCREEN_UV).xyz;
	COLOR.xyz = c*c*c*c;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
