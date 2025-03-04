extends Node

@onready var player = get_tree().root.get_child(get_tree().root.get_child_count()-1).player

@onready var BULLET = get_parent().get_meta("bullet")

@onready var shoot_timer = $ShootTimer
@onready var shoot_point = $ShootPoint

# Called when the node enters the scene tree for the first time.
func _ready():
	shoot_timer.wait_time = randf_range(get_parent().get_meta("shoot_time")-0.5,get_parent().get_meta("shoot_time")+0.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if get_parent().alive:
		get_parent().look_at(player.global_position)

func _on_shoot_timer_timeout():
	if get_parent().alive:
		shoot()

func shoot():
	var bullet = BULLET.instantiate()
	get_parent().add_sibling(bullet)
	bullet.global_position = shoot_point.global_position
	bullet.global_rotation = get_parent().global_rotation
