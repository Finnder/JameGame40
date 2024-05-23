extends Node

@onready var all_upgrades = []
@onready var all_pillars = []

class Pillar:
	var name : String
	var description : float 
	var icon : Resource
	var souls_required : int
	var upgrades = []
	
func _ready():
	add_all()

func add_all():
	all_upgrades.append(load("res://Scripts/Global/Upgrades/dash_cooldown.gd"))
	all_upgrades.append(load("res://Scripts/Global/Upgrades/max_health.gd"))
	all_upgrades.append(load("res://Scripts/Global/Upgrades/increase_damage.gd"))
	
	all_pillars.append(load("res://Scripts/Global/Pillars/easy_pillar.gd"))

func get_random_upgrades(amount : int) -> Array:
	var out : Array = []
	for i in range(amount):
		var rng : int = randi_range(0, len(all_upgrades) - 1)
		if all_upgrades[rng] not in out:
			out.append(all_upgrades[rng])
		
	return out
	


