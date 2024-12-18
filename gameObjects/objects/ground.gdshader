shader_type spatial;

uniform sampler2D diffuse;

void fragment() {
	vec3 text = texture(diffuse,UV).xyz;
	ALBEDO = text; 
}