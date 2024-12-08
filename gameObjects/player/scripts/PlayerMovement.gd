# This script just deals with player movement, camera movement is in the CamOrigin script.

extends CharacterBody3D

var movement_velocity = 10.0
var jump_velocity = 10.0
var turn_speed = 30

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var dash_charges = 3
var dash_velocity: float = 50
var dash_duration: float = 0.5    # how long the dash should be eased over in seconds
var dash_cooldown: float = 5.0;
var timestamp_last_dash: float = 0.0 # the last time dash was pushed 

var last_direction: Vector3 = Vector3(0.5, 0, 0.5).normalized();

var parent

@onready var cam_h = $"../CamOrigin/h"
@onready var cam_v = $"../CamOrigin/h/v"

func _ready():
	# set mouse mode captured so it locks in middle of screen
	capture_mouse()
	
	# set parent
	parent = get_parent()

func _unhandled_key_input(event: InputEvent) -> void:
	# if "exit" (esc) is pressed, close game
	if Input.is_action_just_pressed("Exit"):
		get_tree().quit()
	if Input.is_action_just_pressed("Reset"):
		position = Vector3(0, 5, 0)
	

func _process(delta):
	# set parent position to equal CharacterBody position every frame
	parent.position = position
	pass

# from https://easings.net/#easeOutExpo
func easeOutExpo(x: float)-> float:
	if x == 1:
		return 1.0
	else:
		return 1.0 - 2.0 ** (-10.0 * x)

func _physics_process(delta):
	# turn player inputs into a vector
	var input_dir = Input.get_vector("Player left", "Player right", "Player Forward", "Player Back")
	
	# use input_dir movement vector to know which direction the player is facing, depending on the camera rotation 
	# put .normalized() at the end of this line if you don't want the player to be able to slow walk using joystick
	var direction: Vector3 = (cam_h.transform.basis * Vector3(input_dir.x, 0, input_dir.y))
	
	var velocity_total = velocity; # change the current velocity
	
	# if playerBody isn't on the floor, activate gravity
	# vertical movement
	if not is_on_floor():
		velocity_total.y -= gravity * delta
	elif Input.is_action_just_pressed("Player jump"):
		# Alow jumping when not on floor
		velocity_total.y += jump_velocity# direction of 'up'  is irrelevant here (it would also be zero  

	if direction:
		# save direction for later
		last_direction = direction;
		
		# change player model rotation
		rotation.y = lerp_angle(rotation.y, atan2(-direction.x, -direction.z), turn_speed * delta)
		
		# player horizontal movement
		velocity_total.x = direction.x * movement_velocity
		velocity_total.z = direction.z * movement_velocity
		# dashing
		
		var now_ticks_in_s = Time.get_ticks_msec() / 1000.0;
		
		if Input.is_action_just_pressed("Dash"):
			if timestamp_last_dash == 0 || (now_ticks_in_s - timestamp_last_dash)  > dash_cooldown:				
				timestamp_last_dash = now_ticks_in_s
				$"DustParticleSpawner".emitting = true
		
		var time_since_dash_start = now_ticks_in_s - timestamp_last_dash
		
			
		if timestamp_last_dash != 0 && time_since_dash_start < dash_duration:
			# the dash is still ongoing
			var dash_progress = time_since_dash_start / dash_duration # 0 - 1 of how far the dash has progressed
			var dash_scale = 1.0 - easeOutExpo(dash_progress);
			velocity_total.x += direction.x *  dash_velocity * dash_scale
			velocity_total.z += direction.z *  dash_velocity * dash_scale
	
		
	else:
		# if no direction input, make sure player is still
		velocity_total.x = move_toward(velocity.x, 0, movement_velocity)
		velocity_total.z = move_toward(velocity.z, 0, movement_velocity)
	
	velocity = velocity_total
	move_and_slide()

func getDirection() -> Vector3:
	return last_direction;



func capture_mouse():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func release_mouse():
	# not used anywhere in this demo, but you probably will want to run this func for menus and stuff
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
