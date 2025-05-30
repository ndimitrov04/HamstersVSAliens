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

const MAPRADIUS = 500
var SKYBOUNDS

var random_wave_gen : bool = false
var current_wave : int = 0
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

var waves = [
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
	 ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher, ENEMYTYPE.rusher],

	# Wave 15 (Boss)
	[ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier, ENEMYTYPE.carrier,
	 ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber, ENEMYTYPE.bomber]
]


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
	hud.next_wave.hide()
	current_wave += 1
	wave_notification.play()
	if random_wave_gen:
		# Random wave generation
		for i in range(0, 5 + current_wave):
			# Spawn enemy and give it HP equal to base HP + current wave * 10
			var currentEnemy = enemy_pool[randi_range(1,enemy_pool.size()-1)].instantiate()
			enemies.add_child(currentEnemy)
			currentEnemy.hp += current_wave * 10
			currentEnemy.global_position = Vector3(
				randf_range(-MAPRADIUS,MAPRADIUS),
				randf_range(SKYBOUNDS[0],SKYBOUNDS[1]),
				randf_range(-MAPRADIUS,MAPRADIUS)
				)
	else:
		print("Current wave:")
		print(waves[current_wave])
		# Random wave generation
		for enemy_type in waves[current_wave]:
			# Spawn enemy and give it HP equal to base HP + current wave * 10
			var currentEnemy = create_enemy(enemy_type)
			enemies.add_child(currentEnemy)
			currentEnemy.hp += current_wave * 10
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
