shader_type spatial;
render_mode unshaded;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, repeat_disable, filter_nearest;
uniform vec4 outline_color : source_color;
uniform float outline_width = 10.0;
uniform bool constant_width = true;

void fragment() {
	vec4 pixelatedtext = texture(SCREEN_TEXTURE, SCREEN_UV);
	vec2 pixel_size = 1.0 / VIEWPORT_SIZE;
	ALBEDO = pixelatedtext.rgb;
	ALPHA = 1.0;
	for(int y = -1*int(outline_width); y <= 1*int(outline_width); y++)
	for(int x = -1*int(outline_width); x <= 1*int(outline_width); x++)
	{
		vec4 tex = texture(DEPTH_TEXTURE, SCREEN_UV + vec2(float(x),float(y)) * pixel_size );
		if(tex.x == 0.0 && SCREEN_UV.x + float(x) * pixel_size.x < 1.0 && SCREEN_UV.x + float(x) * pixel_size.x > 0.0 && SCREEN_UV.y + float(y) * pixel_size.y < 1.0 && SCREEN_UV.y + float(y) * pixel_size.y > 0.0)
		{
			ALBEDO = outline_color.rgb;
			ALPHA = 1.0;
		}
	}
	ALBEDO = (texture(DEPTH_TEXTURE, SCREEN_UV + vec2(10.0,0.0) * pixel_size).r > 0.0)?vec3(1.0):vec3(0.0);
	ALBEDO = pixelatedtext.rgb;
	DEPTH = 1.0;
}