shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform float gray_ratio: hint_range(0, 1);

vec4 color_to_grayscale(vec4 col) {
	float gray = col.r * 0.299 + col.g * 0.587 + col.b * 0.114;
	return vec4(gray, gray, gray, 1);
}

void fragment() {
	vec4 screen_frag = textureLod(screen_texture, SCREEN_UV, 0.0);
    COLOR = color_to_grayscale(screen_frag) * gray_ratio + screen_frag * (1.0f - gray_ratio);
}