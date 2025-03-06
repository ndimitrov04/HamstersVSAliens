extends RigidBody3D

@onready var BULLET = get_meta("bullet")

@onready var turret = get_node(get_meta("turret_node"))
@onready var gun_model = $Model/RootNode/turret_single/turret
@onready var shoot_timer = $ShootTimer
@onready var shoot_point = $Turret/ShootPoint

@onready var targeted_enemy = null
@onready var hp = get_meta("hp")
@onready var alive = true

# Called when the node enters the scene tree for the first time.
func _ready():
	shoot_timer.wait_time = randf_range(get_meta("shoot_time")-0.5,get_meta("shoot_time")+0.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if alive and targeted_enemy != null:
		turret.look_at(targeted_enemy.global_position)
		gun_model.look_at(targeted_enemy.global_position,Vector3.UP,true)

func _on_shoot_timer_timeout():
	if alive and targeted_enemy:
		shoot()
	retarget()

func shoot():
	var bullet = BULLET.instantiate()
	add_child(bullet)
	bullet.global_position = shoot_point.global_position
	bullet.global_rotation = turret.global_rotation

func retarget():
	var closest_enemy_distance = 9999
	var closest_enemy = null
	for enemy in get_tree().root.get_child(get_tree().root.get_child_count()-1).enemies.get_children():
		var distance_to_enemy = abs(position.x - enemy.global_position.x) + abs(position.y - enemy.global_position.y) + abs(position.z - enemy.global_position.z)
		if distance_to_enemy < closest_enemy_distance:
			closest_enemy_distance = distance_to_enemy
			closest_enemy = enemy
	targeted_enemy = closest_enemy
