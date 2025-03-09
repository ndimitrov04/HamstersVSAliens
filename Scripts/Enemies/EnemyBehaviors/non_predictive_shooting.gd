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
	if get_parent().alive:
		if track_player:
			get_parent().look_at(get_parent().target.global_position)
		else:
			get_parent().look_at(get_parent().target.global_position * Vector3(1,0,1) + Vector3(0,get_parent().global_position.y,0))

func _on_shoot_timer_timeout():
	if get_parent().alive:
		shoot()

func shoot():
	var bullet = BULLET.instantiate()
	if not bullet_siblings:
		get_parent().add_child(bullet)
	else:
		get_parent().add_sibling(bullet)
	bullet.global_position = shoot_point.global_position
	bullet.global_rotation = get_parent().global_rotation
