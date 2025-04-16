extends RigidBody3D

@onready var targets = $"../../Friendlies"
@onready var target
@onready var target_player : bool = get_meta("target_player")
@onready var player = $"../../Friendlies/Player"
@onready var hud = $"../../HUD"

@onready var hitbox = $Hitbox
@onready var lock_marker = $LockMarker
@onready var model = $Model

@onready var EXPLOSION = preload("res://Scenes/Particles/explosion.tscn")

var alive : bool = true
var hit_ground : bool = false
var screenshake_exectued : bool = false
var type : ObjectTypes.TYPE = ObjectTypes.TYPE.ENEMY
var not_followable : bool = false

@onready var hp = get_meta("hp")

# Called when the node enters the scene tree for the first time.
func _ready():
	if has_meta("targets"):
		targets = get_node(get_meta("targets"))
	if has_meta("not_followable"):
		not_followable = get_meta("not_followable")
	if target_player:
		target = $"../../Friendlies/Player"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	#debug_data.text = (
	#	"Alive?: " + str(alive) + "\n" +
	#	"HitGround: " + str(hitGround)
	#)
	if not target_player:
		retarget()
	
	if alive and hp <= 0:
		die()
	
	if not alive and hit_ground:
		await get_tree().create_timer(0.5).timeout
		player.gold += get_meta("gold")
		hud.update_game_info()
		queue_free()

func _on_body_entered(body):
	var explosion
	
	if body.name == "Player":
		die()
	
	if body.name == "HTerrain":
		hit_ground = true
		explosion = EXPLOSION.instantiate()
		add_sibling(explosion)
		explosion.global_position = global_position
		explosion.amount = 256
		explosion.explosiveness = 0.9
		explosion.emitting = true

func _on_lock_timeout_timeout():
	lock_marker.visible = false

func take_damage(damage : int, explosion = EXPLOSION.instantiate()):
	add_sibling(explosion)
	explosion.global_position = global_position
	explosion.amount = 128
	explosion.emitting = true
	hp -= damage

func die(explosion = EXPLOSION.instantiate()):
	alive = false
	angular_damp = 1
	add_sibling(explosion)
	explosion.global_position = global_position
	explosion.amount = 256
	explosion.emitting = true
	axis_lock_linear_y = false

func retarget():
	var closest_enemy_distance = 9999
	var closest_enemy = null
	for enemy in targets.get_children():
		if enemy == self:
			continue
		if "not_followable" in enemy:
			if enemy.not_followable:
				continue
		var distance_to_enemy = abs(position.x - enemy.global_position.x) + abs(position.y - enemy.global_position.y) + abs(position.z - enemy.global_position.z)
		if distance_to_enemy < closest_enemy_distance:
			closest_enemy_distance = distance_to_enemy
			closest_enemy = enemy
	target = closest_enemy
