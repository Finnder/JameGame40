extends Camera3D

@onready var player = $"../Player"
@export var smoothing_factor: float = 0.1  # Lower values make the camera smoother

var fixed_height: float  # Fixed Y position for the orthographic camera

func _ready():
	fixed_height = global_transform.origin.y  # Initialize fixed height to current camera height

func _process(delta):
	if player:
		# Calculate the new position using a spring-like smoothing method
		var target_position = player.global_transform.origin
		var current_position = global_transform.origin
		
		# Only smooth the X and Z coordinates
		current_position.x += (target_position.x - current_position.x) * smoothing_factor
		current_position.z += (target_position.z - current_position.z + 9) * smoothing_factor
		
		# Keep the Y position fixed
		current_position.y = fixed_height
		
		global_transform.origin = current_position
