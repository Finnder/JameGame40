extends Control

@onready var main_scene_path : String = "res://Scenes/main.tscn"
@onready var camera_2d = $Camera2D

func _on_begin_button_pressed():
	get_tree().change_scene_to_file(main_scene_path)


func _on_achievements_button_pressed():
	camera_2d.moving_to_achievements = true


func _on_settings_button_pressed():
	camera_2d.moving_to_settings = true


func _on_exit_button_pressed():
	get_tree().quit()
