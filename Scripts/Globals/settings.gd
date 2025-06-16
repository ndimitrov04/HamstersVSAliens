extends Node

@onready var fullscreen	: int = 0
@onready var vsync		: int = 0
@onready var upscaling	: int = 0
@onready var aa			: int = 0
@onready var gi			: int = 0
@onready var bloom		: int = 0
@onready var ao			: int = 0
@onready var ssr		: int = 0
@onready var ssl		: int = 0

@onready var music_vol	: int = 0
@onready var sfx_vol	: int = 0
@onready var sens		: float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var config_file = ConfigFile.new()
	
	# Load data from a config file
	var err = config_file.load("user://hamstergame.save")
	
	# If the file didn't load, ignore it.
	if err != OK:
		print("Savefile not found!")
		return
	
	# Iterate over all sections.
	for section in config_file.get_sections():
		# Fetch the data for each section.
		fullscreen = config_file.get_value(section, "fullscreen")
		vsync = config_file.get_value(section, "vsync")
		upscaling = config_file.get_value(section, "upscaling")
		aa = config_file.get_value(section, "aa")
		gi = config_file.get_value(section, "gi")
		bloom = config_file.get_value(section, "bloom")
		ao = config_file.get_value(section, "ao")
		ssr = config_file.get_value(section, "ssr")
		ssl = config_file.get_value(section, "ssl")
		
		music_vol = config_file.get_value(section, "music_vol")
		sfx_vol = config_file.get_value(section, "sfx_vol")
		sens = config_file.get_value(section, "sens")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func save_settings():
	var config_file = ConfigFile.new()
	
	config_file.set_value("s1", "fullscreen", fullscreen)
	config_file.set_value("s1", "vsync", vsync)
	config_file.set_value("s1", "upscaling", upscaling)
	config_file.set_value("s1", "aa", aa)
	config_file.set_value("s1", "gi", gi)
	config_file.set_value("s1", "bloom", bloom)
	config_file.set_value("s1", "ao", ao)
	config_file.set_value("s1", "ssr", ssr)
	config_file.set_value("s1", "ssl", ssl)
	
	config_file.set_value("s1", "music_vol", music_vol)
	config_file.set_value("s1", "sfx_vol", sfx_vol)
	config_file.set_value("s1", "sens", sens)
	
	config_file.save("user://hamstergame.save")
