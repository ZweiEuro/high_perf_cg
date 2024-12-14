#[compute]
#version 450

#include "random.glsl"

layout (local_size_x = 5, local_size_y = 1, local_size_z = 1) in;

int worker_id = 0;

int jump_depth = 0;


// Invocations in the (x, y, z) dimension

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


int index = 0; // index of the current vertex in the output buffer
bool write_vec3_to_output(vec3 v) {
    int worker_start_index = (worker_id) * int(root_bolt.vertex_count_per_branch) * 3;
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


// add jittering later on
vec3 jitter(vec3 v) {
    return vec3(v);
}


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

    root_bolt.origin = jitter(root_bolt.origin);
}


vec3 getDirection(vec3 origin) {
    // the direction is always 
    // 45 degrees down and to the right from the origin
    if(origin == root_bolt.origin){
        return normalize(vec3(0, -1, 0));
    }
    return normalize(vec3(1, -1, 0));
}

int getBranchPointIndex(int depth) {
    return int(1.0 / pow(0.5, depth));
}


int getVerticeCountInBranch(int depth) {
    return int(root_bolt.vertex_count_per_branch * pow(0.5, depth));
}

float getSegmentLength(int depth) {
    // loose 20% of length per depth
    // remove the origin vertex from the count
    return (root_bolt.len * pow(0.2, depth)) / ((getVerticeCountInBranch(depth) -1) * pow(0.5, depth)); 
}

vec3 get_nth_point_of_bolt(vec3 origin, int depth, int n) {
    if(n == 0){
        return origin;
    }

    vec3 current_pos = origin;
    vec3 direction = getDirection(current_pos);
    float segment_length = getSegmentLength(depth);
    
    for(int i=0; i < n; i++){
        // jitter it until you hit n

        vec3 next_pos = current_pos + direction * segment_length;
        current_pos = jitter(next_pos);

    }

    return current_pos;
}

void create_branch(vec3 origin, int depth){

    for(int i = 0 ; i <= getVerticeCountInBranch(depth); i++){
        vec3 v = get_nth_point_of_bolt(origin, depth, i);
        if(write_vec3_to_output(v) == false){
            return;
        }
    }   
    return;
}

int get_nth_branch_point_index_for_worker(int depth, int n){

    int total_num_workers = int(gl_WorkGroupSize.x);

    int first_branch_point_index = getBranchPointIndex(depth);

    int index_between_points = first_branch_point_index * total_num_workers;

    int worker_start_index = worker_id * first_branch_point_index;

    int ret = worker_start_index + index_between_points * n;

    if(ret >= getVerticeCountInBranch(depth)){
        return -1;
    }

    return ret;
}

// The code we want to execute in each invocation
void main() {
    fill_root_bolt();

    worker_id = int(gl_GlobalInvocationID.x);

    // if i am the main work group, i make the root bolt
    
    if(worker_id == 0){
        create_branch(root_bolt.origin, 0);
        return;
    }

    // if i am not the main work group, i make a branch

    for(int i = 0; ;i++){
        int branch_index = get_nth_branch_point_index_for_worker(1, i);
        if(branch_index == -1){
            return;
        }

        create_branch(get_nth_point_of_bolt(root_bolt.origin, 1, branch_index), 1);    
    }

    return;

}
