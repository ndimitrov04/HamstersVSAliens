extends Control

#var next_scene = "res://initial_loader.tscn"  #this results in artifacting for some reason. 
var next_scene = "res://Scenes/Stages/stage_grasslands.tscn"

@onready var title_panel = $TitlePanel
@onready var title = $TitlePanel/Title
@onready var version_number = $TitlePanel/VersionNumber

@onready var menu_panel = $MenuPanel
@onready var play_button = $MenuPanel/PlayButton
@onready var options = $MenuPanel/Options
@onready var quit = $MenuPanel/Quit

@onready var graphics_menu = $GraphicsMenu
@onready var credits = $Credits

var progress = []

# Called when the node enters the scene tree for the first time.
func _ready():
	print("LOADINIT2")
	ResourceLoader.load_threaded_request(next_scene)
	version_number.text = "Version: Alpha " + str(ProjectSettings.get_setting("application/config/version"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	ResourceLoader.load_threaded_get_status(next_scene, progress)

func _on_play_button_pressed():
	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(next_scene)
		get_tree().change_scene_to_packed(packed_scene)

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
