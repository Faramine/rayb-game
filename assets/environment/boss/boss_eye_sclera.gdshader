shader_type spatial;
render_mode unshaded;
render_mode cull_disabled ; // disable backface culling, since those are the faces we want to render

void vertex() {
}

void fragment() {
	ALBEDO = vec3(0.0);
}

