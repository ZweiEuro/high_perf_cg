extends Node3D

var fork_chance: float = 0.2;
var length_ratio_each_fork: float = 0.2;



# Create a local rendering device.
var rd := RenderingServer.create_local_rendering_device()

# Load GLSL shader
var shader_file := load("res://computeLightning/compute_lighting.glsl")
var shader_spirv: RDShaderSPIRV = shader_file.get_spirv()
var shader := rd.shader_create_from_spirv(shader_spirv)


class lightning:
	var origin: Vector3
	var direction: Vector3
	var length: float
	var segment_count: float;
	var seed: float
	
@onready var main_bolt: lightning = lightning.new();

var bolt_rid: RID;
var output_array_rid: RID;

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		rd.free_rid(bolt_rid);
		rd.free_rid(output_array_rid)

func create_lightning_uniform() -> RDUniform:
	# create the data necessary, its smarter to do this in a packed array
	var buffer:= PackedFloat32Array([
			main_bolt.origin.x, main_bolt.origin.y, main_bolt.origin.z,
			main_bolt.direction.x, main_bolt.direction.y, main_bolt.direction.z,
			main_bolt.length,
			main_bolt.segment_count,
			main_bolt.seed])
			
	var buffer_bytes := buffer.to_byte_array()
	# Create a storage buffer that can hold our float values.
	# Each float has 4 bytes (32 bit) so 10 x 4 = 40 bytes
	bolt_rid = rd.storage_buffer_create(buffer_bytes.size(), buffer_bytes)	
	
	var uniform := RDUniform.new()
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER;
	uniform.binding = 0 # this needs to match the "binding" in our shader file
	uniform.add_id(bolt_rid)
	
	return uniform;
	
			
func create_output_uniform(branch_vertex_count: float = 1000) -> RDUniform:
	var uniform := RDUniform.new()
	
	var buffer:= PackedFloat32Array()
	buffer.resize(branch_vertex_count * 3); # this needs ALL data in a block, needs * branch count
	buffer.fill(0);
			
	var buffer_bytes := buffer.to_byte_array()
	# Create a storage buffer that can hold our float values.
	# Each float has 4 bytes (32 bit) so 10 x 4 = 40 bytes
	output_array_rid = rd.storage_buffer_create(buffer_bytes.size(), buffer_bytes)	
	
	uniform.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER;
	uniform.binding = 1 # this needs to match the "binding" in our shader file
	uniform.add_id(output_array_rid)
	
	return uniform;
			
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.main_bolt.direction = Vector3(0,-1,0);
	self.main_bolt.length = 10;
	self.main_bolt.origin = Vector3(0, 5, 0);
	self.main_bolt.segment_count = 2;
	self.main_bolt.seed = Time.get_ticks_msec() % 1000;
	
	# Create a uniform to assign the buffer to the rendering device
	var bolt_uniform = create_lightning_uniform();
	var output_uniform = create_output_uniform()
	
	# the last parameter (the 0) needs to match the "set" in our shader file
	var uniform_set := rd.uniform_set_create(
		[bolt_uniform, output_uniform],
		 shader, 0)

	# Create a compute pipeline
	var pipeline := rd.compute_pipeline_create(shader)
	var compute_list := rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(compute_list, pipeline)
	rd.compute_list_bind_uniform_set(compute_list, uniform_set, 0)
	rd.compute_list_dispatch(compute_list, 1, 1, 1)
	rd.compute_list_end()
	
	# Submit to GPU and wait for sync
	rd.submit()
	rd.sync() # usually done after 2-3 frames
	
	# Read back the data from the buffer
	var output_bytes := rd.buffer_get_data(output_array_rid)
	var output := output_bytes.to_float32_array()
	print("Input: ", main_bolt)
	print("Output: ", output)



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
