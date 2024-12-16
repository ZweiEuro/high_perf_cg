extends MeshInstance3D

@export var start_point_offset: Vector3 = Vector3(0, 1.0, 0);
@export var end_point_offset : Vector3
@export var n_segments: int
@export var jaggedness: float
@export var branch_chance: float
@export var max_branch_depth: int

@export var thickness: float = 0.1;

@onready var main_bolt_direction = (end_point_offset - start_point_offset).normalized()
@onready var segment_length = (end_point_offset - start_point_offset).length() / n_segments

@onready var rel_start_point : Vector3 = start_point_offset + self.position;
@onready var rel_end_point : Vector3 = end_point_offset + self.position;

@onready var main_bolt = Array()
@onready var bolt_uvs = Array();

@export var lifetime: float = 0.2;

@onready var start_time = Time.get_ticks_msec()

func offsetVector(vec: Vector3) -> Vector3:
	return vec + Vector3(1.0, 0, 0) * thickness

func append_quad(arr: Array, p1: Vector3, direction: Vector3) -> void:
	
	var tl: Vector3;
	var tr: Vector3;
	
	if arr.size() == 0:
		tl = p1;
		tr = offsetVector(p1);
	else:
		tl = arr[-3];
		tr = arr[-1];
	
	
	var bl = p1 + direction * self.segment_length;
	var br = offsetVector(bl);
	
	arr.append(tl);
	bolt_uvs.append(Vector2(-1, 1));
	arr.append(tr);
	bolt_uvs.append(Vector2(1, 1));
	arr.append(bl);
	bolt_uvs.append(Vector2(-1, -1));
	
	arr.append(bl);
	bolt_uvs.append(Vector2(-1, -1));
	arr.append(tr);
	bolt_uvs.append(Vector2(1, 1));
	arr.append(br);
	bolt_uvs.append(Vector2(1, -1));
	
	

func jitter_point(point: Vector3) ->Vector3:
	return point + Vector3((randf()*2-1) * jaggedness, 0,(randf()*2-1) * jaggedness)


func generate_main_bolt() -> void:
	var branches = []
	append_quad(main_bolt, start_point_offset, main_bolt_direction);
	
	for i in range(n_segments + 1):				
		var point = start_point_offset + main_bolt_direction * segment_length * i
					
		# random displacement 
		point += Vector3((randf()*2-1) * jaggedness, 0,(randf()*2-1) * jaggedness)
		
		append_quad(main_bolt, point, main_bolt_direction);
	


func generate_branch(branch_point: Vector3, depth = self.max_branch_depth) -> void:
	if depth <= 0:
		return;
	
	var branch: Array = [];
	var branch_dir = main_bolt_direction.rotated(Vector3.UP, randf() * 0.5 - 0.25).rotated(Vector3.RIGHT, randf() * 0.2 - 0.1)
	
	append_quad(branch, branch_point, branch_dir);
	
	for i in range(3):
		var next_point = branch_point + branch_dir * segment_length;
		next_point = jitter_point(next_point);
	
		append_quad(branch, next_point, branch_dir);

	self.main_bolt += branch

func generate_branches() -> void:
	for i in range(0, main_bolt.size(), 6):
		if randf() < branch_chance:
			# actually branch
			generate_branch(main_bolt[i]);
		

func _process(_delta):
	$OmniLight3D.position = lerp(start_point_offset,Vector3(0.0, 0.1, 0.0),(Time.get_ticks_msec() - start_time)/(lifetime*1000.0))


func create_mesh():
	var mesh = ImmediateMesh.new()
	
	generate_main_bolt() 
	generate_branches();
	
	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)

	var randId = Color(randf(),randf(),randf())

	for point_i in range(0, main_bolt.size()):
		var pos = main_bolt[point_i];
		var uv = bolt_uvs[point_i];
	
		mesh.surface_set_uv(uv);
		mesh.surface_set_color(randId);
		
		mesh.surface_add_vertex(pos)
	mesh.surface_end()
	
	self.mesh = mesh

func _ready():
	create_mesh()
	var lightning_material = ShaderMaterial.new()
	lightning_material.shader = load("res://alt_lightning/alt-lightning.gdshader")
	lightning_material.set_shader_parameter("total_model_height", 5);
	#lightning_material.shader = load("res://alt_lightning/hashlightning.gdshader")

	
	self.material_override = lightning_material
	
	
	$OmniLight3D.position = self.start_point_offset;
	
	
	
	
	



	

func delete_self() -> void:
	queue_free();
