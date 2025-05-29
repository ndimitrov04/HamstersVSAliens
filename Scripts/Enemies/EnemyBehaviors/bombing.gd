extends Node

@onready var BULLET = get_parent().get_meta("bullet")

@onready var shoot_timer = $ShootTimer
@onready var shoot_point = $ShootPoint
@onready var bullet_siblings : bool = get_parent().get_meta("bullet_siblings")
@onready var track_player : bool = get_parent().get_meta("track_player")

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(0.5).timeout
	shoot_timer.wait_time = randf_range(get_parent().get_meta("shoot_time")-0.5,get_parent().get_meta("shoot_time")+0.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass
	
func _on_shoot_timer_timeout():
	if get_parent().alive and not get_parent().has_meta("max_bullets"):
		shoot()
	elif get_parent().alive and get_parent().has_meta("max_bullets"):
		if get_parent().get_meta("max_bullets") > 0:
			get_parent().set_meta("max_bullets", get_parent().get_meta("max_bullets")-1)
			shoot()

func shoot():
	var bullet = BULLET.instantiate()
	if not bullet_siblings:
		get_parent().add_child(bullet)
	else:
		get_parent().add_sibling(bullet)
	bullet.global_position = shoot_point.global_position
	bullet.global_rotation = shoot_point.global_rotation
	bullet.scale = Vector3(3,3,3)
	bullet.linear_velocity = Vector3(0,0,0)
	bullet.apply_central_impulse(Vector3(0,-bullet.speed,0))
	await get_tree().create_timer(0.0001).timeout
	bullet.linear_velocity = Vector3(0,0,0)
	bullet.apply_central_impulse(Vector3(0,-bullet.speed,0))
