shader_type spatial;
render_mode cull_disabled, blend_add;

uniform vec3 color_blue : source_color =  vec3(0.2, 0.3, 0.8);

uniform float flicker_speed = 2.0;
uniform float emission_energy : hint_range(1.0, 100.0, 0.01);

uniform float total_model_height: hint_range(1, 100);

float random (vec2 uv) {
    return fract(sin(dot(uv.xy,
        vec2(12.9898,78.233))) * 43758.5453123);
}

float easeInExpo(float x) {
	if(x == 0.0){
		return 0.0;
	}else{
		return pow(2, 10.0 * x -10.0);
	}
}

void vertex() {
}


void fragment() {
	
	vec3 model_pos = (inverse(MODEL_MATRIX) * inverse(VIEW_MATRIX) * vec4(VERTEX, 1.0)).xyz;

	// Alpha fade for glows
	float side_alpha = 1.0 - smoothstep(0.5, 1.0, abs(UV.x));	
	
	float cutoff_point = 1.0;
	float scale = easeInExpo(cutoff_point - abs(UV.x));
	
	vec3 color = mix(color_blue, vec3(1.0),  scale);
	

	float time_offset = TIME + TAU * COLOR.x;
	
	float flicker = ((sin(time_offset * flicker_speed) + 1.0) / 2.0) + 0.1; // [0-1]
	
	float offset = (abs(model_pos.y) / total_model_height);
	float rolldown = ((sin((time_offset + offset) * 10.0) + 1.0) / 2.0) + 0.1; // [0-1]
	
	ALBEDO = color; // Use red channel of noise
	float alpha = side_alpha * rolldown; 
	ALPHA = clamp(alpha, 0.2 ,1.0);
		
	EMISSION = color_blue * emission_energy;
	
	ALBEDO =  COLOR.xyz;
}
