extends Node2D

@onready var camera = $"../../../../Friendlies/Player/TwistPivot/PitchPivot/SpringArm3D/TraumaDetector/Camera"

var point_direction = null
var free_marked = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if point_direction and rotation:
		rotation = camera.global_rotation.y - point_direction.rotation.y
	
	if point_direction == null and not free_marked:
		free_marked = true
		queue_free()
