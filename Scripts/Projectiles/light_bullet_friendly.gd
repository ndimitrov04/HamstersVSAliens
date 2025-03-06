extends RigidBody3D

@onready var damage = 50
@onready var speed = 1.1

# Called when the node enters the scene tree for the first time.
func _ready():
	top_level = true
	await get_tree().create_timer(0.1).timeout
	apply_central_impulse(global_transform.basis * Vector3(0,0,-speed))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	pass

func _on_body_entered(body):
	if "type" in body:
		if body.type == ObjectTypes.TYPE.ENEMY:
			body.take_damage(damage)
			print(body)
			print("Took Hit")
			queue_free()

func _on_timer_timeout():
	queue_free()
