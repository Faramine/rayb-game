shader_type spatial;
render_mode unshaded;
render_mode cull_disabled ; // disable backface culling, since those are the faces we want to render

void vertex() {
	// Since this material makes front faces visible, clipping with other objects yields
	// unsightly results.
	// We prevent vertices from clipping with the floor by forcing them to remain above floor level
	VERTEX.y = max(VERTEX.y,-2.5);
	
}

void fragment() {
	// This material only shows its backface
	// The idea is to create and fill the outline of the object, while letting anything inside it
	// appear on top of it.
	if(FRONT_FACING) discard; // discard front facing faces
	ALBEDO = vec3(0.0);
}
