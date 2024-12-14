#[compute]
#version 450

#include "random.glsl"


int worker_id = 0;

int jump_depth = 0;


// Invocations in the (x, y, z) dimension
layout(local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

// A binding to the buffer we create in our script
layout(set = 0, binding = 0, std430)restrict buffer MainBolt {
	float data[];
}main_bolt;

layout(set = 0, binding = 1, std430) writeonly buffer OutputData {
	float data[];
}output_data;

struct RootBolt {
	vec3 origin;
    vec3 direction;
    float len;
    float seed;
    float vertex_count_per_branch;
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
    root_bolt.seed = main_bolt.data[7];
    root_bolt.vertex_count_per_branch = main_bolt.data[8];

    setState(root_bolt.seed);
}

// add jittering later on
vec3 jitter(vec3 v) {
    return vec3(v);
}


vec3 get_nth_point_of_bolt(vec3 origin, vec3 direction, int depth, float n) {
    if(n == 0){
        return origin;
    }


    vec3 current_pos = origin;


    float segment_length = (root_bolt.len * pow(0.2, depth)) / root_bolt.vertex_count_per_branch; // loose 20% of length per depth
    
    for(int i=0; i < n; i++){
        // jitter it until you hit n

        vec3 next_pos = current_pos + direction * segment_length;
        current_pos = jitter(next_pos);

    }

    return current_pos;

}


int index = 0; // index of the current vertex in the output buffer
bool write_vec3_to_output(vec3 v) {
    int worker_start_index = worker_id * int(root_bolt.vertex_count_per_branch) * 3;
    int worker_max_index = worker_start_index + int(root_bolt.vertex_count_per_branch) * 3;


    if(index >= worker_max_index) {
        return false;
    }

    output_data.data[worker_start_index + index] = v.x;
    output_data.data[worker_start_index + index + 1] = v.y;
    output_data.data[worker_start_index + index + 2] = v.z;
    index += 3;

    return true;
}

// The code we want to execute in each invocation
void main() {
    fill_root_bolt();

    worker_id = int(gl_GlobalInvocationID.x);

    // if i am the main work group, i make the root bolt
    
    if(worker_id == 0){
        for(int i =0 ; i <= root_bolt.vertex_count_per_branch; i++){
            vec3 v = get_nth_point_of_bolt(root_bolt.origin, root_bolt.direction, 0, i);
            if(write_vec3_to_output(v) == false) {
                break;
            }
        }
        return;
    }

    if(worker_id == 1){

        write_vec3_to_output(vec3(-1,-2,-3));

    }

    
    




    
	// gl_GlobalInvocationID.x uniquely identifies this invocation across all work groups
	// main_bolt_input_data.data[gl_GlobalInvocationID.x] *= 2.0 * random(vec2(1,1));
}
