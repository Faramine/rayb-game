shader_type sky;
uniform sampler3D noise : repeat_enable;

void sky() {
    if (!AT_CUBEMAP_PASS) {
        // Sets the radiance cubemap to a nice shade of blue instead of doing
        // expensive sky calculations
		vec3 eydir_time = EYEDIR;
		eydir_time.x = eydir_time.x + TIME/100.0;
		eydir_time.y = eydir_time.y + TIME/100.0;
		eydir_time.z = eydir_time.z + TIME/100.0;
		vec3 eydir_time2 = EYEDIR;
		eydir_time2.x = eydir_time2.x - TIME/100.0;
		eydir_time2.y = eydir_time2.y - TIME/100.0;
		eydir_time2.z = eydir_time2.z - TIME/100.0;
        COLOR = vec3(0, 0, 0) + texture(noise, eydir_time).rgb * texture(noise, eydir_time2).rgb;
    }
}