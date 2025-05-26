extends Node3D

#Enemies
@onready var UFO = preload("res://Scenes/Enemies/ufo.tscn")
@onready var SEEKER = preload("res://Scenes/Enemies/spaceship3.tscn")
@onready var DESTROYER = preload("res://Scenes/Enemies/spaceship1.tscn")
@onready var CARRIER = preload("res://Scenes/Enemies/carrier.tscn")
@onready var RUSHER = preload("res://Scenes/Enemies/rusher.tscn")
@onready var SHIELDER = preload("res://Scenes/Enemies/shielder.tscn")
@onready var SPHERE_BOT_R = preload("res://Scenes/Enemies/sphere_bot_r.tscn")
@onready var SPHERE_BOT_S = preload("res://Scenes/Enemies/sphere_bot_s.tscn")

@onready var enemies = $Enemies
@onready var friendlies = $Friendlies

@onready var player = $Friendlies/Player
@onready var level_up = $HUD/LevelUp
@onready var hud = $HUD
@onready var next_wave = $NextWave
@onready var wave_notification = $WaveNotification

@onready var world_environment = $WorldEnvironment

const MAPRADIUS = 500
var SKYBOUNDS

var current_wave : int = 0
var enemy_pool
var city_hp = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	SKYBOUNDS = get_meta("skybounds")
	print("START IN 1")
	await get_tree().create_timer(1).timeout
	print("START")
	enemy_pool = [UFO, SEEKER, DESTROYER, RUSHER, SHIELDER, CARRIER, SPHERE_BOT_R, SPHERE_BOT_S]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	hud.level_data.text = (
		"Current Wave: " + str(current_wave) + "\n" +
		"Enemies Left: " + str(enemies.get_child_count())
	)
	if enemies.get_child_count() <= 0 and next_wave.is_stopped():
		new_wave()
		
	city_hp = calculate_city_hp()
	if city_hp <= 0:
		player.hp = 0
		
	#Dash toward crosshair (forward)
	if Input.is_action_just_pressed("debug_ka"):
		for enemy in enemies.get_children():
			if "hp" in enemy:
				enemy.hp = 0

func new_wave():
	level_up.initiate_upgrade_phase()
	next_wave.start()
	hud.next_wave.show()

func _on_next_wave_timeout():
	hud.next_wave.hide()
	current_wave += 1
	wave_notification.play()
	for i in range(0, current_wave * 5):
		var enemy = enemy_pool[randi_range(1,enemy_pool.size()-1)].instantiate()
		enemies.add_child(enemy)
		enemy.global_position = Vector3(
			randf_range(-MAPRADIUS,MAPRADIUS),
			randf_range(SKYBOUNDS[0],SKYBOUNDS[1]),
			randf_range(-MAPRADIUS,MAPRADIUS)
			)
	hud.update_game_info()

func calculate_city_hp() -> int:
	var hp = 0
	for object in friendlies.get_children():
		if "npc_building" in object:
			if object.npc_building:
				hp += object.hp
	return hp
