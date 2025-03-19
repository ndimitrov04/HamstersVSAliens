extends RigidBody3D

@onready var damage = 50
@onready var speed = 1.5
@onready var hitbox = $Hitbox
@onready var type = ObjectTypes.TYPE.FRIENDLYBULLET

# Called when the node enters the scene tree for the first time.
func _ready():
	top_level = true
	linear_velocity = get_parent().linear_velocity
	await get_tree().create_timer(0.0001).timeout
	apply_central_impulse(global_transform.basis * Vector3(0,0,-speed))

func _on_body_entered(body):
	if "type" in body:
		if body.type == ObjectTypes.TYPE.ENEMY:
			body.take_damage(damage)
			print(body)
			print("Took Hit")
	queue_free()

func _on_timer_timeout():
	queue_free()
