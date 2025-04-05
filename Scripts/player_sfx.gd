extends Node3D

@onready var roll_sfx = $RollSFX
@onready var land_sfx = $LandSFX

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

func _on_player_body_entered(body):
	if body.name == "HTerrain":
		if not land_sfx.playing and last_land.is_stopped() and not landed:
			land_sfx.play()
			last_land.start()
			landed = true
