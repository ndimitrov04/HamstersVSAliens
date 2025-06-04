extends Area3D

@onready var supportbox = $Supportbox
@onready var area_viewer = $AreaViewer

var boosted_boost = 1.1
var velocity_boost = 5

var debug_ctr = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(_delta):
	pass

func _on_body_entered(body):
	if body.name == "Player":
		print("speedboost active" + str(debug_ctr))
		debug_ctr += 1
		body.speedboost = boosted_boost
		body.MAXVELOCITY += velocity_boost

func _on_body_exited(body):
	if body.name == "Player":
		print("speedboost disabled" + str(debug_ctr))
		debug_ctr += 1
		if body.speedboost > 1:
			body.speedboost = 1
			body.MAXVELOCITY -= velocity_boost
