extends MeshInstance3D

@export var start_point : Vector3 
@export var end_point : Vector3
@export var n_segments: int
@export var jaggedness: float
@export var branch_chance: float
@export var max_branch_depth: int


func _generate_lightning() -> Array:
	var main_bolt = Array()
	var branches = []

	var direction = (end_point - start_point).normalized()
	var segment_length = (end_point - start_point).length() / n_segments

	for i in range(n_segments + 1):
		var point = start_point + direction * segment_length * i
		
		# random displacement 
		point += Vector3((randf()*2-1) * jaggedness, 0,(randf()*2-1) * jaggedness)
		main_bolt.append(point)

		# branch check
		if i > 1 and randf() < branch_chance:
			var branch_count = randi() % 2 + 1  # 1-2 branches per point
			for j in range(branch_count):
				# Limit branch angles to stay near vertical -> don't know how, too tired to question
				var branch_dir = direction.rotated(Vector3.UP, randf() * 0.5 - 0.25).rotated(Vector3.RIGHT, randf() * 0.2 - 0.1)
				var branch_length = segment_length * randf() * 1.5
				branches.append(_generate_branch(point, branch_dir, branch_length, jaggedness * 0.5, 2, max_branch_depth - 1))

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

	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	
	for point in main_bolt:
		mesh.surface_add_vertex(point)
	mesh.surface_end()

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
	
