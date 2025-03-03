extends Node3D

#Enemies
@onready var UFO = preload("res://Scenes/Enemies/ufo.tscn")
@onready var SPACESHIP3 = preload("res://Scenes/Enemies/spaceship3.tscn")

@onready var enemies = $Enemies
@onready var level_data = $HUD/LevelData

@onready var player = $Player

const MAPRADIUS = 512
const SKYBOUNDS = [20,35]

var currentWave : int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	level_data.text = (
		"Current Wave: " + str(currentWave) + "\n" +
		"Enemies Left: " + str(enemies.get_child_count())
	)
	if enemies.get_child_count() <= 0:
		newWave()

func newWave():
	currentWave += 1
	for i in range(0, currentWave * 5):
		var enemy = SPACESHIP3.instantiate()
		enemies.add_child(enemy)
		enemy.global_position = Vector3(
			randf_range(-MAPRADIUS,MAPRADIUS),
			randf_range(SKYBOUNDS[0],SKYBOUNDS[1]),
			randf_range(-MAPRADIUS,MAPRADIUS)
			)
