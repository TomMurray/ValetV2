shader_type spatial;
render_mode cull_disabled, blend_add, shadows_disabled, specular_disabled, unshaded;

uniform vec4 base_colour;
varying vec3 xyz;

void vertex() {
	xyz = COLOR.rgb;
}

void fragment() {
	ALBEDO.rgb = base_colour.rgb;
	ALPHA = base_colour.a * (1.0 - xyz.y);
}
