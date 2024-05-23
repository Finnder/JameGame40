extends Upgrades.Upgrade

var amountToRemove : float = 0.1

func _init() -> void:
	name = "Dash Cooldown Reduction"
	level = 1
	maxLevel = 5
	description = "Reduce dash cooldown by 0.1 seconds"

func apply_on_upgrade(player):
	if level >= maxLevel: return
	super.levelUp_Upgrade()
	player.dash_rate -= amountToRemove
	print("Dash Rate Is Now -> " + str(player.dash_rate))
