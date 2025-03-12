extends Node3D

@onready var hp_background = $HPBackground
@onready var hp_bar = $HPBar

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	hp_bar.texture.width = int(lerp(float(hp_bar.texture.width), float(get_parent().hp), 0.1))/4
	global_position = get_parent().global_position + Vector3(0,5,0)
