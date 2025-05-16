extends Control

@onready var title = $Title
@onready var version_number = $VersionNumber
@onready var loading_bar = $LoadingBar
@onready var loading_text = $LoadingText

#var next_scene = "res://initial_loader.tscn"
var next_scene = "res://menu_bg.tscn"

# Called when the node enters the scene tree for the first time.
func _ready():
	print("LOADINIT")
	ResourceLoader.load_threaded_request(next_scene)
	version_number.text = "Version: Alpha " + str(ProjectSettings.get_setting("application/config/version"))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var progress = []
	ResourceLoader.load_threaded_get_status(next_scene, progress)
	loading_bar.value = progress[0] * 100
	loading_text.text = str(int(progress[0] * 100)) + "%"

	if progress[0] == 1:
		var packed_scene = ResourceLoader.load_threaded_get(next_scene)
		get_tree().change_scene_to_packed(packed_scene)
