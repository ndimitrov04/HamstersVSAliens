extends Node3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass

func _on_rusher_body_entered(body):
	if body.name == "Player":
		body.take_damage(75)
		get_parent().hp = 0
		get_parent().hit_ground = true
		get_parent().die()
