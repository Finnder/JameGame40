extends CharacterBody3D

@export var speed: float = 10.0
@export var needle_speed: float = 70  # Base speed of the needle
@export var max_needle_speed: float = 200  # Maximum speed of the needle
@export var speed_increase_rate: float = 50  # Speed increase rate per second
@export var fire_rate: float = 0.5  # Time in seconds between shots

var movement_direction: Vector3 = Vector3.ZERO
var target_position: Vector3 = Vector3.ZERO
var can_shoot: bool = true

@onready var camera = $"../Camera3D"
@onready var world = $".."
@onready var fire_timer = Timer.new()
@onready var raycast: RayCast3D = $Gun/RayCast3D

func _ready():
	add_child(fire_timer)
	fire_timer.one_shot = true
	fire_timer.wait_time = fire_rate
	fire_timer.timeout.connect(func(): _on_fire_timer_timeout())

func get_input_direction() -> Vector3:
	var input_dir = Vector3.ZERO
	if Input.is_action_pressed("move_up"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	
	return input_dir.normalized()

func _physics_process(delta: float):
	movement_direction = get_input_direction()
	velocity = movement_direction * speed
	move_and_slide()
	rotate_to_mouse()

	# Check for mouse button press to shoot needle
	if Input.is_action_pressed("primary") and can_shoot:
		shoot_needle()

func rotate_to_mouse():
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_origin = camera.project_ray_origin(mouse_pos)
	var ray_direction = camera.project_ray_normal(mouse_pos)
	
	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.to = ray_origin + ray_direction * 1000
	params.from = ray_origin
	var result = space_state.intersect_ray(params)
	
	if result:
		var target_pos = result.position
		var direction = (target_pos - global_transform.origin).normalized()
		direction.y = 0  # Keep the rotation on the horizontal plane
		
		var new_rotation = Vector3(0, atan2(direction.x, direction.z), 0)
		rotation = new_rotation

func shoot_needle():

	if raycast.is_colliding():
		var collider = raycast.get_collider()
		print(raycast.get_collider())
		if collider.is_in_group("enemies"):
			print("Hit an enemy: ", collider.name)
			if collider.has_method("take_damage"):
				collider.take_damage(1)
				

	# Start the fire rate timer and disable shooting until it times out
	can_shoot = false
	fire_timer.start()


func _on_fire_timer_timeout():
	can_shoot = true
