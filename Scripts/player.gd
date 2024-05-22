extends CharacterBody3D

@export var speed: float = 10.0
@export var needle_speed: float = 70  # Base speed of the needle
@export var max_needle_speed: float = 200  # Maximum speed of the needle
@export var speed_increase_rate: float = 50  # Speed increase rate per second
@export var fire_rate: float = 0.5  # Time in seconds between shots
@export var dash_rate: float = 1
@export var dash_force: float = 1000  # Force applied during dash

var movement_direction: Vector3 = Vector3.ZERO
var target_position: Vector3 = Vector3.ZERO
var dash_impulse: Vector3 = Vector3.ZERO  # To store the dash impulse

var can_attack: bool = true
var can_dash: bool = true

@onready var camera : Camera3D = $"../Camera3D"
@onready var world : Node3D = $".."
@onready var fire_timer : Timer = Timer.new()
@onready var dash_timer : Timer = Timer.new()
@onready var raycast: RayCast3D = $Gun/RayCast3D
@onready var collision_shape_3d : CollisionShape3D = $MeleeAttackArea/CollisionShape3D
@onready var dash_trail = $DashTrail

var attackable_entities = {}
var melee_attack_dmg : float = 1
var input_dir = Vector3.ZERO

func _ready():
	dash_trail.hide()
	add_child(fire_timer)
	fire_timer.one_shot = true
	fire_timer.wait_time = fire_rate
	fire_timer.timeout.connect(func(): _on_fire_timer_timeout())
	
	add_child(dash_timer)
	dash_timer.one_shot = true
	dash_timer.wait_time = dash_rate
	dash_timer.timeout.connect(func(): _on_dash_timer_timeout())

func _physics_process(delta: float):
	update_input_direction()
	velocity = input_dir * speed + dash_impulse
	move_and_slide()

	rotate_to_mouse()

	# Reset dash impulse after applying it
	dash_impulse = Vector3.ZERO

	if Input.is_action_pressed("primary") and can_attack:
		attack()

	if Input.is_action_just_pressed("dash") and can_dash:
		dash()

func update_input_direction():
	input_dir = Vector3.ZERO
	if Input.is_action_pressed("move_up"):
		input_dir.z -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.z += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()

func dash():
	if can_dash:
		print("Dashed")
		can_dash = false
		dash_trail.show()
		jump_toward_input_direction(dash_force)
		dash_timer.start()

func jump_toward_input_direction(amount: float):
	if input_dir != Vector3.ZERO:
		dash_impulse = input_dir * amount

func jump_toward_cursor(amount: float):
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
		dash_impulse = direction * amount

func rotate_to_mouse():
	var mouse_pos : Vector2 = get_viewport().get_mouse_position()
	var ray_origin : Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_direction : Vector3 = camera.project_ray_normal(mouse_pos)
	
	var space_state = get_world_3d().direct_space_state
	var params : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	params.to = ray_origin + ray_direction * 1000
	params.from = ray_origin
	var result = space_state.intersect_ray(params)
	
	if result:
		var target_pos = result.position
		var direction = (target_pos - global_transform.origin).normalized()
		direction.y = 0  # Keep the rotation on the horizontal plane
		
		var new_rotation = Vector3(0, atan2(direction.x, direction.z), 0)
		rotation = new_rotation

func attack():
	for enemy in attackable_entities:
		if attackable_entities.get(enemy).has_method("take_damage"):
			attackable_entities.get(enemy).take_damage(melee_attack_dmg)

	can_attack = false
	fire_timer.start()

func _on_fire_timer_timeout():
	can_attack = true
	
func _on_dash_timer_timeout():
	can_dash = true
	dash_trail.hide()

func _on_melee_attack_area_body_entered(body):
	if body.is_in_group("enemies"):
		attackable_entities.merge({ body.name : body })	
		
func _on_melee_attack_area_body_exited(body):
	if body.is_in_group("enemies"):
		attackable_entities.erase(body.name)
