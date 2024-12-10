shader_type spatial;

render_mode cull_disabled;

uniform vec3 effect_color: source_color = vec3(0.2, 0.3, 0.8);
uniform int octave_count: hint_range(1, 20) = 10;
uniform float amp_start = 0.5;
uniform float amp_coeff = 0.5;
uniform float freq_coeff = 2.0;
uniform float speed = 0.5;
uniform vec2 direction = vec2(1.0, 0.0); // New uniform for direction


uniform float thickness = 1.0;
uniform bool billboard = false;

float hash12(vec2 x) {
    return fract(cos(mod(dot(x, vec2(13.9898, 8.141)), 3.14)) * 43758.5453);
}

vec2 hash22(vec2 uv) {
    uv = vec2(dot(uv, vec2(127.1,311.7)),
              dot(uv, vec2(269.5,183.3)));
    return 2.0 * fract(sin(uv) * 43758.5453123) - 1.0;
}

float noise(vec2 uv) {
    vec2 iuv = floor(uv);
    vec2 fuv = fract(uv);
    vec2 blur = smoothstep(0.0, 1.0, fuv);
    return mix(mix(dot(hash22(iuv + vec2(0.0,0.0)), fuv - vec2(0.0,0.0)),
                   dot(hash22(iuv + vec2(1.0,0.0)), fuv - vec2(1.0,0.0)), blur.x),
               mix(dot(hash22(iuv + vec2(0.0,1.0)), fuv - vec2(0.0,1.0)),
                   dot(hash22(iuv + vec2(1.0,1.0)), fuv - vec2(1.0,1.0)), blur.x), blur.y) + 0.5;
}

float fbm(vec2 uv, int octaves) {
    float value = 0.1;
    float amplitude = amp_start;
    for (int i = 0; i < octaves; i++) {
        value += amplitude * noise(uv);
        uv *= freq_coeff;
        amplitude *= amp_coeff;
    }
    return value;
}

varying vec3 position;

void vertex(){
	if(billboard){
		    mat4 modified_model_view = VIEW_MATRIX * mat4(
        INV_VIEW_MATRIX[0],
        INV_VIEW_MATRIX[1],
        INV_VIEW_MATRIX[2],
        MODEL_MATRIX[3]
    );
    MODELVIEW_MATRIX = modified_model_view;
	}

	COLOR.x = INSTANCE_CUSTOM.y;
	position = VERTEX;
}

void fragment() {
    vec2 uv = 2.0 * UV - 1.0;

    // Normalize the direction and use it to transform the UV coordinates
    vec2 norm_direction = normalize(direction);
    uv = mat2(
		vec2(norm_direction.x, -norm_direction.y),
		vec2(norm_direction.y, norm_direction.x)
		) * uv;

    uv += 2.0 * fbm(uv + TIME * speed, octave_count) - 1.0;

    float dist = abs(uv.x) / thickness;
    vec3 color = effect_color * mix(0.0, 0.05, hash12(vec2(TIME))) / dist;
    ALBEDO = color;

	ALPHA = mix(0.0, 0.05, hash12(vec2(TIME))) / dist;


	ALPHA = pow(ALPHA, 4.0)  ;


	float lifetime = COLOR.x; // 0 - 1
	float leftOverLifetime = 1.0 - lifetime * 2.0; // 0 - 1

	float y_normalized_position = (position.y + 1.0) / 2.0;

	if(y_normalized_position < leftOverLifetime){
		discard;
	}





}