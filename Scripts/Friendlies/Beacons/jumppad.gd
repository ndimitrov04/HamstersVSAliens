extends Node3D

@onready var sfx = $SFX

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_boost_area_body_entered(body):
	if body.name == "Player":
		body.boosted.start()
		body.MAXVELOCITY = 50
		body.apply_central_impulse(body.twist_pivot.basis * Vector3(0,0,-1) * 3500)
		body.apply_central_impulse(Vector3(0,1,0) * 5000)
		sfx.play()
		body.dash_lines.emitting = true
		body.dash_particles.emitting = true
