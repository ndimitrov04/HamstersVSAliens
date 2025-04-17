extends Node3D

@onready var player = $".."

@onready var roll_sfx = $RollSFX
@onready var land_sfx = $LandSFX
@onready var homing_hit_sfx = $HomingHitSFX
@onready var wind_sfx = $WindSFX
@onready var hit_sfx = $HitSFX
@onready var jump_sfx = $JumpSFX
@onready var speed_particles = $"../Ship/SpeedParticles"

@onready var last_land = $LastLand

var landed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if max(	abs(get_parent().angular_velocity.x), 
			abs(get_parent().angular_velocity.y), 
			abs(get_parent().angular_velocity.z)
			) > 0.1 and get_parent().floor_detector.is_colliding():
		if not roll_sfx.playing:
			roll_sfx.play()
	else:
		roll_sfx.stop()
		
	roll_sfx.pitch_scale = max(	abs(get_parent().angular_velocity.x), 
								abs(get_parent().angular_velocity.y), 
								abs(get_parent().angular_velocity.z),
								0.1
								) / 16
	
	wind_sfx.volume_db = max(	abs(get_parent().linear_velocity.x), 
								abs(get_parent().linear_velocity.y), 
								abs(get_parent().linear_velocity.z),
								0
								) - 20
								
	wind_sfx.pitch_scale = max(	abs(get_parent().linear_velocity.x), 
								abs(get_parent().linear_velocity.y), 
								abs(get_parent().linear_velocity.z),
								0.1
								) / 32

func _on_player_body_entered(body):
	if body.name == "HTerrain":
		if not land_sfx.playing and last_land.is_stopped() and not landed:
			#trigger screenshake
			player.trauma_detector.add_trauma(0.8)
			#play land SFX
			land_sfx.play()
			hit_sfx.play()
			last_land.start()
			landed = true
