extends Upgrades.Upgrade

var amount = 1

func _init() -> void:
	name = "Strength Sirum"
	level = 1
	maxLevel = 10
	description = "Increase base damage by " + str(amount)
	icon = load("res://Assets/Images/BloodSplat.png")

func update():
	amount = 1 * level

func apply_on_upgrade(player):
	if level >= maxLevel: return
	super.levelUp_Upgrade()
	update()
	player.damage_to_deal = amount
