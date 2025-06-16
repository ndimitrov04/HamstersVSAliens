extends Control

@onready var volume_slider_value = $VolumeSliderValue
@onready var sfx_slider_value = $SFXSliderValue
@onready var sens_slider_value = $SensSliderValue

@onready var volume_slider = $VolumeSlider
@onready var sfx_slider = $SFXSlider
@onready var sens_slider = $SensSlider

const MUSIC_BUS : int = 1
const SFX_BUS : int = 2

# Called when the node enters the scene tree for the first time.
func _ready():
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_volume_slider_value_changed(value):
	Settings.music_vol = value
	if value <= -15:
		AudioServer.set_bus_mute(MUSIC_BUS, true)
	else:
		AudioServer.set_bus_mute(MUSIC_BUS, false)
		AudioServer.set_bus_volume_db(MUSIC_BUS, value)
	volume_slider_value.text = str(value+16)
	Settings.save_settings()

func _on_sfx_slider_value_changed(value):
	Settings.sfx_vol = value
	if value <= -15:
		AudioServer.set_bus_mute(SFX_BUS, true)
	else:
		AudioServer.set_bus_mute(SFX_BUS, false)
		AudioServer.set_bus_volume_db(SFX_BUS, value)
	sfx_slider_value.text = str(value+16)
	Settings.save_settings()

func _on_sens_slider_value_changed(value):
	Settings.sens = value
	sens_slider_value.text = str(value)
	Settings.save_settings()
