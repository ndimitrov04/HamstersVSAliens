extends RigidBody3D

@onready var hitbox = $Hitbox
@onready var lock_marker = $LockMarker

@onready var EXPLOSION = preload("res://Scenes/Particles/explosion.tscn")

var alive : bool = true
var hitGround : bool = false
var type : ObjectTypes.TYPE = ObjectTypes.TYPE.ENEMY

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#debug_data.text = (
	#	"Alive?: " + str(alive) + "\n" +
	#	"HitGround: " + str(hitGround)
	#)
	
	if not alive and hitGround:
		await get_tree().create_timer(0.5).timeout
		queue_free()

func _on_body_entered(body):
	var explosion
	
	if body.name == "Player":
		alive = false
		explosion = EXPLOSION.instantiate()
		add_sibling(explosion)
		explosion.global_position = global_position
		explosion.amount = 256
		explosion.emitting = true
		axis_lock_linear_y = false
	
	if body.name == "HTerrain":
		hitGround = true
		explosion = EXPLOSION.instantiate()
		add_sibling(explosion)
		explosion.global_position = global_position
		explosion.amount = 4096
		explosion.explosiveness = 0.9
		explosion.emitting = true

func _on_lock_timeout_timeout():
	lock_marker.visible = false
