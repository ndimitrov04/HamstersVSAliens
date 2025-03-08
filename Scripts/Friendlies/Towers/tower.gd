extends RigidBody3D

@onready var EXPLOSION = preload("res://Scenes/Particles/explosion.tscn")

@onready var hp : int = 15

@onready var type : ObjectTypes.TYPE = ObjectTypes.TYPE.FRIENDLY

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if hp <= 0:
		axis_lock_linear_x = false
		axis_lock_linear_y = false
		axis_lock_linear_z = false
		axis_lock_angular_x = false
		axis_lock_angular_y = false
		axis_lock_angular_z = false

func take_damage(damage : int, explosion = EXPLOSION.instantiate()):
	add_child(explosion)
	explosion.global_position = global_position
	explosion.amount = 256
	explosion.emitting = true
	hp -= damage
