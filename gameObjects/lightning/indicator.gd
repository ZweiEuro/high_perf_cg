extends Node3D

@export var triggerDuration_s: float = 1.0; # duration in seconds for it to grow
@export var singleFire: bool = false;

@export var actualScale: float = 1.0;

@onready var innerIndicator: CylinderMesh = $IndicatorInner.mesh
@onready var outerIndicator: CylinderMesh = $IndicatorOuter.mesh



@onready var startTime: float = Time.get_ticks_msec() / 1000.0; # time since start in seconds 

var indicatorInnerSize: float = 0.0;

func _ready() -> void:
	self.scale = Vector3(actualScale, actualScale, actualScale);
	
	innerIndicator.top_radius = 1;
	innerIndicator.bottom_radius = 1;

func _process(_delta: float) -> void:
	var now = Time.get_ticks_msec() / 1000.0;
	if now - startTime > triggerDuration_s:
		startTime = now;
	
	var newSize = lerpf(0.0, 1.0, (( now - startTime) / triggerDuration_s))
	
	innerIndicator.bottom_radius = newSize;
	innerIndicator.top_radius = newSize;
