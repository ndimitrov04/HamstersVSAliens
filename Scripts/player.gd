extends RigidBody3D

@onready var main = $"../.."

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
#@onready var camera = $TwistPivot/PitchPivot/Camera
@onready var camera = $TwistPivot/PitchPivot/SpringArm3D/TraumaDetector/Camera
@onready var particle_pivot = $TwistPivot/PitchPivot/SpringArm3D/TraumaDetector/Camera/ParticlePivot
@onready var speed_lines = $TwistPivot/PitchPivot/SpringArm3D/TraumaDetector/Camera/ParticlePivot/SpeedLines
@onready var dash_lines = $TwistPivot/PitchPivot/SpringArm3D/TraumaDetector/Camera/DashLines
@onready var trauma_detector = $TwistPivot/PitchPivot/SpringArm3D/TraumaDetector
@onready var floor_detector = $FloorDetector
@onready var enemy_detector = $Ship/EnemyDetector
@onready var speed_particles = $Ship/SpeedParticles
@onready var floor_marker = $FloorMarker
@onready var hover_decal = $FloorMarker/HoverDecal
@onready var sphere = $Sphere
@onready var ship = $Ship
@onready var shoot_point = $Ship/ShootPoint
@onready var shot_cd_timer = $ShotCDTimer
@onready var heat_cd_timer = $HeatCDTimer
@onready var homing_cooldown = $HomingCooldown
@onready var sfx = $SFX

@onready var hud = $"../../HUD"
@onready var player_data = $"../../HUD/PlayerData"
@onready var stats = $"../../HUD/Stats"

@onready var EXPLOSION = preload("res://Scenes/Particles/explosion.tscn")
@onready var BULLET = preload("res://Scenes/Projectiles/light_bullet_friendly.tscn")
@onready var DEBUG_ENEMY_BULLET = preload("res://Scenes/Projectiles/light_bullet.tscn")

var MAXVELOCITY : int = 25
const INERTIAJUMPMULTIPLIER : float = 0.2

var mouse_sensitivity : float = 0.002
var twist_input : float = 0.0
var pitch_input : float = 0.0
var thrust_power : float = 60000
var jump_power : float = 60000
var floor_power : float = 120000
var exploded : bool = false

var speedboost : float = 1

var homing_target = null
var homing_available = true
var target_hit : bool = false
var shot_cooldown : bool = false
var heat_cooldown : bool = false

var max_hp : int = 100
var hp : int = 100
var max_heat : int = 100
var heat : int = 0
var max_combo : float = 100
var combo : float = 0
var gold : int = 10000
var type : ObjectTypes.TYPE = ObjectTypes.TYPE.FRIENDLY
var build_spot = null
var current_speed : float
var current_horizontal_speed : float

var damage_buff : int = 0
var hp_buff : int = 0
var speed_buff : int = 0
var jump_buff : int = 0

var dash_cost = 10
var homing_cost = 25

# Called when the node enters the scene tree for the first time.
func _ready():
	#Capture mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	current_speed = max(abs(linear_velocity.x), abs(linear_velocity.y), abs(linear_velocity.z), 0)
	current_horizontal_speed = max(abs(linear_velocity.x), abs(linear_velocity.z), 0)

	#Detect death
	if hp <= 0:
		if not exploded:
			var explosion = EXPLOSION.instantiate()
			add_sibling(explosion)
			explosion.global_position = global_position
			explosion.amount = 512
			explosion.emitting = true
			exploded = true
		hide()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		hud.game_over.show()
		return
	
	if hp > max_hp + hp_buff:
		hp = max_hp + hp_buff
	
	var input = Vector3.ZERO
	input.x = Input.get_axis("move_left","move_right")
	input.z = Input.get_axis("move_forward","move_backward")
	#Move on axes via keyboard input, relative to camera twist
	apply_central_force(twist_pivot.basis * input * (thrust_power + speed_buff) * delta * speedboost)

	#Set maximum speed
	if linear_velocity.x > MAXVELOCITY + combo / 10:
		linear_velocity.x = MAXVELOCITY + combo / 10
	elif linear_velocity.x < -MAXVELOCITY - combo / 10:
		linear_velocity.x = -MAXVELOCITY - combo / 10
	if linear_velocity.y > MAXVELOCITY * 3:
		linear_velocity.y = MAXVELOCITY * 3
	elif linear_velocity.y < -MAXVELOCITY:
		linear_velocity.y = -MAXVELOCITY
	if linear_velocity.z > MAXVELOCITY + combo / 10:
		linear_velocity.z = MAXVELOCITY + combo / 10
	elif linear_velocity.z < -MAXVELOCITY - combo / 10:
		linear_velocity.z = -MAXVELOCITY - combo / 10

	#Set maximum combo
	if combo > max_combo:
		combo = max_combo
	if combo < 0:
		combo = 0

	#Stick to ground if on ground
	if Input.is_action_pressed("floorslide") and floor_detector.is_colliding():
		apply_central_force(Vector3.DOWN * floor_power * delta)
		
	#Jump if on ground
	if Input.is_action_just_pressed("jump") and floor_detector.is_colliding():
		var jumpInertia = max(abs(linear_velocity.x), abs(linear_velocity.y), abs(linear_velocity.z)) * INERTIAJUMPMULTIPLIER
		#print(jumpInertia)
		#print((jump_power * jumpInertia))
		apply_central_impulse(Vector3.UP * ((jump_power + jump_buff) * jumpInertia / 1.3) * delta)
		sfx.jump_sfx.play()

	#Dash toward crosshair (forward)
	if Input.is_action_just_pressed("dash") and combo > dash_cost:
		apply_central_impulse(twist_pivot.basis * Vector3.FORWARD * (jump_power * (2.2 + (combo / 150)) * delta))
		combo -= dash_cost
		dash_lines.emitting = true

	if Input.is_action_pressed("shoot") and heat < max_heat:
		if not shot_cooldown:
			shoot(BULLET)
			shot_cooldown = true
			heat_cooldown = false
			shot_cd_timer.start()
			heat += 5
			heat_cd_timer.start()
	if Input.is_action_just_pressed("debug_shoot"):
		shoot(DEBUG_ENEMY_BULLET)
	if heat_cooldown and heat > 0:
		heat -= 1

	#Lock on if looking at enemy and homing attack on right click
	if enemy_detector.is_colliding() and homing_available and combo > homing_cost:
		var object = enemy_detector.get_collider(0)
		if "type" in object:
			if object.type == ObjectTypes.TYPE.ENEMY and object.alive:
				object.lock_marker.visible = true
				if Input.is_action_just_pressed("homing"):
					combo -= homing_cost
					homing_attack()
		
	#if floor_marker.is_colliding():
	hover_decal.position.y = floor_marker.get_collision_point().y
		
	#Toggle mouse focus
	if Input.is_action_pressed("unfocus"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_released("unfocus"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	#Control camera
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	#Prevent pitch from turning camera upside down (0.5 Rad)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(90))
	#Reset twist and pitch to 0 when mouse is not moving
	twist_input = 0
	pitch_input = 0
	#Have camera, floor detection raycast and spaceship
	#follow player sphere manually
	twist_pivot.position = position
	floor_detector.position = position
	floor_marker.position = position
	hover_decal.position.x = position.x
	hover_decal.position.z = position.z
	ship.position = position + Vector3(0,-0.12,-0.045)
	#Rotate ship to face the focus point of the camera
	ship.rotation = camera.global_rotation
	
	#Debug stats
	stats.text = (
		"MaxHP = " + str(max_hp + hp_buff) + "\n" +
		"Strength = " + str(50 + damage_buff) + "\n" +
		"Acceleration = " + str(thrust_power + speed_buff) + "\n" +
		"Jump Power = " + str(jump_power + jump_buff) + "\n" +
		"City HP = " + str(main.city_hp)
	)
	player_data.text = (
		"HamstersVSAliens Pre-Alpha Ver " + ProjectSettings.get_setting("application/config/version") + "\n" +
		"Linear Velocity: " + str(linear_velocity) + "\n" +
		"Angluar Velocity: " + str(angular_velocity) + "\n" +
		"Input: " + str(twist_pivot.basis * input * thrust_power * delta) + "\n" +
		"OnFloor?: " + str(floor_detector.is_colliding()) + "\n" +
		"Heat: " + str(heat) + "\n" +
		"Trauma: " + str(trauma_detector.trauma) + "\n" +
		"Combo: " + str(combo)
		)
		
	if not floor_detector.is_colliding():
		sfx.landed = false
	
	#Simulate speed
	if current_horizontal_speed > 10:
		#Spawn dust/dirt particles
		if floor_detector.is_colliding():
			speed_particles.emitting = true
			speed_particles.amount = 64 + current_horizontal_speed * 1.8
		else:
			speed_particles.emitting = false
		
		#Modify camera FOV based on horizontal speed
		camera.fov = lerpf(camera.fov, min(130, 90 + current_horizontal_speed * 1.5 - 20), 0.1)
	else:
		speed_particles.emitting = false
		camera.fov = lerpf(camera.fov, 90, 0.1)
	
	particle_pivot.global_position = camera.global_position
	
	if current_speed > 15:
		#Add speed lines
		speed_lines.emitting = true
		speed_lines.process_material.initial_velocity_min = current_speed / 5
		speed_lines.process_material.initial_velocity_max = current_speed / 5
		#Make speed lines move according to player movement and camera location
		var target_position = camera.global_position - linear_velocity.normalized()
		particle_pivot.look_at(target_position, Vector3.UP, true)
		#Add screenshake on fast movement
		if trauma_detector.trauma < 0.3:
			trauma_detector.add_trauma(0.08)
	else:
		speed_lines.emitting = false


func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = -event.relative.y * mouse_sensitivity

func homing_attack(homingRepeat : int = 175, homing_refresh : float = 0.01):
	if not homing_available:
		return
	homing_available = false
	homing_target = enemy_detector.get_collider(0)
	for i in range(0,homingRepeat):
		if target_hit:
			sfx.homing_hit_sfx.play()
			homing_cooldown.start()
			break
		if homing_target:
			var enemy_position = homing_target.global_position
			linear_velocity = Vector3(0,0,0)
			var distance = abs(position.x - enemy_position.x) + abs(position.y - enemy_position.y) + abs(position.z - enemy_position.z)
			#print(distance)
			if distance >= 10:
				linear_velocity.x = move_toward(linear_velocity.x, position.x - enemy_position.x, -abs(position.x - enemy_position.x) * 6)
				linear_velocity.y = move_toward(linear_velocity.y, position.y - enemy_position.y, -abs(position.y - enemy_position.y) * 6)
				linear_velocity.z = move_toward(linear_velocity.z, position.z - enemy_position.z, -abs(position.z - enemy_position.z) * 6)
			else:
				linear_velocity.x = move_toward(linear_velocity.x, position.x - enemy_position.x, -abs(position.x - enemy_position.x) * 30)
				linear_velocity.y = move_toward(linear_velocity.y, position.y - enemy_position.y, -abs(position.y - enemy_position.y) * 30)
				linear_velocity.z = move_toward(linear_velocity.z, position.z - enemy_position.z, -abs(position.z - enemy_position.z) * 30)
		await get_tree().create_timer(homing_refresh).timeout
	homing_target = null
	target_hit = false
	
func take_damage(damage : int):
	sphere.get_surface_override_material(0).albedo_color = Color(1.0, 0.0, 0.0, 0.6)
	var explosion = EXPLOSION.instantiate()
	add_sibling(explosion)
	explosion.global_position = global_position
	explosion.amount = 256
	explosion.emitting = true
	hp -= damage
	await get_tree().create_timer(0.5).timeout
	sphere.get_surface_override_material(0).albedo_color = Color(1.0, 1.0, 1.0, 0.6)

func shoot(object):
	var bullet = object.instantiate()
	add_child(bullet)
	bullet.damage += damage_buff
	bullet.global_position = shoot_point.global_position
	bullet.global_rotation = camera.global_rotation

func _on_body_entered(body):
	if homing_target != null:
		if body == homing_target:
			target_hit = true
			linear_velocity = Vector3(0,0,0)
			linear_velocity.x = move_toward(linear_velocity.x, -position.x + body.global_position.x, -abs(position.x - body.global_position.x)*3)
			linear_velocity.y = move_toward(linear_velocity.y, -position.y + body.global_position.y, -abs(position.y - body.global_position.y)*3)
			linear_velocity.z = move_toward(linear_velocity.z, -position.z + body.global_position.z, -abs(position.z - body.global_position.z)*3)
			#print("Target hit")
	if "type" in body:
		if body.type == ObjectTypes.TYPE.ENEMY:
			combo += 15

func _on_shot_cd_timer_timeout():
	shot_cooldown = false

func _on_heat_cd_timer_timeout():
	heat_cooldown = true

func _on_homing_cooldown_timeout():
	homing_available = true

#Collect combo from inertia while out of a homing attack
func _on_combo_clock_timeout():
	if not homing_target:
		if current_horizontal_speed <= 10:
			combo -= 0.4
		elif current_horizontal_speed <= 20:
			combo -= 0.1
		elif current_horizontal_speed > 22:
			combo += (current_horizontal_speed / MAXVELOCITY) / 8
		elif current_horizontal_speed > 27:
			combo += (current_horizontal_speed / MAXVELOCITY) / 6
		elif current_horizontal_speed > 30:
			combo += (current_horizontal_speed / MAXVELOCITY) / 5
		
		combo -= 0.05
		
		if current_horizontal_speed > 31:
			hp += 1
