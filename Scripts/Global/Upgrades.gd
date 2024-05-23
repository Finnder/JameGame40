extends Node

class Upgrade:
	var name : String
	var description : String
	var level : float
	var maxLevel : int
	var icon : Resource # image

	func apply_on_upgrade(player) -> void: pass

	func levelUp_Upgrade():
		level += 1
		level = clamp(level, 0, maxLevel)
