extends RigidBody3D

@onready var BULLET = get_meta("bullet")
@onready var EXPLOSION = preload("res://Scenes/Particles/explosion.tscn")

@onready var turret = get_node(get_meta("turret_node"))
@onready var gun_model = $Model/RootNode/turret_single/turret
@onready var shoot_timer = $ShootTimer
@onready var shoot_point = $Turret/ShootPoint
@onready var hp_projector = $HPProjector
@onready var hp_bar = $HPProjector/HPBar
@onready var shield_regen_timer = $ShieldRegenTimer
@onready var shield_model = $Shield

@onready var targeted_enemy = null
@onready var max_hp : int = get_meta("hp")
@onready var hp : int = get_meta("hp")
@onready var max_shield : int = get_meta("shield")
@onready var shield : int = get_meta("shield")
@onready var shield_regen : bool = false
@onready var alive : bool = true

@onready var type : ObjectTypes.TYPE = ObjectTypes.TYPE.FRIENDLY
@onready var build_spot = null

@onready var bullet_speed

@onready var build_type : ObjectTypes.BUILDTYPE = ObjectTypes.BUILDTYPE.FASTTURRET

var tower = null

var upgraded : bool = false
var upgrade_cost_1 = 45
var upgrade_cost_2 = 25
var upgrade_description_1 = "Faster shooting speed"
var upgrade_description_2 = "Stronger shield"

func upgrade1():
	upgraded = true
	tower.b_model.material_override.albedo_color = Color("ff0909")
	shoot_timer.wait_time /= 2
	
func upgrade2():
	upgraded = true
	tower.b_model.material_override.albedo_color = Color("387248")
	max_shield += 150

# Called when the node enters the scene tree for the first time.
func _ready():
	shoot_timer.wait_time = randf_range(get_meta("shoot_time")-0.5,get_meta("shoot_time")+0.5)
	var testbullet = BULLET.instantiate()
	add_child(testbullet)
	bullet_speed = testbullet.speed
	testbullet.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if hp > max_hp:
		hp = max_hp
	
	if shield <= 0:
		shield = 0
		shield_model.hide()
	else:
		shield_model.show()
		
	if shield > max_shield:
		shield = max_shield
	
	if hp <= 0:
		die()
	
	if alive and targeted_enemy != null and bullet_speed != null:
		if "type" in targeted_enemy:
			if targeted_enemy.type == ObjectTypes.TYPE.ENEMY:
				var bullet_travel_time : float = predict_bullet_travel_time(targeted_enemy.global_position, bullet_speed)
				var predicted_enemy_position : Vector3 = predict_enemy_location(targeted_enemy, bullet_travel_time)
				
				#print("EnemyPos: " + str(targeted_enemy.global_position))
				#print("EnemyVel: " + str(targeted_enemy.linear_velocity))
				#print("PredictPos: " + str(predicted_enemy_position))
				turret.look_at(predicted_enemy_position)
				gun_model.look_at(predicted_enemy_position,Vector3.UP,true)

func predict_bullet_travel_time(enemy_position, b_speed) -> float:
	return global_position.distance_to(enemy_position) / (b_speed)

# Predicts where the enemy will be after 1 frame of movement
# Because GODOT's velocity is calculated in units per second:
# resultPos = startPos + velocity*time   			// returns where the object will be after 1 second
# resultPos = startPos + ((velocity*delta)*time) 	// returns where the object will be after 1 frame
func predict_enemy_location(enemy, bullet_travel_time) -> Vector3:
	return enemy.global_position + ((enemy.linear_velocity * get_process_delta_time()) * bullet_travel_time)

func shoot():
	var bullet = BULLET.instantiate()
	add_child(bullet)
	bullet.speed = 4
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

func take_damage(damage : int, explosion = EXPLOSION.instantiate()):
	add_child(explosion)
	explosion.global_position = global_position
	shield_regen = false
	shield_regen_timer.start()
	if shield <= 0:
		hp -= damage
		explosion.amount = 256
		explosion.emitting = true
	else:
		shield -= damage
		explosion.amount = 64
		explosion.emitting = true

func die(explosion = EXPLOSION.instantiate()):
	alive = false
	add_sibling(explosion)
	explosion.global_position = global_position
	explosion.amount = 256
	explosion.emitting = true
	await get_tree().create_timer(0.5).timeout
	if build_spot != null:
		build_spot.building = null
	queue_free()

func _on_shoot_timer_timeout():
	if alive and targeted_enemy:
		shoot()
	retarget()

func _on_shield_regen_timer_timeout():
	shield_regen = true

func _on_shield_regen_tick_timeout():
	if shield_regen:
		shield += 10
