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
@onready var BOMBER = preload("res://Scenes/Enemies/bomber.tscn")

@onready var enemies = $Enemies
@onready var friendlies = $Friendlies

@onready var player = $Friendlies/Player
@onready var level_up = $HUD/LevelUp
@onready var hud = $HUD
@onready var next_wave = $NextWave
@onready var wave_notification = $WaveNotification

@onready var world_environment = $WorldEnvironment
@onready var enemy_list = $HUD/EnemyList
@onready var tower_list = $HUD/TowerList
@onready var open_button = $HUD/EnemyList/OpenButton
@onready var menu = $HUD/Menu

const MAPRADIUS = 500
var SKYBOUNDS

var random_wave_gen : bool = false
var current_wave : int = 0
var stage_mod : float = 1
var stage_waves
var enemy_pool
var city_hp = 1

enum ENEMYTYPE {
	seeker,
	destroyer,
	carrier,
	rusher,
	shielder,
	sphere_bot_s,  # shootbot
	sphere_bot_r,  # rushbot
	bomber
}

var waves_1 = [
	[],  # Wave 0 (no enemies)

	# Wave 1
	[ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker],

	# Wave 2
	[ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer],

	# Wave 3
	[ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.carrier],

	# Wave 4
	[ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.carrier, ENEMYTYPE.carrier],

	# Wave 5
	[ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.rusher, ENEMYTYPE.rusher],

	# Wave 6
	[ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher],

	# Wave 7
	[ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder],

	# Wave 8 (Boss)
	[ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder,
	 ENEMYTYPE.rusher, ENEMYTYPE.rusher],

	# Wave 9
	[ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s,
	 ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s,
	 ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher],

	# Wave 10
	[ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s,
	 ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier],

	# Wave 11
	[ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder,
	 ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher],

	# Wave 12
	[ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber,
	 ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier],

	# Wave 13
	[ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder,
	 ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber],

	# Wave 14
	[ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r,
	 ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r,
	 ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier],

	# Wave 15 (Boss)
	[ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber]
]

var waves_2 = [
	[],  # Wave 0 (no enemies)

	# Wave 1
	[ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer],

	# Wave 2
	[ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.destroyer],

	# Wave 3
	[ENEMYTYPE.rusher, ENEMYTYPE.rusher,
	 ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer],

	# Wave 4
	[ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder,
	 ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.rusher],

	# Wave 5
	[ENEMYTYPE.rusher, ENEMYTYPE.rusher,
	 ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r,
	 ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.shielder],

	# Wave 6
	[ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s,
	 ENEMYTYPE.rusher, ENEMYTYPE.rusher,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer],

	# Wave 7
	[ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s,
	 ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r,
	 ENEMYTYPE.rusher, ENEMYTYPE.rusher,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.seeker, ENEMYTYPE.seeker,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer],

	# Wave 8
	[ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher,
	 ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s,
	 ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker],

	# Wave 9
	[ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer],

	# Wave 10
	[ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder,
	 ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder],

	# Wave 11
	[ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber,
	 ENEMYTYPE.bomber, ENEMYTYPE.bomber,
	 ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder],

	# Wave 12
	[ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r,
	 ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher,
	 ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer],

	# Wave 13
	[ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s,
	 ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s,
	 ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher,
	 ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer],

	# Wave 14
	[ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder,
	 ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker,
	 ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker],

	# Wave 15
	[ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber,
	 ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber,
	 ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber,
	 ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber,
	 ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher,
	 ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder,
	 ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder,
	 ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker,
	 ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker]
]


var waves_3 = [
	[],  # Wave 0 (no enemies)

	# Wave 1
	[ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.seeker, ENEMYTYPE.seeker],

	# Wave 2
	[ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer],

	# Wave 3
	[ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.carrier],

	# Wave 4
	[ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.carrier, ENEMYTYPE.carrier],

	# Wave 5
	[ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.rusher, ENEMYTYPE.rusher],

	# Wave 6
	[ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher],

	# Wave 7
	[ENEMYTYPE.seeker, ENEMYTYPE.seeker, ENEMYTYPE.destroyer, ENEMYTYPE.destroyer,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder],

	# Wave 8 (Boss)
	[ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder,
	 ENEMYTYPE.rusher, ENEMYTYPE.rusher],

	# Wave 9
	[ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s,
	 ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s,
	 ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher],

	# Wave 10
	[ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s, ENEMYTYPE.sphere_bot_s,
	 ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier],

	# Wave 11
	[ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder,
	 ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher],

	# Wave 12
	[ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber,
	 ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier],

	# Wave 13
	[ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder, ENEMYTYPE.shielder,
	 ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber],

	# Wave 14
	[ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r,
	 ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r, ENEMYTYPE.sphere_bot_r,
	 ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier],

	# Wave 15 (Boss)
	[ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber]
]

# Called when the node enters the scene tree for the first time.
func _ready():
	match get_meta("stage"):
		1:
			stage_mod = 1
			stage_waves = waves_1
			MusicPlayer.stream = MusicPlayer.stage1_music
		2:
			stage_mod = 1.5
			stage_waves = waves_2
			MusicPlayer.stream = MusicPlayer.stage2_music
		3:
			stage_mod = 2
			stage_waves = waves_3
			MusicPlayer.stream = MusicPlayer.stage1_music
	MusicPlayer.play()
	SKYBOUNDS = get_meta("skybounds")
	print("START IN 1")
	await get_tree().create_timer(1).timeout
	print("START")
	enemy_pool = [UFO, SEEKER, DESTROYER, RUSHER, SHIELDER, CARRIER, SPHERE_BOT_R, SPHERE_BOT_S]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not get_tree().paused:
		tower_list.enemy_panel.hide()
		enemy_list.enemy_panel.hide()
	if menu.visible:
		enemy_list.open_button.button_pressed = false
		tower_list.open_button.button_pressed = false
		tower_list.enemy_panel.hide()
		enemy_list.enemy_panel.hide()
	
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
	hud.comms.update_comms(current_wave)
	level_up.initiate_upgrade_phase()
	next_wave.start()
	hud.next_wave.show()

func create_enemy(enemy_type: ENEMYTYPE):
	var enemy_scenes = {
		ENEMYTYPE.seeker: preload("res://Scenes/Enemies/spaceship3.tscn"),
		ENEMYTYPE.destroyer: preload("res://Scenes/Enemies/spaceship1.tscn"),
		ENEMYTYPE.carrier: preload("res://Scenes/Enemies/carrier.tscn"),
		ENEMYTYPE.rusher: preload("res://Scenes/Enemies/rusher.tscn"),
		ENEMYTYPE.shielder: preload("res://Scenes/Enemies/shielder.tscn"),
		ENEMYTYPE.sphere_bot_s: preload("res://Scenes/Enemies/sphere_bot_s.tscn"),
		ENEMYTYPE.sphere_bot_r: preload("res://Scenes/Enemies/sphere_bot_r.tscn"),
		ENEMYTYPE.bomber: preload("res://Scenes/Enemies/bomber.tscn")
	}

	if enemy_type in enemy_scenes:
		return enemy_scenes[enemy_type].instantiate()
	else:
		push_error("Unknown enemy type: %s" % str(enemy_type))
		return null

func _on_next_wave_timeout():
	if current_wave >= 15:
		random_wave_gen = true
	hud.next_wave.hide()
	current_wave += 1
	wave_notification.play()
	if random_wave_gen:
		# Random wave generation
		for i in range(0, 5 + current_wave):
			# Spawn enemy and give it HP equal to base HP + current wave * 10
			var currentEnemy = enemy_pool[randi_range(1,enemy_pool.size()-1)].instantiate()
			enemies.add_child(currentEnemy)
			currentEnemy.hp += current_wave * 10 * stage_mod
			currentEnemy.global_position = Vector3(
				randf_range(-MAPRADIUS,MAPRADIUS),
				randf_range(SKYBOUNDS[0],SKYBOUNDS[1]),
				randf_range(-MAPRADIUS,MAPRADIUS)
				)
	else:
		print("Current wave:")
		print(stage_waves[current_wave])
		update_enemy_list()
		# Random wave generation
		for enemy_type in stage_waves[current_wave]:
			# Spawn enemy and give it HP equal to base HP + current wave * 10
			var currentEnemy = create_enemy(enemy_type)
			enemies.add_child(currentEnemy)
			currentEnemy.hp += current_wave * 20 * stage_mod
			currentEnemy.global_position = Vector3(
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

func update_enemy_list():
	if get_meta("stage") == 1:
		match current_wave:
			2:
				enemy_list.unlocked_enemies += 1
				enemy_list.current_index = enemy_list.unlocked_enemies - 1
				open_button.button_pressed = true
				enemy_list.load_entry(enemy_list.current_index)
				enemy_list.new_enemy_sfx.play()
			3:
				enemy_list.unlocked_enemies += 1
				enemy_list.current_index = enemy_list.unlocked_enemies - 1
				open_button.button_pressed = true
				enemy_list.load_entry(enemy_list.current_index)
				enemy_list.new_enemy_sfx.play()
			5:
				enemy_list.unlocked_enemies += 1
				enemy_list.current_index = enemy_list.unlocked_enemies - 1
				open_button.button_pressed = true
				enemy_list.load_entry(enemy_list.current_index)
				enemy_list.new_enemy_sfx.play()
			7:
				enemy_list.unlocked_enemies += 1
				enemy_list.current_index = enemy_list.unlocked_enemies - 1
				open_button.button_pressed = true
				enemy_list.load_entry(enemy_list.current_index)
				enemy_list.new_enemy_sfx.play()
			9:
				enemy_list.unlocked_enemies += 1
				enemy_list.current_index = enemy_list.unlocked_enemies - 1
				open_button.button_pressed = true
				enemy_list.load_entry(enemy_list.current_index)
				enemy_list.new_enemy_sfx.play()
			10:
				enemy_list.unlocked_enemies += 1
				enemy_list.current_index = enemy_list.unlocked_enemies - 1
				open_button.button_pressed = true
				enemy_list.load_entry(enemy_list.current_index)
				enemy_list.new_enemy_sfx.play()
			12:
				enemy_list.unlocked_enemies += 1
				enemy_list.current_index = enemy_list.unlocked_enemies - 1
				open_button.button_pressed = true
				enemy_list.load_entry(enemy_list.current_index)
				enemy_list.new_enemy_sfx.play()
