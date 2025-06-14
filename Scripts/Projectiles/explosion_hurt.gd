extends Area3D

var damage = 25

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if "type" in body:
		if body.type == ObjectTypes.TYPE.FRIENDLY:
			body.take_damage(damage)
	await get_tree().create_timer(0.1).timeout
	queue_free()
