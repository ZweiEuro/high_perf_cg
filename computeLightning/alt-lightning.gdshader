shader_type spatial;
render_mode cull_disabled;

uniform vec3 color_blue : source_color = vec3(0.2, 0.3, 1.0); 
uniform vec3 color_white : source_color = vec3(1.0, 1.0, 1.0); 
uniform float flicker_speed = 10.0;
uniform float blue_bias = 4.0; //higher = more blue vs white

void fragment() {
	float flicker = (sin(TIME * flicker_speed) + 1.0) / 2.0; // [0-1]
    flicker = pow(flicker, blue_bias);

    vec3 color = mix(color_blue, color_white, flicker);

    // never have 0 brigthness -> otherwise random black flash
    float brightness = clamp(flicker, 0.2, 1.0);

    ALBEDO = color * brightness;
   	EMISSION = color * brightness * 3.0; //glows
}
