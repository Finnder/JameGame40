extends StaticBody3D

@onready var circle_notifier : MeshInstance3D = $CircleNotifier
@onready var line_mesh_instance : MeshInstance3D = $LineMeshInstance
@onready var player: CharacterBody3D = $"../../Player"

@export var pillar_color : Color

var tween : Tween
var can_click : bool = false
var selected : bool = false
var player_in_zone : bool = false

@onready var sprite_circle = $CircleNotifier/Sprite3D

@onready var default_color : Color = $Model/DollBody.get_active_material(0).albedo_color

func _ready():
	tween = get_tree().create_tween()
	sprite_circle.modulate = pillar_color
	sprite_circle.modulate.a = 0.1

func select_doll():
	selected = true
	for child in $Model.get_children():
		if child is MeshInstance3D:
			change_material_color(child, pillar_color)

func deselect_doll():
	selected = false
	for child in $Model.get_children():
		if child is MeshInstance3D:
			change_material_color(child, default_color)

func on_click():
	if !selected:
		select_doll()
	else:
		deselect_doll()

# Function to change the material color of a MeshInstance3D
func change_material_color(mesh_instance, color):
	var material = mesh_instance.get_surface_override_material(0)
	if material is StandardMaterial3D:
		material.albedo_color = color
	else:
		material = StandardMaterial3D.new()
		material.albedo_color = color
		mesh_instance.set_surface_override_material(0, material)

func _on_area_3d_body_entered(body):
	if body.name == "Player":
		print("player entered zone")
		tween.stop()
		tween.tween_property(circle_notifier.get_surface_override_material(0), "albedo_color:a", 1.0, 1)
		circle_notifier.show()
		select_doll()
		player_in_zone = true

func _on_area_3d_body_exited(body):
	if body.name == "Player":
		print("player exited zone")
		tween.stop()
		tween.tween_property(circle_notifier.get_surface_override_material(0), "albedo_color:a", 0.0, 1)
		circle_notifier.hide()
		deselect_doll()
		player_in_zone = false

func change_material_transparency(material: StandardMaterial3D, duration: float, target: float):
	if material is StandardMaterial3D:
		tween.tween_property(material, "albedo_color:a", target, duration)
	else:
		print("Material is not a StandardMaterial3D or is invalid")

func _process(delta):
	if player_in_zone:
		DebugDraw3D.draw_line(global_position, player.position, Color.WHITE)
		
