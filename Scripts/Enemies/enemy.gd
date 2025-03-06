extends RigidBody3D

@onready var player = get_tree().root.get_child(get_tree().root.get_child_count()-1).player

@onready var hitbox = $Hitbox
@onready var lock_marker = $LockMarker
@onready var model = $Model

@onready var EXPLOSION = preload("res://Scenes/Particles/explosion.tscn")

var alive : bool = true
var hit_ground : bool = false
var type : ObjectTypes.TYPE = ObjectTypes.TYPE.ENEMY

@onready var hp = get_meta("hp")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	#debug_data.text = (
	#	"Alive?: " + str(alive) + "\n" +
	#	"HitGround: " + str(hitGround)
	#)
	
	if hp <= 0:
		die()
	
	if not alive and hit_ground:
		await get_tree().create_timer(0.5).timeout
		queue_free()

func _on_body_entered(body):
	var explosion
	
	if body.name == "Player":
		die()
	
	if body.name == "HTerrain":
		hit_ground = true
		explosion = EXPLOSION.instantiate()
		add_child(explosion)
		explosion.global_position = global_position
		explosion.amount = 4096
		explosion.explosiveness = 0.9
		explosion.emitting = true

func _on_lock_timeout_timeout():
	lock_marker.visible = false

func take_damage(damage : int, explosion = EXPLOSION.instantiate()):
	add_child(explosion)
	explosion.global_position = global_position
	explosion.amount = 256
	explosion.emitting = true
	hp -= damage

func die(explosion = EXPLOSION.instantiate()):
	alive = false
	add_child(explosion)
	explosion.global_position = global_position
	explosion.amount = 256
	explosion.emitting = true
	axis_lock_linear_y = false
