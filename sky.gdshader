shader_type sky;

uniform vec3 sky_color: source_color;
void sky() {
	COLOR = sky_color;
	FOG = vec4(0.15);
}
