shader_type sky;
uniform sampler3D noise : repeat_enable;

void sky() {
    if (!AT_CUBEMAP_PASS) {
        // Sets the radiance cubemap to a nice shade of blue instead of doing
        // expensive sky calculations
		vec3 eydir_time = EYEDIR;
		eydir_time.x = eydir_time.x + TIME/10.0;
        COLOR = vec3(0, 0, 1) + texture(noise, eydir_time).rgb;
    }
}