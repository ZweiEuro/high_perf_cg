shader_type spatial;

render_mode cull_disabled;
render_mode unshaded;

uniform vec3 effect_color: source_color = vec3(0.2, 0.3, 0.8);
varying vec3 position;

varying float lifetime;

void vertex(){
	lifetime = INSTANCE_CUSTOM.y;
	position = VERTEX;

	VERTEX.y += 0.5;

}

void fragment() {
    vec2 uv = 2.0 * UV - 1.0;

	ALPHA = pow(ALPHA, 4.0)  ;




	ALPHA = 1.0;
    ALBEDO = vec3(1.0, 0.0, 0.0);
/*
	float lifetime = COLOR.x; // 0 - 1
	float leftOverLifetime = 1.0 - lifetime * 2.0; // 0 - 1

	float y_normalized_position = (position.y + 1.0) / 2.0;

	if(y_normalized_position < leftOverLifetime){
		discard;
	}

	*/





}