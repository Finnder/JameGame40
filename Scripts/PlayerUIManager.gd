extends Control

@onready var health_bar = $HealthBar
@onready var upgrades = $Upgrades
@onready var upgrades_panel = $Upgrades/UpgradesPanel
@onready var upgrades_v_box_container = $Upgrades/UpgradesPanel/UpgradesVBoxContainer

var button_to_ability_map = {}

func update_ui(pillar : Pillars.Pillar):
	for upgrade in pillar.upgrades:
		pass



