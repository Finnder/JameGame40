extends Camera2D

@export var achievements_x_pos = 0
@export var settings_x_pos = 0
@export var speed = 1

@export var moving_to_achievements = false
@export var moving_to_settings = false

func _process(delta):
	if moving_to_achievements:
		while position.x < achievements_x_pos:
			position.x += 1
			
		moving_to_achievements = false
			
	elif moving_to_settings:
		while position.x > settings_x_pos:
			position.x -= 1
		
		moving_to_achievements = false
