extends AudioStreamPlayer

@onready var menu_music = preload("res://Music/Brave Pilots (Menu Screen).ogg")
@onready var game_over_music = preload("res://Music/Defeated (Game Over Tune).ogg")
@onready var stage1_music = preload("res://Music/Space Heroes.ogg")
@onready var stage2_music = preload("res://Music/Rain of Lasers.ogg")

@onready var stage0_songs = [
	preload("res://Music/Space Heroes.ogg")
	]

@onready var stage1_songs = [
	preload("res://Music/Space Heroes.ogg"),
	preload("res://Music/397 [Misc Extras] bgm_space_upbeat_F.ogg"),
	preload("res://Music/006 [Heavy Metal Chiptunes] bgm_stage_F (faster).ogg")
	]

@onready var stage2_songs = [
	preload("res://Music/Rain of Lasers.ogg"),
	preload("res://Music/Battle in the Stars.ogg"),
	preload("res://Music/218 [Super Action Chiptunes] bgm_stage_9.ogg"),
	preload("res://Music/Coming+Home.mp3")
	]

@onready var stage3_songs = [
	preload("res://Music/Nihilore+-+Mono+no+Aware+-+05+An+Unwavering+Will.mp3"),
	preload("res://Music/Nihilore+-+Self+Loathing+-+08+Get+Mad.mp3"),
	preload("res://Music/Send+Help.mp3"),
	preload("res://Music/chase.mp3")
	]

var stage : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not playing:
		match stage:
			0:
				stream = stage0_songs[randi_range(0,stage0_songs.size()-1)]
				play()
			1:
				stream = stage1_songs[randi_range(0,stage1_songs.size()-1)]
				play()
			2:
				stream = stage2_songs[randi_range(0,stage2_songs.size()-1)]
				play()
			3:
				stream = stage3_songs[randi_range(0,stage3_songs.size()-1)]
				play()
