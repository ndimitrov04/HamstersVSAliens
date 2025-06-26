extends Control

var next_scene = "res://initial_loader.tscn"
# For some reason, adding a booster and/or jumppad to the 
# shader compilation scene, results in visual artifacts
# for the entire game?!
#var next_scene = "res://Scenes/Stages/stage_grasslands.tscn"

@onready var title_panel = $TitlePanel
@onready var title = $TitlePanel/Title
@onready var version_number = $TitlePanel/VersionNumber

@onready var menu_panel = $MenuPanel
@onready var play_button = $MenuPanel/PlayButton
@onready var options = $MenuPanel/Options
@onready var quit = $MenuPanel/Quit

@onready var stage_select = $StageSelect
@onready var graphics_menu = $GraphicsMenu
@onready var credits = $Credits

var progress = []

# Called when the node enters the scene tree for the first time.
func _ready():
	MusicPlayer.stream = MusicPlayer.menu_music
	MusicPlayer.play()
	print("LOADINIT2")
	ResourceLoader.load_threaded_request(next_scene)
	version_number.text = "Version: Alpha " + str(ProjectSettings.get_setting("application/config/version"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	ResourceLoader.load_threaded_get_status(next_scene, progress)

func _on_options_toggled(toggled_on):
	if toggled_on:
		graphics_menu.show()
	else:
		graphics_menu.hide()

func _on_quit_pressed():
	get_tree().quit()

func _on_credits_toggled(toggled_on):
	if toggled_on:
		credits.show()
	else:
		credits.hide()

func _on_play_button_toggled(toggled_on):
	if toggled_on:
		stage_select.show()
	else:
		stage_select.hide()

func _on_stage_1_pressed():
	NextStage.next_stage = NextStage.stage_1
	if progress[0] == 1:
		MusicPlayer.stop()
		var packed_scene = ResourceLoader.load_threaded_get(next_scene)
		get_tree().change_scene_to_packed(packed_scene)

func _on_stage_2_pressed():
	NextStage.next_stage = NextStage.stage_2
	if progress[0] == 1:
		MusicPlayer.stop()
		var packed_scene = ResourceLoader.load_threaded_get(next_scene)
		get_tree().change_scene_to_packed(packed_scene)
