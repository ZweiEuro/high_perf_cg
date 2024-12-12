extends MeshInstance3D

@export var start_point_offset: Vector3 = Vector3(0, 1.0, 0);
@export var end_point_offset : Vector3
@export var n_segments: int
@export var jaggedness: float
@export var branch_chance: float
@export var max_branch_depth: int

@export var thickness: float = 0.1;

@onready var direction = (end_point_offset - start_point_offset).normalized()
@onready var segment_length = (end_point_offset - start_point_offset).length() / n_segments

@onready var rel_start_point : Vector3 = start_point_offset + self.position;
@onready var rel_end_point : Vector3 = end_point_offset + self.position;

@onready var self_remove_timer: Timer = Timer.new();

func offsetVector(vec: Vector3) -> Vector3:
	return vec + Vector3(1.0, 0, 0) * thickness

func append_quad(arr: Array, p1: Vector3) -> void:
	
	var tl: Vector3;
	var tr: Vector3;
	
	if arr.size() == 0:
		tl = p1;
		tr = offsetVector(p1);
	else:
		tl = arr[-3];
		tr = arr[-2];
	
	
	var bl = p1 + self.direction * self.segment_length;
	var br = offsetVector(bl);
	
	arr.append(tl);
	arr.append(tr);
	arr.append(bl);
	
	arr.append(bl);
	arr.append(br);
	arr.append(tr);
	
	

func _generate_lightning() -> Array:
	var main_bolt = Array()
	var branches = []

	append_quad(main_bolt, start_point_offset);
	
 
	for i in range(n_segments + 1):				
		var point = start_point_offset + direction * segment_length * i
					
		# random displacement 
		point += Vector3((randf()*2-1) * jaggedness, 0,(randf()*2-1) * jaggedness)
		
		append_quad(main_bolt, point);

		# branch check
		if i > 1 and randf() < branch_chance:
			var branch_count = randi() % 2 + 1  # 1-2 branches per point
			for j in range(branch_count):
				# Limit branch angles to stay near vertical -> don't know how, too tired to question
				var branch_dir = direction.rotated(Vector3.UP, randf() * 0.5 - 0.25).rotated(Vector3.RIGHT, randf() * 0.2 - 0.1)
				var branch_length = segment_length * randf() * 1.5
				# !!! v comment back in
				# branches.append(_generate_branch(point, branch_dir, branch_length, jaggedness * 0.5, 2, max_branch_depth - 1))

	return [main_bolt, branches]

func _generate_branch(base_point: Vector3, direction: Vector3, length: float, jaggedness: float, segments: int, depth: int) -> Array:
	var branch_points = Array()
	for i in range(segments + 1):
		var point = base_point + direction * length * (i / segments)
		
		point += Vector3((randf()*2-1) * jaggedness, 0,(randf()*2-1) * jaggedness)
		branch_points.append(point)

		# recursive branches 
		if depth > 0 and i > 1 and randf() < branch_chance:
			var sub_branch_dir = direction.rotated(Vector3.UP, randf() * 0.4 - 0.2).rotated(Vector3.RIGHT, randf() * 0.2 - 0.1)
			var sub_branch_length = length * randf() * 0.5
			branch_points.append_array(_generate_branch(point, sub_branch_dir, sub_branch_length, jaggedness * 0.5, segments, depth - 1))

	return branch_points

func create_mesh():
	var lightning_data = _generate_lightning() 
	var main_bolt = lightning_data[0]
	var branches = lightning_data[1]

	var mesh = ImmediateMesh.new()

	mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for point in main_bolt:
		mesh.surface_add_vertex(point)
	mesh.surface_end()
	
	print(main_bolt)
	
	self.mesh = mesh
	return;
	
	# Draw branches
	for branch in branches:
		mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
		for point in branch:
			mesh.surface_add_vertex(point)
		mesh.surface_end()

	self.mesh = mesh

func _ready():
	create_mesh()
	var lightning_material = ShaderMaterial.new()
	lightning_material.shader = load("res://alt_lightning/alt-lightning.gdshader")
	$".".material_override = lightning_material
	
	self_remove_timer.autostart = true;
	self_remove_timer.wait_time = 0.5;
	self_remove_timer.timeout.connect(delete_self);
	
	
	#add_child(self_remove_timer);
	

	

func delete_self() -> void:
	queue_free();
