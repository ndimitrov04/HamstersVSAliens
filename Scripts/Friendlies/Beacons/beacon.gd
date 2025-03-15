extends RigidBody3D

@onready var model = $Model

@onready var EXPLOSION = preload("res://Scenes/Particles/explosion.tscn")

@onready var max_hp : int = get_meta("hp")
@onready var hp : int = get_meta("hp")
@onready var fallpoint : int = get_meta("fallpoint")

@onready var type : ObjectTypes.TYPE = ObjectTypes.TYPE.FRIENDLY
@onready var build_spot = null

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(0.2).timeout
	position += Vector3(0,10,0)
	rotation = Vector3(0,0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if hp > max_hp:
		hp = max_hp
	
	if hp <= 0:
		build_spot.building = null
		queue_free()

func take_damage(damage : int, explosion = EXPLOSION.instantiate()):
	add_sibling(explosion)
	explosion.global_position = global_position
	explosion.amount = 256
	explosion.emitting = true
	hp -= damage
