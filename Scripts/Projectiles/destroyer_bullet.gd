extends RigidBody3D

@onready var EXPLOSION = preload("res://Scenes/Particles/explosion.tscn")
@onready var EXPLOSION_HURT = preload("res://Scenes/Projectiles/explosion_hurt.tscn")

@onready var damage = 40
@onready var speed = 0.8
@onready var type = ObjectTypes.TYPE.BULLET

# Called when the node enters the scene tree for the first time.
func _ready():
	top_level = true
	linear_velocity = get_parent().linear_velocity
	await get_tree().create_timer(0.0001).timeout
	apply_central_impulse(global_transform.basis * Vector3(0,0,-speed))

func _on_body_entered(body):
	if "type" in body:
		if body.type == ObjectTypes.TYPE.FRIENDLY:
			body.take_damage(damage)
	explode()
	await get_tree().create_timer(0.2).timeout
	queue_free()

func _on_timer_timeout():
	explode()
	await get_tree().create_timer(0.2).timeout
	queue_free()

func explode(explosion = EXPLOSION.instantiate(), explosion_hurt = EXPLOSION_HURT.instantiate()):
	add_sibling(explosion)
	explosion.global_position = global_position
	explosion.amount = 2048
	explosion.emitting = true
	axis_lock_linear_y = false
	add_sibling(explosion_hurt)
	explosion_hurt.global_position = global_position
