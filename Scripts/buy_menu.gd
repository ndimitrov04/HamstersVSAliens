extends Control

@onready var item_list = $ItemList
@onready var friendlies = $"../../Friendlies"
@onready var player = $"../../Friendlies/Player"

const FAST_TURRET = preload("res://Scenes/FriendlyTowers/fast_turret.tscn")
const TOWER = preload("res://Scenes/FriendlyTowers/tower.tscn")
const SPEEDBOOST_TOWER = preload("res://Scenes/FriendlyTowers/speedboost_tower.tscn")
const REGENERATION_TOWER = preload("res://Scenes/FriendlyTowers/regeneration_tower.tscn")

const BUILDINGS = [FAST_TURRET, TOWER, SPEEDBOOST_TOWER, REGENERATION_TOWER]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func _on_item_list_item_clicked(index, at_position, mouse_button_index):
	if player.build_spot.building == null:
		var building = BUILDINGS[index].instantiate()
		friendlies.add_child(building)
		building.global_position = player.build_spot.global_position + Vector3(0,30,0)
		player.build_spot.building = building
		building.build_spot = player.build_spot
	else:
		print("BUILDING IN OCCUPIED SPACE!")
