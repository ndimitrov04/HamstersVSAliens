extends RigidBody3D

@onready var damage = 10
@onready var speed = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	top_level = true
	await get_tree().create_timer(0.1).timeout
	apply_central_impulse(global_transform.basis * Vector3(0,0,-speed))

func _on_body_entered(body):
	if body.name == "Player":
		body.take_damage(damage)
		queue_free()

func _on_timer_timeout():
	queue_free()
