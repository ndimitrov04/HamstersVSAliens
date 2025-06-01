extends Panel

@onready var player = $"../../Friendlies/Player"
@onready var version_number = $Design/VersionNumber

@onready var player_data = $"../PlayerData"
@onready var level_data = $"../LevelData"
@onready var debug_data = $"../DebugData"
@onready var graphics_menu = $GraphicsMenu
@onready var main = $"../.."
@onready var enemy_list = $"../EnemyList"
@onready var tower_list = $"../TowerList"

const MUSIC_BUS : int = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	version_number.text = "Ver. Alpha " + str(ProjectSettings.get_setting("application/config/version"))
	hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	#Toggle mouse focus
	if Input.is_action_just_pressed("ui_cancel"):
		enemy_list.open_button.button_pressed = false
		tower_list.open_button.button_pressed = false
		if main.process_mode == ProcessMode.PROCESS_MODE_DISABLED:
			main.process_mode = ProcessMode.PROCESS_MODE_INHERIT
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			main.process_mode = ProcessMode.PROCESS_MODE_DISABLED
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _on_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(MUSIC_BUS, value)

func _on_sens_slider_value_changed(value):
	player.mouse_sensitivity = value/1000

func _on_debug_hud_toggled(toggled_on):
	if toggled_on:
		player_data.show()
		debug_data.show()
		level_data.show()
	else:
		player_data.hide()
		debug_data.hide()
		level_data.hide()

func _on_graphics_toggled(toggled_on):
	if toggled_on:
		graphics_menu.show()
	else:
		graphics_menu.hide()

func _on_quit_game_pressed():
	get_tree().quit()
