extends Control

@onready var hud = $".."
@onready var tower_list = $TowerList
@onready var friendlies = $"../../Friendlies"
@onready var player = $"../../Friendlies/Player"
@onready var upgrade_menu = $"../UpgradeMenu"

@onready var sfx = $SFX

const TOWER = preload("res://Scenes/FriendlyTowers/tower.tscn")

const FAST_TURRET = preload("res://Scenes/FriendlyTowers/fast_turret.tscn")
const PREDICTIVE_TURRET = preload("res://Scenes/FriendlyTowers/predictive_turret.tscn")
const SPEEDBOOST_TOWER = preload("res://Scenes/FriendlyTowers/speedboost_beacon.tscn")
const REGENERATION_TOWER = preload("res://Scenes/FriendlyTowers/regeneration_beacon.tscn")
const SHIELD_BEACON = preload("res://Scenes/FriendlyTowers/shield_beacon.tscn")
const SLOWDOWN_BEACON = preload("res://Scenes/FriendlyTowers/slowdown_beacon.tscn")

const TOWERS = [FAST_TURRET, PREDICTIVE_TURRET, SPEEDBOOST_TOWER, REGENERATION_TOWER, SHIELD_BEACON, SLOWDOWN_BEACON]
const PRICES = [35,75,80,150,70,100]

const BUILDHEIGHT = 30
const TOWERHEIGHT = 49

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	#If an item is too expensive, make it unselectable
	for i in range(0,tower_list.item_count):
		if player.gold < PRICES[i]:
			tower_list.set_item_disabled(i, true)
		else:
			tower_list.set_item_disabled(i, false)

func _on_tower_list_item_clicked(index, _at_position, mouse_button_index):
	if mouse_button_index == MOUSE_BUTTON_LEFT:
		if player.build_spot.building == null:
			#Spawn tower
			var tower = TOWER.instantiate()
			friendlies.add_child(tower)
			tower.global_position = player.build_spot.global_position + Vector3(0,BUILDHEIGHT,0)
			#Spawn turret/beacon on top of tower
			var building = TOWERS[index].instantiate()
			friendlies.add_child(building)
			building.global_position = player.build_spot.global_position + Vector3(0,TOWERHEIGHT,0)
			player.build_spot.building = building
			building.build_spot = player.build_spot
			building.tower = tower
			player.gold -= PRICES[index]
			hide()
			hud.upgrade_menu.upgrade_description_1.text = building.upgrade_description_1
			hud.upgrade_menu.upgrade_description_2.text = building.upgrade_description_2
			hud.upgrade_menu.upgrade_button_1.text = "Upgrade: " + str(building.upgrade_cost_1) + "G" 
			hud.upgrade_menu.upgrade_button_2.text = "Upgrade: " + str(building.upgrade_cost_2) + "G" 
			upgrade_menu.show()
			sfx.play()
		else:
			print("BUILDING IN OCCUPIED SPACE!")
