shader_type spatial;
render_mode unshaded;
render_mode cull_disabled ; // disable backface culling, since those are the faces we want to render

void vertex() {}

void fragment() {
	// This material only shows its backface
	// The idea is to create and fill the outline of the object, while letting anything inside it
	// appear on top of it.
	if(FRONT_FACING) discard; // discard front facing faces
	ALBEDO = vec3(0.0);
}
