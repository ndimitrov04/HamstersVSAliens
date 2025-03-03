extends GPUParticles3D

@onready var omni_light_3d = $OmniLight3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	omni_light_3d.omni_range -= 0.08
	omni_light_3d.light_energy -= 0.08


func _on_finished():
	queue_free()
