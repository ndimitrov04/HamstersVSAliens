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

@onready var volume_slider_value = $Settings/VolumeSliderValue
@onready var sfx_slider_value = $Settings/SFXSliderValue
@onready var sens_slider_value = $Settings/SensSliderValue

@onready var volume_slider = $Settings/VolumeSlider
@onready var sfx_slider = $Settings/SFXSlider
@onready var sens_slider = $Settings/SensSlider

const MUSIC_BUS : int = 1
const SFX_BUS : int = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	version_number.text = "Ver. Alpha " + str(ProjectSettings.get_setting("application/config/version"))
	
	await Engine.get_main_loop().process_frame
	await Engine.get_main_loop().process_frame
	await Engine.get_main_loop().process_frame
	
	# Load graphics settings from global
	volume_slider.emit_signal("value_changed", Settings.music_vol)
	volume_slider.value = Settings.music_vol
	sfx_slider.emit_signal("value_changed", Settings.sfx_vol)
	sfx_slider.value = Settings.sfx_vol
	sens_slider.emit_signal("value_changed", Settings.sens)
	sens_slider.value = Settings.sens
	
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
	if value <= -15:
		AudioServer.set_bus_mute(MUSIC_BUS, true)
	else:
		AudioServer.set_bus_mute(MUSIC_BUS, false)
		AudioServer.set_bus_volume_db(MUSIC_BUS, value)
	Settings.music_vol = value
	volume_slider_value.text = str(value+16)
	Settings.save_settings()

func _on_sfx_slider_value_changed(value):
	if value <= -15:
		AudioServer.set_bus_mute(SFX_BUS, true)
	else:
		AudioServer.set_bus_mute(SFX_BUS, false)
		AudioServer.set_bus_volume_db(SFX_BUS, value)
	Settings.sfx_vol = value
	sfx_slider_value.text = str(value+16)
	Settings.save_settings()

func _on_sens_slider_value_changed(value):
	player.mouse_sensitivity = value/1000
	Settings.sens = value
	sens_slider_value.text = str(value)
	Settings.save_settings()

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
