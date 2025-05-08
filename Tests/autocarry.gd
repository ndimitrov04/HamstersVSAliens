extends PathFollow3D

@onready var lock_marker = $LockMarker
@onready var sphere = $Sphere

const MAXSPEED = 40
var speed = 10

var hookable : bool = true
var hooked : bool = false
var input : Vector3 = Vector3(0,0,0)
@onready var initial_progress : float = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_progress = progress_ratio

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if hooked:
		lock_marker.visible = false
		if speed < MAXSPEED:
			speed += 1 * delta
		progress += speed * delta
		input.x = Input.get_axis("move_left","move_right")
		if h_offset < 1.5:
			h_offset += -1 * input.x * delta
		else:
			h_offset = 1.49
		if h_offset > -1.5:
			h_offset += -1 * input.x * delta
		else:
			h_offset = -1.49
		if abs(h_offset) > 0:
			h_offset = lerpf(h_offset,0,0.2 * delta)
	else:
		progress += 2 * delta
		speed = 10
		if sphere.visible:
			sphere.hide()
		if h_offset != 0:
			h_offset = 0

func _on_lock_timeout_timeout():
	lock_marker.visible = false

func _on_snap_body_entered(body):
	if body.name == "Player":
		if body.following == null:
			body.following = self
			hooked = true
			sphere.show()
