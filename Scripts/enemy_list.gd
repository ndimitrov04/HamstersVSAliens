extends Control

@onready var enemy_panel = $EnemyPanel
@onready var bottom_bar = $EnemyPanel/BottomBar
@onready var enemy_label = $EnemyPanel/BottomBar/EnemyLabel
@onready var previous = $EnemyPanel/BottomBar/Previous
@onready var next = $EnemyPanel/BottomBar/Next
@onready var enemy_picture = $EnemyPanel/EnemyPicture
@onready var name_label = $EnemyPanel/NameLabel
@onready var description = $EnemyPanel/Description
@onready var stats = $EnemyPanel/Stats
@onready var open_button = $OpenButton

@onready var main = $"../.."
@onready var hud = $".."

@onready var swap_sfx = $EnemyPanel/BottomBar/SwapSFX
@onready var new_enemy_sfx = $NewEnemySFX
@onready var open_sfx = $OpenSFX


class EnemyEntry:
	var ename
	var picture
	var description
	var stats

var current_index : int = 0
var unlocked_enemies : int = 1
var enemy_entries

# Called when the node enters the scene tree for the first time.
func _ready():
	var seeker : EnemyEntry = EnemyEntry.new()
	seeker.ename = "Seeker"
	seeker.picture = preload("res://Textures/HUD/Enemies/seeker.png")
	seeker.description = "	This spacecraft follows the player around and tries to shoot them.
							It is relatively slow and fraile."
	seeker.stats = "Base HP: 100\nDamage: 20\nBase Speed: 25"

	var destroyer : EnemyEntry = EnemyEntry.new()
	destroyer.ename = "Destroyer"
	destroyer.picture = preload("res://Textures/HUD/Enemies/destroyer.png")
	destroyer.description = "	This spacecraft tries to destroy friendly buildings.
							It has explosive bullets, which deal a lot of damage.
							It is relatively slow and fraile."
	destroyer.stats = "Base HP: 100\nDamage: 40\nBase Speed: 25"

	var carrier : EnemyEntry = EnemyEntry.new()
	carrier.ename = "Carrier"
	carrier.picture = preload("res://Textures/HUD/Enemies/carrier.png")
	carrier.description = "	This spacecraft cannot attack on it's own.
							It carries 4 small spaceships that it unleashes on the battlefield.
							One minion per 7 seconds.
							It is slow and durable.
							It would be a good idea to take it out before it spawns its minions."
	carrier.stats = "Base HP: 400\nDamage: NA\nBase Speed: 25"
	
	var rusher : EnemyEntry = EnemyEntry.new()
	rusher.ename = "Rusher"
	rusher.picture = preload("res://Textures/HUD/Enemies/rusher.png")
	rusher.description = "	This flying spacecraft doesn't shoot the player, but instead rushes them
							and tries to explode near them. It would be wise to avoid touching it."
	rusher.stats = "Base HP: 75\nDamage: 75\nBase Speed: 27"
	
	var shielder : EnemyEntry = EnemyEntry.new()
	shielder.ename = "Shielder"
	shielder.picture = preload("res://Textures/HUD/Enemies/shielder.png")
	shielder.description = "This spaceraft follows enemies and protects them from projectiles.
							Due to its shield and its quick movement, it would be difficult
							to destroy it with ranged attacks."
	shielder.stats = "Base HP: 50\nShield: 300 (can regenerate)\nDamage: NA\nBase Speed: 25"
	
	var shootbot : EnemyEntry = EnemyEntry.new()
	shootbot.ename = "Shootbot"
	shootbot.picture = preload("res://Textures/HUD/Enemies/gunbot.png")
	shootbot.description = "This drone cannot fly, however it can move quickly on the ground.
							It's main objective is to shoot either the player or their towers."
	shootbot.stats = "Base HP: 200\nDamage: 20\nBase Speed: 27"
	
	var rushbot : EnemyEntry = EnemyEntry.new()
	rushbot.ename = "Rushbot"
	rushbot.picture = preload("res://Textures/HUD/Enemies/gunbot.png")
	rushbot.description = "	This drone cannot fly, however it can move quickly on the ground.
							It's main objective is to crash into the player, exploding on impact."
	rushbot.stats = "Base HP: 125\nDamage: 75\nBase Speed: 27"
	
	var bomber : EnemyEntry = EnemyEntry.new()
	bomber.ename = "Bomber"
	bomber.picture = preload("res://Textures/HUD/Enemies/bomber.png")
	bomber.description = "	This spacecraft strafes in the air and drops bombs.
							It moves quickly and erraticaly and is very durable."
	bomber.stats = "Base HP: 300\nDamage: 40\nBase Speed: 27"


	enemy_entries = [seeker, destroyer, carrier, rusher, shielder, shootbot, rushbot, bomber]
	load_entry(current_index)

func load_entry(index : int):
	name_label.text = enemy_entries[index].ename
	description.text = enemy_entries[index].description
	stats.text = enemy_entries[index].stats
	enemy_picture.texture = enemy_entries[index].picture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("debug_unlock_all"):
		unlocked_enemies = 100

func _on_open_button_toggled(toggled_on):
	if toggled_on:
		enemy_panel.show()
		main.process_mode = ProcessMode.PROCESS_MODE_DISABLED
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		open_sfx.play()
	else:
		enemy_panel.hide()
		main.process_mode = ProcessMode.PROCESS_MODE_INHERIT
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		open_sfx.play()

func _on_previous_pressed():
	if current_index > 0:
		current_index -= 1
		load_entry(current_index)
		swap_sfx.play()

func _on_next_pressed():
	if current_index < enemy_entries.size() - 1 and current_index < unlocked_enemies - 1:
	#if current_index < enemy_entries.size() - 1:
		current_index += 1
		print(current_index)
		load_entry(current_index)
		swap_sfx.play()
