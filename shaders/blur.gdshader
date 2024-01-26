shader_type canvas_item;

uniform float lod : hint_range(0.0, 5.0) = 0.0;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

void fragment() {
	// Called for every pixel the material is visible on.
	COLOR = textureLod(screen_texture, SCREEN_UV, lod);
}
