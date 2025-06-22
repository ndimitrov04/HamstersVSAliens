extends Node3D

@onready var mesh = $Mesh
@onready var hurtbox = $Hurtbox
@onready var timeout = $Timeout
@onready var player = get_parent().get_parent().get_parent()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
	
func _on_hurtbox_body_entered(body):
	if "type" in body:
		if body.type == ObjectTypes.TYPE.ENEMY:
			if "lasered" in body:
				body.lasered = true
				body.laser_force = player.laser_force + player.damage_buff
			else:
				print("Error: Enemy body cannot be lasered")

func _on_hurtbox_body_exited(body):
	if "type" in body:
		if body.type == ObjectTypes.TYPE.ENEMY:
			if "lasered" in body:
				body.lasered = false
	
func _on_timeout_timeout():
	queue_free()
