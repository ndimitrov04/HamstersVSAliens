extends Node3D

#Enemies
@onready var UFO = preload("res://Scenes/Enemies/ufo.tscn")
@onready var SEEKER = preload("res://Scenes/Enemies/spaceship3.tscn")
@onready var DESTROYER = preload("res://Scenes/Enemies/spaceship1.tscn")
@onready var CARRIER = preload("res://Scenes/Enemies/carrier.tscn")
@onready var RUSHER = preload("res://Scenes/Enemies/rusher.tscn")
@onready var SHIELDER = preload("res://Scenes/Enemies/shielder.tscn")

@onready var enemies = $Enemies

@onready var player = $Friendlies/Player
@onready var level_up = $HUD/LevelUp
@onready var hud = $HUD
@onready var next_wave = $NextWave

@onready var world_environment = $WorldEnvironment
@onready var directional_light_3d = $DirectionalLight3D

const MAPRADIUS = 500
const SKYBOUNDS = [20,35]

var current_wave : int = 0
var enemy_pool

var sun_rotation_x : float = 290
#var sun_speed : float = 0.00001
var sun_speed : float = 0.1
#var sun_speed : float = 0.005

# Called when the node enters the scene tree for the first time.
func _ready():
	print("START IN 1")
	await get_tree().create_timer(1).timeout
	print("START")
	enemy_pool = [UFO, SEEKER, DESTROYER, RUSHER, SHIELDER, CARRIER]
	directional_light_3d.rotation_degrees.x = -120

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	hud.level_data.text = (
		"Current Wave: " + str(current_wave) + "\n" +
		"Enemies Left: " + str(enemies.get_child_count())
	)
	if enemies.get_child_count() <= 0 and next_wave.is_stopped():
		new_wave()
	
	#Control day/night cycle
	#Control sun/moon angle
	if directional_light_3d.rotation_degrees.x < -360:
		directional_light_3d.rotation_degrees.x = 0
	if directional_light_3d.rotation_degrees.x > 0:
		directional_light_3d.rotation_degrees.x = 0
	directional_light_3d.rotation_degrees.x -= sun_speed
	#print(directional_light_3d.rotation_degrees.x)
	#print((((-1/360) * (pow(abs(directional_light_3d.rotation_degrees.x),2)) + abs(directional_light_3d.rotation_degrees.x)) / 90) / 2)
	#Control sky light intensity
	if abs(directional_light_3d.rotation_degrees.x) < 180:
		world_environment.environment.background_energy_multiplier = clamp((((-1/180) * (pow(abs(directional_light_3d.rotation_degrees.x),2)) + abs(directional_light_3d.rotation_degrees.x)) / 90 ) / 4, 0.2, 1)
		directional_light_3d.light_energy = clamp((((-1/180) * (pow(abs(directional_light_3d.rotation_degrees.x),2)) + abs(directional_light_3d.rotation_degrees.x)) / 90 ) / 4, 0.2, 1)
		directional_light_3d.light_color = Color(1, 1, 0.8)
	if abs(directional_light_3d.rotation_degrees.x) > 180:
		world_environment.environment.background_energy_multiplier = clamp(1 - (((-1/180) * (pow(abs(directional_light_3d.rotation_degrees.x),2)) + abs(directional_light_3d.rotation_degrees.x)) / 90 ) / 4, 0.2, 1)
		directional_light_3d.light_energy = clamp(1 - (((-1/180) * (pow(abs(directional_light_3d.rotation_degrees.x),2)) + abs(directional_light_3d.rotation_degrees.x)) / 90 ) / 4, 0.2, 1)
		directional_light_3d.light_color = Color(0, 0.26, 0.42)

func new_wave():
	level_up.initiate_upgrade_phase()
	next_wave.start()
	hud.next_wave.show()

func _on_next_wave_timeout():
	hud.next_wave.hide()
	current_wave += 1
	for i in range(0, current_wave * 5):
		var enemy = enemy_pool[randi_range(1,enemy_pool.size()-1)].instantiate()
		enemies.add_child(enemy)
		enemy.global_position = Vector3(
			randf_range(-MAPRADIUS,MAPRADIUS),
			randf_range(SKYBOUNDS[0],SKYBOUNDS[1]),
			randf_range(-MAPRADIUS,MAPRADIUS)
			)
	hud.update_game_info()
