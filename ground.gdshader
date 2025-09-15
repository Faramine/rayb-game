shader_type spatial;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	ALBEDO = vec3(0.1,0.0,0.1);
}

void light() {
	DIFFUSE_LIGHT += dot(NORMAL, LIGHT) * ATTENUATION * ALBEDO;
	vec3 H = normalize(VIEW + LIGHT);
	float NdotH = max(0, dot(NORMAL, H));
	float specular = pow(NdotH, 2.0) * 0.5 * ATTENUATION;
	SPECULAR_LIGHT += specular * vec3(0.0,0.0,0.0);
}
