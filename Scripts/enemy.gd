extends CharacterBody3D

@export var move_speed: float = 1.0  # Speed at which the object moves towards the player
@export var max_health: int = 4

@onready var health = max_health
var player

var in_pillar # ref to pillar

# Called when the node enters the scene tree for the first time.
func _ready():
	player = $"../../Player"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player:
		move_towards_player(delta)

func move_towards_player(delta):
	var player_position = player.global_transform.origin
	var current_position = global_transform.origin

	# Calculate the direction towards the player
	var direction = (player_position - current_position).normalized()

	# Move the object towards the player
	var movement = direction * move_speed * delta
	global_transform.origin += movement

func take_damage(dmg : int):
	health -= dmg
	if health <= 0:
		queue_free()
