extends CharacterBody3D

# Stats
@export var max_health = 10
@onready var current_health = max_health
@export var speed: float = 10.0
@export var fire_rate: float = 0.5  # Time in seconds between hitting
@export var dash_rate: float = 1
@export var dash_force: float = 1000  # Force applied during dash
@export var life_steal_percentage : float = 0.01 # percentage of damage
@export var health_regen_per_sec : float = 0.1
@export var second_chances = 0 # revive on death with half health
@export var damage_to_deal : float = 1.0

# Movement 
var movement_direction: Vector3 = Vector3.ZERO
var target_position: Vector3 = Vector3.ZERO
var dash_impulse: Vector3 = Vector3.ZERO  # To store the dash impulse

# Bools
var can_attack: bool = true
var can_dash: bool = true

@onready var camera : Camera3D = $"../Camera3D"
@onready var world : Node3D = $".."
@onready var fire_timer : Timer = Timer.new()
@onready var dash_timer : Timer = Timer.new()
@onready var collision_shape_3d : CollisionShape3D = $MeleeAttackArea/CollisionShape3D
@onready var dash_trail = $DashTrail
@onready var attack_sprites : Node3D = $AttackSprites

var attackable_entities = {}
var input_dir = Vector3.ZERO

func _ready():
	attack_sprites.hide()
	dash_trail.hide()
	add_child(fire_timer)
	fire_timer.one_shot = true
	fire_timer.wait_time = fire_rate
	fire_timer.timeout.connect(func(): _on_fire_timer_timeout())
	
	add_child(dash_timer)
	dash_timer.one_shot = true
	dash_timer.wait_time = dash_rate
	dash_timer.timeout.connect(func(): _on_dash_timer_timeout())

func _physics_process(_delta: float):
	
	if Input.is_action_pressed("primary") and can_attack:
		attack()

	if Input.is_action_just_pressed("dash") and can_dash:
		dash()

	update_input_direction()
	rotate_to_mouse() 	
	
	velocity = input_dir * speed + dash_impulse
	move_and_slide()

	# Reset dash impulse after applying it
	dash_impulse = Vector3.ZERO

func update_input_direction():
	input_dir = Vector3()
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
	
	# Extended the raycast length and ensure it interacts with the floor layer
	var space_state = get_world_3d().direct_space_state
	var params : PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
	params.to = ray_origin + ray_direction * 10000  # Adjust distance as needed
	params.from = ray_origin
	params.collision_mask = 1

	var result = space_state.intersect_ray(params)
	
	if result:
		var target_pos = result.position
		var direction = (target_pos - global_transform.origin).normalized()
		direction.y = 0  # Keep the rotation on the horizontal plane
		
		var new_rotation = Vector3(0, atan2(direction.x, direction.z), 0)
		rotation = new_rotation
	else:
		# Rotate based on raycast extending to its full length if no hit
		var target_pos = ray_origin + ray_direction * 1000  # Use the full length of the ray
		var direction = (target_pos - global_transform.origin).normalized()
		direction.y = 0
		var new_rotation = Vector3(0, atan2(direction.x, direction.z), 0)
		rotation = new_rotation


func attack():
	attack_sprites.show()
	rotate_to_mouse()
	jump_toward_cursor(50)
	
	for enemy in attackable_entities:
		if attackable_entities.get(enemy).has_method("take_damage"):
			attackable_entities.get(enemy).take_damage(damage_to_deal)

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
		
func take_damage(amount : int):
	current_health -= amount
	if current_health <= 0 and second_chances <= 0:
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")
	elif current_health <= 0 and second_chances > 0:
		second_chances -= 1
		current_health = max_health / 2
		
		
	
