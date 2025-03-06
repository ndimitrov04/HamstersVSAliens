extends Area3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_body_entered(body):
	if body.name == "Player":
		body.speedboost = 1.1
		body.MAXVELOCITY = 30

func _on_body_exited(body):
	if body.name == "Player":
		if body.speedboost > 1:
			body.speedboost = 1
			body.MAXVELOCITY = 25
