shader_type spatial;
render_mode depth_draw_never;

uniform sampler2D depth_texture : hint_depth_texture;

// We can use the transform here to 
uniform mat4 transform;

varying mat4 CAMERA;

void vertex() {
	CAMERA = INV_VIEW_MATRIX;
}

void fragment() {
	float depth = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth);
	vec4 view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	view.xyz /= view.w;
	float linear_depth = -view.z;
	vec4 world = CAMERA * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 world_p = world.xyz / world.w;
	
	mat3 basis_c = mat3(transform);
	vec3 position_c = transform[3].xyz;
	vec3 lengths = vec3(length(basis_c[0]), length(basis_c[1]), length(basis_c[2]));
	vec3 b = lengths * 0.5;
	mat3 rot = mat3(basis_c[0] / lengths.x, basis_c[1] / lengths.y, basis_c[2] / lengths.z);
	mat3 rot_inverse_c = inverse(rot);
	// Rect bounds
	
	// Calculate the distance to our cube surface - if negative
	// we are inside the cube.
	vec3 p_rel = rot_inverse_c * (world_p - position_c);
	// Now calculate the distance to the cube surface
	vec3 q = abs(p_rel) - b;
	float dist = length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
	if (dist >= 0.0) {
		ALPHA = 0.0;
	}
	// Calculate normal based on depth
	vec3 dx = dFdx(world_p);
	vec3 dy = dFdy(world_p);
	vec3 normal = normalize(cross(dx, dy));
	ALBEDO.rgb = vec3(1.0);
	NORMAL = abs(normal);
}
