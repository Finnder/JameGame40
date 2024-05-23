extends Upgrades.Upgrade

var amountGain : int

func _init() -> void:
	name = "Max health"
	level = 1
	maxLevel = 5
	amountGain = 10
	icon = load("res://Assets/UI/Icons/140.png")
	description = "Increase max health by 10%"

func apply_on_upgrade(player):
	if level >= maxLevel: return
	super.levelUp_Upgrade()
	player.max_health += amountGain
	print("Max Health Is Now -> " + str(player.maxHealth))
