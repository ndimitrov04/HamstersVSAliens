extends Control

@onready var panel = $Panel
@onready var label = $Label
@onready var upgrade_description_1 = $UpgradeDescription1
@onready var upgrade_button_1 = $UpgradeButton1
@onready var upgrade_description_2 = $UpgradeDescription2
@onready var upgrade_button_2 = $UpgradeButton2

@onready var friendlies = $"../../Friendlies"
@onready var player = $"../../Friendlies/Player"

@onready var sfx = $SFX

var upgradable_tower = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if upgradable_tower != null:
		if player.gold < upgradable_tower.upgrade_cost_1:
			upgrade_button_1.disabled = true
		else:
			upgrade_button_1.disabled = false
		if player.gold < upgradable_tower.upgrade_cost_2:
			upgrade_button_2.disabled = true
		else:
			upgrade_button_2.disabled = false

func _on_upgrade_button_1_pressed():
	upgradable_tower.upgrade1()
	player.gold -= upgradable_tower.upgrade_cost_1
	hide()
	sfx.play()

func _on_upgrade_button_2_pressed():
	upgradable_tower.upgrade2()
	player.gold -= upgradable_tower.upgrade_cost_2
	hide()
	sfx.play()
