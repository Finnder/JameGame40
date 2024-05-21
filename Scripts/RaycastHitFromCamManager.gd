extends Node3D

@onready var camera : Camera3D = $"../Camera3D"
@export var target_color : Color = Color(1, 1, 1)

# Function to handle input events
func _input(event):
	pass
	#if event is InputEventMouseButton and event.pressed:
		#if event.button_index == MOUSE_BUTTON_LEFT:
			#handle_mouse_click(event.position)

# Function to handle mouse click
func handle_mouse_click(mouse_position: Vector2):
	var from = camera.project_ray_origin(mouse_position)
	var to = from + camera.project_ray_normal(mouse_position) * 1000
	
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = get_world_3d().direct_space_state.intersect_ray(query)
	
	if result:
		var clicked_object = result.collider
		if clicked_object is StaticBody3D:
			clicked_object_clicked(clicked_object)


func clicked_object_clicked(clicked_object):
	print("Clicked " + clicked_object.name)
	if clicked_object.name == "Pillar":
		if clicked_object.can_click:
			clicked_object.on_click()
