shader_type spatial;
render_mode unshaded;

const int stroke_n = 4;

uniform sampler2D ALPHA_TEXTURE : source_color;
uniform int stroke_index : hint_range(0, stroke_n-1);

void vertex() {
        vec3 world_origin = (MODEL_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
        float scale_x = length(MODEL_MATRIX[0].xyz);
        float scale_y = length(MODEL_MATRIX[1].xyz);
        vec3 cam_right = normalize(INV_VIEW_MATRIX[0].xyz);
        vec3 cam_up    = normalize(INV_VIEW_MATRIX[1].xyz);
		mat4 rotation_matrix = MODEL_MATRIX;
		rotation_matrix[0][3] = 0.0;
		rotation_matrix[1][3] = 0.0;
		rotation_matrix[2][3] = 0.0;
		rotation_matrix[3][0] = 0.0;
		rotation_matrix[3][1] = 0.0;
		rotation_matrix[3][2] = 0.0;
        vec2 local = (rotation_matrix * vec4(VERTEX,1.0)).xy;
        vec3 world_billboard = world_origin
            + cam_right * local.x
            + cam_up    * local.y;
        POSITION = PROJECTION_MATRIX * VIEW_MATRIX * vec4(world_billboard, 1.0);
}

void fragment() {
	// Called for every pixel the material is visible on.
	vec2 uv = vec2(UV.x, UV.y/float(stroke_n) + 1.0/float(stroke_n)*float(stroke_index));
	ALBEDO = vec3(0.0);
	ALPHA = texture(ALPHA_TEXTURE, uv).a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
