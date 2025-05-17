extends Node2D

@onready var camera = $"../../../../Friendlies/Player/TwistPivot/PitchPivot/SpringArm3D/TraumaDetector/Camera"

var point_direction = null
var free_marked = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if point_direction != null:
		rotation = camera.global_rotation.y - point_direction.global_rotation.y
	
	if point_direction == null and not free_marked:
		free_marked = true
		await get_tree().process_frame
		queue_free()
