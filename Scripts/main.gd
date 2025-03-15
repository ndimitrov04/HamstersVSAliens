extends Node3D

#Enemies
@onready var UFO = preload("res://Scenes/Enemies/ufo.tscn")
@onready var SEEKER = preload("res://Scenes/Enemies/spaceship3.tscn")
@onready var DESTROYER = preload("res://Scenes/Enemies/spaceship1.tscn")
@onready var CARRIER = preload("res://Scenes/Enemies/carrier.tscn")

@onready var enemies = $Enemies
@onready var level_data = $HUD/LevelData

@onready var player = $Friendlies/Player
@onready var level_up = $HUD/LevelUp

const MAPRADIUS = 500
const SKYBOUNDS = [20,35]

var current_wave : int = 0
var enemy_pool

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(1).timeout
	enemy_pool = [UFO, SEEKER, DESTROYER, CARRIER]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	level_data.text = (
		"Current Wave: " + str(current_wave) + "\n" +
		"Enemies Left: " + str(enemies.get_child_count())
	)
	if enemies.get_child_count() <= 0:
		new_wave()

func new_wave():
	level_up.initiate_upgrade_phase()
	current_wave += 1
	for i in range(0, current_wave * 5):
		var enemy = enemy_pool[randi_range(1,enemy_pool.size()-1)].instantiate()
		enemies.add_child(enemy)
		enemy.global_position = Vector3(
			randf_range(-MAPRADIUS,MAPRADIUS),
			randf_range(SKYBOUNDS[0],SKYBOUNDS[1]),
			randf_range(-MAPRADIUS,MAPRADIUS)
			)
