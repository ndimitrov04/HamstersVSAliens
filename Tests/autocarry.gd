extends PathFollow3D

@onready var lock_marker = $LockMarker

var hookable : bool = true
var hooked : bool = false
@onready var initial_progress : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_progress = progress_ratio

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if hooked:
		progress += 40 * delta
	else:
		progress += 2 * delta

func _on_lock_timeout_timeout():
	lock_marker.visible = false

func _on_snap_body_entered(body):
	if body.name == "Player":
		if body.following == null:
			body.following = self
			hooked = true
