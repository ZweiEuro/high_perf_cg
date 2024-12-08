extends Node

@export var spawningInterval: float = 0.05; # period in seconds
@export var spawningIntervalRandomNoise: float = 0.5;

@export var spawnRadius: float = 5.0;

var indicator = preload("res://gameObjects/lightning/indicator.tscn");

@onready var timer := Timer.new();
@onready var player := $"../Player"

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.autostart = true;
	timer.one_shot = true;
	timer.wait_time = spawningInterval;
	timer.timeout.connect(_on_timer_timeout)

	add_child(timer)
	

func restartSpawner() -> void:
	var nextTimeoutTime = spawningInterval + randf_range(-spawningIntervalRandomNoise, spawningIntervalRandomNoise);
	timer.start(nextTimeoutTime)
	
	print(nextTimeoutTime)


func get_random_pos_around_center(center: Vector3, radius: float) -> Vector3:
	# get a planar Vec3 in a random direction
	# var	dir: Vector3 = player.getCurrentForwardDirection();
	
	# get a random direction
	var dir = Vector3(randf_range(-0.5, 0.5), 0, randf_range(-0.5, 0.5)).normalized();
		
	# make it a minimum radius away from the player
	return center + dir * randf_range(0.5, radius) * randf();
	
func _on_timer_timeout() -> void:
	
	var newChild: Node3D = indicator.duplicate().instantiate();
	var newPos =  get_random_pos_around_center(player.position, spawnRadius);
	newChild.position = newPos;
	add_child(newChild);
	restartSpawner();

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
