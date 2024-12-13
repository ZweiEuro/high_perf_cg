#[compute]
#version 450


// Invocations in the (x, y, z) dimension
layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

// A binding to the buffer we create in our script
layout(set = 0, binding = 0, std430)restrict buffer MainBolt {
	float data[];
}main_bolt;

layout(set = 0, binding = 1, std430)restrict buffer OutputData {
	float data[];
}output_data;

struct RootBolt {
	vec3 origin;
    vec3 direction;
    float len;
    float segment_count;
    float seed;
}root_bolt;


void fill_root_bolt() {
    root_bolt.origin = vec3(
        main_bolt.data[0],
        main_bolt.data[1],
        main_bolt.data[2]
    );
    root_bolt.direction = vec3(
        main_bolt.data[3],
        main_bolt.data[4],
        main_bolt.data[5]
    );
    root_bolt.len = main_bolt.data[6];
    root_bolt.segment_count = main_bolt.data[7];
    root_bolt.seed = main_bolt.data[8];
}


// generate a random float between 0 and 1
float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898,78.233)))*43758.5453123);
}


// The code we want to execute in each invocation
void main() {
    fill_root_bolt();

    output_data.data[0] = root_bolt.origin.x;
    output_data.data[1] = root_bolt.origin.y;
    output_data.data[2] = root_bolt.origin.z;




	// gl_GlobalInvocationID.x uniquely identifies this invocation across all work groups
	// main_bolt_input_data.data[gl_GlobalInvocationID.x] *= 2.0 * random(vec2(1,1));
}
