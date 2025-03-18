extends Control

@onready var tower_list = $TowerList
@onready var friendlies = $"../../Friendlies"
@onready var player = $"../../Friendlies/Player"

const TOWER = preload("res://Scenes/FriendlyTowers/tower.tscn")

const FAST_TURRET = preload("res://Scenes/FriendlyTowers/fast_turret.tscn")
const SPEEDBOOST_TOWER = preload("res://Scenes/FriendlyTowers/speedboost_beacon.tscn")
const REGENERATION_TOWER = preload("res://Scenes/FriendlyTowers/regeneration_beacon.tscn")

const TOWERS = [FAST_TURRET, SPEEDBOOST_TOWER, REGENERATION_TOWER]
const PRICES = [10,20,20]

const BUILDHEIGHT = 30
const TOWERHEIGHT = 48

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

func _on_tower_list_item_clicked(index, _at_position, _mouse_button_index):
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
	else:
		print("BUILDING IN OCCUPIED SPACE!")
