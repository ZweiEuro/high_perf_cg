shader_type spatial;
render_mode cull_disabled,blend_add,unshaded;

uniform vec3 color_blue : source_color =  vec3(0.2, 0.3, 0.8);
uniform vec3 color_white : source_color = vec3(1.0, 1.0, 1.0);
uniform float flicker_speed = 10.0;
uniform float blue_bias = 4.0; //higher = more blue vs white

uniform sampler3D noise_texture;

void vertex(){
	
}

void fragment() {
	/*
	
	vec3 world_pos = (inverse(MODEL_MATRIX) * inverse(VIEW_MATRIX) * vec4(VERTEX, 1.0)).xyz;
	//float color_thirds = smoothstep(-0.4, -0.2, world_pos.x) * (1.0 - smoothstep(0.2, 0.4, world_pos.x));

	// Alpha fade for glows
	float side_alpha = 1.0 - smoothstep(0.5, 1.0, abs(world_pos.x));


	//float flicker = (sin(TIME * flicker_speed) + 1.0) / 2.0; // [0-1]
    //flicker = pow(flicker, blue_bias);

	vec3 color = color_blue;
	if(world_pos.z>0.4){
		color = color_white;
	}
	if(world_pos.z<-0.4){
		color = vec3(1.0,0.0,0.0);
	}
	// mix(color_blue, color_white, color_thirds);

	vec3 noise = texture(noise_texture, world_pos * 0.5 + vec3(0.0, TIME * 0.2, 0.0)).rgb;
    // never have 0 brigthness -> otherwise random black flash
   float brightness = 1.0;//clamp(flicker, 0.2, 1.0);

	float alpha = side_alpha ;//* flicker;

	ALBEDO = color * brightness * noise.r; // Use red channel of noise
	EMISSION = color * brightness * noise.r * 2.0; // Glow effect
	ALPHA = alpha; //* noise.r; // Combine alpha with noise

}
void light() {
  //  DIFFUSE_LIGHT = color_white * 100.0; // optionally
*/
}
