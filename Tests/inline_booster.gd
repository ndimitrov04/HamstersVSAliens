extends Area3D

@onready var boost_area = $BoostArea

var inside_boost : bool = false
var player

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if inside_boost:
		player.inline_boost = Vector3(1,1,2) * boost_area.global_basis

func _on_body_entered(body):
	if body.name == "Player":
		player = body
		inside_boost = true

func _on_body_exited(body):
	if body.name == "Player":
		inside_boost = false
		body.inline_boost = Vector3(0,0,0)
