extends Node3D

#compile shaders

const FLOATING_RUSHER = preload("res://Scenes/Behaviors/floating_rusher.tscn")
const IMPACT_EXPLODER = preload("res://Scenes/Behaviors/impact_exploder.tscn")
const NON_PREDICTIVE_SHOOTING = preload("res://Scenes/Behaviors/non_predictive_shooting.tscn")
const CARRIER = preload("res://Scenes/Enemies/carrier.tscn")
const CARRIER_MINION = preload("res://Scenes/Enemies/carrier_minion.tscn")
const RUSHER = preload("res://Scenes/Enemies/rusher.tscn")
const SHIELDER = preload("res://Scenes/Enemies/shielder.tscn")
const SPACESHIP_1 = preload("res://Scenes/Enemies/spaceship1.tscn")
const SPACESHIP_3 = preload("res://Scenes/Enemies/spaceship3.tscn")
const UFO = preload("res://Scenes/Enemies/ufo.tscn")
const FAST_TURRET = preload("res://Scenes/FriendlyTowers/fast_turret.tscn")
const REGENERATION_BEACON = preload("res://Scenes/FriendlyTowers/regeneration_beacon.tscn")
const SPEEDBOOST_BEACON = preload("res://Scenes/FriendlyTowers/speedboost_beacon.tscn")
const TOWER = preload("res://Scenes/FriendlyTowers/tower.tscn")
const CARRIER_MODEL = preload("res://Scenes/ModelScenes/carrier_model.tscn")
const E_45_GLSL = preload("res://Scenes/ModelScenes/e_45_glsl.tscn")
const FAST_TURRETM = preload("res://Scenes/ModelScenes/fast_turret.tscn")
const GROUND_BUMP = preload("res://Scenes/ModelScenes/ground_bump.tscn")
const SPACESHIP_3_MODEL = preload("res://Scenes/ModelScenes/spaceship3_model.tscn")
const SPACE_HUMSTER = preload("res://Scenes/ModelScenes/space_humster.tscn")
const UFO_MODEL = preload("res://Scenes/ModelScenes/ufo_model.tscn")
const EXPLOSION = preload("res://Scenes/Particles/explosion.tscn")
const HEALTH_PARTICLE = preload("res://Scenes/Particles/health_particle.tscn")
const DESTROYER_BULLET = preload("res://Scenes/Projectiles/destroyer_bullet.tscn")
const LIGHT_BULLET = preload("res://Scenes/Projectiles/light_bullet.tscn")
const LIGHT_BULLET_FRIENDLY = preload("res://Scenes/Projectiles/light_bullet_friendly.tscn")
const BUILD_SPOT = preload("res://Scenes/build_spot.tscn")
const PLAYER = preload("res://Scenes/player.tscn")

var resources = [
	FLOATING_RUSHER,
	IMPACT_EXPLODER,
	NON_PREDICTIVE_SHOOTING,
	CARRIER,
	CARRIER_MINION,
	RUSHER,
	SHIELDER,
	SPACESHIP_1,
	SPACESHIP_3,
	UFO,
	FAST_TURRET,
	REGENERATION_BEACON,
	SPEEDBOOST_BEACON,
	TOWER,
	CARRIER_MODEL,
	E_45_GLSL,
	FAST_TURRETM,
	GROUND_BUMP,
	SPACESHIP_3_MODEL,
	SPACE_HUMSTER,
	UFO_MODEL,
	EXPLOSION,
	HEALTH_PARTICLE,
	DESTROYER_BULLET,
	LIGHT_BULLET,
	LIGHT_BULLET_FRIENDLY,
	BUILD_SPOT,
	PLAYER
]

var next_scene = "res://Scenes/Stages/stage_grasslands.tscn"

@onready var color_rect = $CanvasLayer/LoadingScreen/ColorRect
@onready var screen_bg_1 = $CanvasLayer/LoadingScreen/ScreenBG1
@onready var title = $CanvasLayer/LoadingScreen/Title
@onready var version_number = $CanvasLayer/LoadingScreen/VersionNumber
@onready var loading_text = $CanvasLayer/LoadingScreen/LoadingText
@onready var loading_helper = $CanvasLayer/LoadingScreen/LoadingHelper
@onready var loading_bar = $CanvasLayer/LoadingScreen/LoadingBar


# Called when the node enters the scene tree for the first time.
func _ready():
	print("SHADERCOMPILE")
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

# Called when the node enters the scene tree for the first time.
#func _ready():
	#for resource in resources:
		#resource.instantiate()
	#pass

#func _physics_process(_delta):
	#pass
