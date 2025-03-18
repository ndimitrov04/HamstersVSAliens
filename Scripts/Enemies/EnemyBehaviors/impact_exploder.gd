extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func _on_rusher_body_entered(body):
	if body.name == "Player":
		get_parent().die()
		body.take_damage(75)
