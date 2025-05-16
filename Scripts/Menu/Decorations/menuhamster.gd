extends RigidBody3D

@onready var sphere = $Sphere
@onready var hitbox = $Hitbox
@onready var ship = $Ship
@onready var incoming_ships = $"../IncomingShips"

# Called when the node enters the scene tree for the first time.
func _ready():
	#look_at(incoming_ships.global_position)
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	sphere.rotation_degrees += Vector3(250,0,0) * delta
