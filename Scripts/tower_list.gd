extends Control

@onready var open_button = $OpenButton
@onready var enemy_panel = $EnemyPanel
@onready var bottom_bar = $EnemyPanel/BottomBar
@onready var enemy_label = $EnemyPanel/BottomBar/EnemyLabel
@onready var previous = $EnemyPanel/BottomBar/Previous
@onready var next = $EnemyPanel/BottomBar/Next
@onready var enemy_picture = $EnemyPanel/EnemyPicture
@onready var name_label = $EnemyPanel/NameLabel
@onready var description = $EnemyPanel/Description
@onready var stats = $EnemyPanel/Stats

@onready var main = $"../.."
@onready var hud = $".."

@onready var swap_sfx = $EnemyPanel/BottomBar/SwapSFX
@onready var open_sfx = $OpenSFX

class Entry:
	var ename
	var picture
	var description
	var stats

var current_index : int = 0
var unlocked_entries : int = 10
var entries

# Called when the node enters the scene tree for the first time.
func _ready():
	var f_turret : Entry = Entry.new()
	f_turret.ename = "Fast Turret"
	f_turret.picture = preload("res://Textures/HUD/Friendlies/fastturret.png")
	f_turret.description = "This is a turret that shoots your enemies.
							It is fairly inaccurate, but shoots rather quickly.
							Cost: 35 Gold"
	f_turret.stats = "Base HP: 250\nShield: 300\nDamage: 50\nAccuracy: Poor\nRate of fire: 100 RPM"
	
	var p_turret : Entry = Entry.new()
	p_turret.ename = "Predictive Turret"
	p_turret.picture = preload("res://Textures/HUD/Friendlies/fastturret.png")
	p_turret.description = "This is a turret that shoots your enemies.
							It shoots accurately but slowly.
							Cost: 75 Gold"
	p_turret.stats = "Base HP: 150\nShield: 150\nDamage: 50\nAccuracy: Good\nRate of fire: 65 RPM"

	var speedboost_beacon : Entry = Entry.new()
	speedboost_beacon.ename = "Speedboost Beacon"
	speedboost_beacon.picture = preload("res://Textures/HUD/Friendlies/speedboost.png")
	speedboost_beacon.description = "	This is a beacon that increases your top speed while
										you remain in its area of effect (AOE).
										Cost: 80 Gold"
	speedboost_beacon.stats = "Base HP: 200\nShield: 500\nTop speed boost: 50%\nAOE Radius: 500 Meters"

	var regen_beacon : Entry = Entry.new()
	regen_beacon.ename = "Regeneration Beacon"
	regen_beacon.picture = preload("res://Textures/HUD/Friendlies/regen.png")
	regen_beacon.description = "	This is a beacon that heals you and all 
									friendly buildings in an AOE once every X seconds.
									Cost: 150 Gold"
	regen_beacon.stats = "Base HP: 200\nShield: 500\nBase HP Regeneration: 10 per 5 seconds\nAOE Radius: 500 Meters"

	var shield_beacon : Entry = Entry.new()
	shield_beacon.ename = "Shield Beacon"
	shield_beacon.picture = preload("res://Textures/HUD/Friendlies/shieldtower.png")
	shield_beacon.description = "	This is a beacon generates a large shield, protecting
									all friendly units and towers inside of it.
									Cost: 70 Gold"
	shield_beacon.stats = "Base HP: 200\nShield: 1000\nAOE Radius: 500 Meters"

	var slowdown_beacon : Entry = Entry.new()
	slowdown_beacon.ename = "Slowdown Beacon"
	slowdown_beacon.picture = preload("res://Textures/HUD/Friendlies/slowdown.png")
	slowdown_beacon.description = "	This beacon slows down all enemies within its radius.
									Cost: 100 Gold"
	slowdown_beacon.stats = "Base HP: 200\nShield: 300\nAOE Radius: 500 Meters"

	entries = [f_turret, p_turret, speedboost_beacon, regen_beacon, shield_beacon, slowdown_beacon]
	load_entry(current_index)

func load_entry(index : int):
	name_label.text = entries[index].ename
	description.text = entries[index].description
	stats.text = entries[index].stats
	enemy_picture.texture = entries[index].picture

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

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
	if current_index < entries.size() - 1 and current_index < unlocked_entries - 1:
	#if current_index < enemy_entries.size() - 1:
		current_index += 1
		print(current_index)
		load_entry(current_index)
		swap_sfx.play()
