extends GPUParticles3D

@onready var omni_light_3d = $OmniLight3D
@onready var sfx = $SFX

# Called when the node enters the scene tree for the first time.
func _ready():
	await Engine.get_main_loop().process_frame
	sfx.volume_db = self.amount / 1024
	sfx.play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	omni_light_3d.omni_range -= 0.8 * delta
	omni_light_3d.light_energy -= 0.8 * delta


func _on_finished():
	queue_free()
