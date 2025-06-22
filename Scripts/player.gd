extends RigidBody3D

@onready var main = $"../.."

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
#@onready var camera = $TwistPivot/PitchPivot/Camera
@onready var camera = $TwistPivot/PitchPivot/SpringArm3D/TraumaDetector/Camera
@onready var spring_arm_3d = $TwistPivot/PitchPivot/SpringArm3D
@onready var particle_pivot = $TwistPivot/PitchPivot/SpringArm3D/TraumaDetector/Camera/ParticlePivot
@onready var dash_particles = $Ship/DashParticles
@onready var speed_lines = $TwistPivot/PitchPivot/SpringArm3D/TraumaDetector/Camera/ParticlePivot/SpeedLines
@onready var dash_lines = $TwistPivot/PitchPivot/SpringArm3D/TraumaDetector/Camera/DashLines
@onready var trauma_detector = $TwistPivot/PitchPivot/SpringArm3D/TraumaDetector
@onready var floor_detector = $FloorDetector
@onready var enemy_detector = $Ship/EnemyDetector
@onready var tesla_lock_on = $Ship/TeslaLockOn
@onready var speed_particles = $Ship/SpeedParticles
@onready var floor_marker = $FloorMarker
@onready var hover_decal = $FloorMarker/HoverDecal
@onready var sphere = $Sphere
@onready var ship = $Ship
@onready var shoot_point = $Ship/ShootPoint
@onready var laser = $Ship/Laser
@onready var laser_mesh = $Ship/Laser/Mesh
@onready var laser_hurtbox = $Ship/Laser/Hurtbox
@onready var lock_ons = $Ship/LockONs
@onready var shot_cd_timer = $ShotCDTimer
@onready var heat_cd_timer = $HeatCDTimer
@onready var homing_cooldown = $HomingCooldown
@onready var boosted = $Boosted
@onready var sfx = $SFX
@onready var electricity = $Ship/Electricity


@onready var hud = $"../../HUD"
@onready var player_data = $"../../HUD/PlayerData"
@onready var stats = $"../../HUD/Stats"

@onready var EXPLOSION = preload("res://Scenes/Particles/explosion.tscn")
@onready var BULLET = preload("res://Scenes/Projectiles/light_bullet_friendly.tscn")
@onready var DEBUG_ENEMY_BULLET = preload("res://Scenes/Projectiles/light_bullet.tscn")
@onready var AUTOLASER = preload("res://Scenes/laser.tscn")

var MAXVELOCITY : float = 25
const INERTIAJUMPMULTIPLIER : float = 0.2
const DEFAULTSPRINGCAMERA : float = 1.705

var mouse_sensitivity : float = 0.002
var twist_input : float = 0.0
var pitch_input : float = 0.0
var thrust_power : float = 60000
var jump_power : float = 60000
var floor_power : float = 120000
var exploded : bool = false

var speedboost : float = 1
var inline_boost : Vector3 = Vector3(0,0,0)

var homing_target = null
var homing_available = true
var target_hit : bool = false
var shot_cooldown : bool = false
var heat_cooldown : bool = false
var following : PathFollow3D = null

var max_hp : int = 100
var hp : int = 100
var max_heat : float = 100
var heat : float = 0
var max_combo : float = 100
var combo : float = 0
var gold : int = 50
var type : ObjectTypes.TYPE = ObjectTypes.TYPE.FRIENDLY
var build_spot = null
var current_speed : float
var current_horizontal_speed : float

var damage_buff : int = 0
var hp_buff : int = 0
var speed_buff : int = 0
var jump_buff : int = 0

var dash_cost : int = 10
var homing_cost : int = 25

enum Weapon {PLASMAGUN, LASER, HOMING}
var unlocked_weapons = [Weapon.PLASMAGUN, Weapon.LASER, Weapon.HOMING]
#var current_weapon : Weapon = unlocked_weapons[0]
var current_weapon : Weapon = Weapon.PLASMAGUN

var laser_force : float = 50
var debug_laser_marker : bool = false #to be used for debugging the laser

var tesla_objects = []

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().paused = false
	main.process_mode = ProcessMode.PROCESS_MODE_INHERIT
	
	#Capture mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	await Engine.get_main_loop().process_frame
	await Engine.get_main_loop().process_frame
	await Engine.get_main_loop().process_frame
	hud.weapon_list.select(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	current_speed = max(abs(linear_velocity.x), abs(linear_velocity.y), abs(linear_velocity.z), 0)
	current_horizontal_speed = max(abs(linear_velocity.x), abs(linear_velocity.z), 0)
	
	#Detect death
	if hp <= 0:
		hud.fade_out.show()
		hud.game_over.show()
		hud.animation_player.play("gameover")
		MusicPlayer.stream = MusicPlayer.game_over_music
		MusicPlayer.play()
		if not exploded:
			var explosion = EXPLOSION.instantiate()
			add_sibling(explosion)
			explosion.global_position = global_position
			explosion.amount = 512
			explosion.emitting = true
			exploded = true
		linear_velocity.lerp(Vector3(0,0,0),8)
		hide()
		await get_tree().create_timer(1).timeout
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		main.process_mode = ProcessMode.PROCESS_MODE_DISABLED
		return
	
	if hp > max_hp + hp_buff:
		hp = max_hp + hp_buff
	
	var input = Vector3.ZERO
	input.x = Input.get_axis("move_left","move_right")
	input.z = Input.get_axis("move_forward","move_backward")
	#Move on axes via keyboard input, relative to camera twist
	apply_central_force((twist_pivot.basis * input * (thrust_power + speed_buff) * delta * speedboost) + inline_boost)

	#Move to follow autocarry
	if following != null:
		global_position = following.sphere.global_position

	#Set maximum speed
	if linear_velocity.x > (MAXVELOCITY + combo / 10) + inline_boost.x:
		linear_velocity.x = (MAXVELOCITY + combo / 10) + inline_boost.x
	elif linear_velocity.x < (-MAXVELOCITY - combo / 10) - inline_boost.x:
		linear_velocity.x = (-MAXVELOCITY - combo / 10) - inline_boost.x
	if linear_velocity.y > MAXVELOCITY * 3:
		linear_velocity.y = MAXVELOCITY * 3
	elif linear_velocity.y < -MAXVELOCITY:
		linear_velocity.y = -MAXVELOCITY
	if linear_velocity.z > (MAXVELOCITY + combo / 10) + inline_boost.z:
		linear_velocity.z = (MAXVELOCITY + combo / 10) + inline_boost.z
	elif linear_velocity.z < (-MAXVELOCITY - combo / 10) - inline_boost.z:
		linear_velocity.z = (-MAXVELOCITY - combo / 10) - inline_boost.z

	#Set maximum combo
	if combo > max_combo:
		combo = max_combo
	if combo < 0:
		combo = 0

	#Stick to ground if on ground
	if Input.is_action_pressed("floorslide") and floor_detector.is_colliding():
		apply_central_force(Vector3.DOWN * floor_power * delta)
		
	#Jump if on ground
	if Input.is_action_just_pressed("jump") and (floor_detector.is_colliding() or following != null):
		var jumpInertia = max(abs(linear_velocity.x), abs(linear_velocity.y), abs(linear_velocity.z)) * INERTIAJUMPMULTIPLIER
		#print(jumpInertia)
		#print((jump_power * jumpInertia))
		apply_central_impulse(Vector3.UP * ((jump_power + jump_buff) * jumpInertia / 1.3) * delta)
		sfx.jump_sfx.play()
		if following:
			apply_central_impulse(following.basis * Vector3.BACK * (following.speed) * (jump_power * (2.3 + (combo / 150)) * delta))
			MAXVELOCITY = 40
			boosted.start()
			following.hooked = false
			for trolley in following.get_parent().get_children():
				if "initial_progress" in trolley:
					trolley.progress_ratio = trolley.initial_progress
			following = null

	#Dash toward crosshair (forward)
	if Input.is_action_just_pressed("dash") and combo > dash_cost:
		apply_central_impulse(twist_pivot.basis * Vector3.FORWARD * (jump_power * 2.3) * delta)
		combo -= dash_cost
		sfx.dash_sfx.play()
		dash_lines.emitting = true
		dash_particles.emitting = true
	
	if current_weapon == Weapon.HOMING and heat < max_heat:
		track_homing()
	if Input.is_action_pressed("shoot") and heat < max_heat:
		match current_weapon:
			Weapon.PLASMAGUN:
				if not shot_cooldown:
					shoot(BULLET)
					shot_cooldown = true
					heat_cooldown = false
					shot_cd_timer.start()
					heat += 5 - (combo / 25)
					heat_cd_timer.start()
			Weapon.LASER:
				shoot_laser()
				heat_cooldown = false
				heat += 20 * delta - (combo / 350)
				heat_cd_timer.start()
	else:
		sfx.laser_sfx.stop()
		sfx.electric_sfx.stop()
		electricity.hide()
		laser_mesh.hide()
		laser_hurtbox.monitoring = false
	if heat_cooldown and heat > 0:
		heat -= 1

	if Input.is_action_just_pressed("weapon_1"):
		current_weapon = Weapon.PLASMAGUN
		laser_hurtbox.monitoring = false
		laser_mesh.hide()
		hud.weapon_list.select(0)
	if Input.is_action_just_pressed("weapon_2"):
		if Weapon.LASER in unlocked_weapons:
			current_weapon = Weapon.LASER
			hud.weapon_list.select(1)
	if Input.is_action_just_pressed("weapon_3"):
		if Weapon.HOMING in unlocked_weapons:
			laser_hurtbox.monitoring = false
			laser_mesh.hide()
			current_weapon = Weapon.HOMING
			hud.weapon_list.select(2)

	if Input.is_action_just_pressed("debug_shoot"):
		shoot(DEBUG_ENEMY_BULLET)
	if Input.is_action_just_pressed("debug_axis_lock"):
		if axis_lock_linear_y:
			axis_lock_linear_y = false
		else:
			axis_lock_linear_y = true
	if Input.is_action_just_pressed("debug_money_cheat"):
		gold += 10000

	#Lock onto hookable object
	if enemy_detector.is_colliding():
		var object = enemy_detector.get_collider(0)
		if object:
			if "hookable" in object.get_parent():
				if object.get_parent().hookable:
					#change color here
					object.get_parent().lock_marker.visible = true
					object.get_parent().lock_marker.modulate = Color("Red")
					if Input.is_action_just_pressed("homing"):
						homing_attack()

	#Lock on if looking at enemy and homing attack on right click
	if enemy_detector.is_colliding() and homing_available and combo > homing_cost:
		var object = enemy_detector.get_collider(0)
		if "type" in object:
			if object.type == ObjectTypes.TYPE.ENEMY and object.alive:
				object.lock_marker.visible = true
				object.lock_marker.modulate = Color("Red")
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
		"Combo: " + str(combo) + "\n" +
		"Currently lasering?: " + str(debug_laser_marker)
		)
		
	if not floor_detector.is_colliding():
		sfx.landed = false
	
	#Simulate speed
	if current_horizontal_speed > 10:
		#Spawn dust/dirt particles
		if floor_detector.is_colliding():
			speed_particles.emitting = true
			speed_particles.amount_ratio = 0.2 + current_horizontal_speed / 10
		else:
			speed_particles.emitting = false
		
		#Modify camera FOV based on horizontal speed
		camera.fov = lerpf(camera.fov, min(130, 90 + current_horizontal_speed * 1.5 - 20), 0.1)
	else:
		speed_particles.emitting = false
		camera.fov = lerpf(camera.fov, 90, 0.1)
	
	particle_pivot.global_position = camera.global_position
	
	if current_speed > 20:
		#Add speed lines
		speed_lines.emitting = true
		speed_lines.process_material.initial_velocity_min = current_speed / 5
		speed_lines.process_material.initial_velocity_max = current_speed / 5
		#Make speed lines move according to player movement and camera location
		var target_position = camera.global_position - linear_velocity.normalized()
		#Check if UP and target are aligned before looking at target, prevent error spam (~40-200 errors)
		if abs(target_position.normalized().y) < 0.99:
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
	homing_available = true
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

func shoot_laser():
	sfx.laser_sfx.play()
	laser_mesh.show()
	laser_hurtbox.monitoring = true
	laser_hurtbox.monitorable = true

func track_homing():
	for object in tesla_objects:
		print(object.name)
		object.lock_marker.visible = true
		object.lock_marker.modulate = Color("Cyan")
		#object.get_parent().lock_marker.visible = true
		if Input.is_action_pressed("shoot") and heat < max_heat and tesla_objects.size() > 0:
			heat_cooldown = false
			heat += 40 * get_process_delta_time() - (combo / 400)
			heat_cd_timer.start()
			electricity.show()
			var autolaser
			if autolaser == null:
				autolaser = AUTOLASER.instantiate()
				lock_ons.add_child(autolaser)
				autolaser.global_position = ship.global_position
				autolaser.look_at(object.global_position)
			else:
				autolaser.global_position = ship.global_position
				autolaser.look_at(object.global_position)
		else:
			electricity.hide()

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

func _on_laser_cd_timer_timeout():
	pass # Replace with function body.

func _on_heat_cd_timer_timeout():
	heat_cooldown = true

func _on_homing_cooldown_timeout():
	homing_available = true

#Collect combo from inertia while out of a homing attack
func _on_combo_clock_timeout():
	if not homing_target and following == null:
		if current_horizontal_speed <= 10:
			combo -= 0.2
		elif current_horizontal_speed <= 20:
			combo -= 0.05
		elif current_horizontal_speed > 22:
			combo += (current_horizontal_speed / MAXVELOCITY) / 7
		elif current_horizontal_speed > 27:
			combo += (current_horizontal_speed / MAXVELOCITY) / 5
		elif current_horizontal_speed > 30:
			combo += (current_horizontal_speed / MAXVELOCITY) / 4
		
		combo -= 0.05
		
		if current_horizontal_speed > 31:
			hp += 1

func _on_boosted_timeout():
	while MAXVELOCITY > 25:
		MAXVELOCITY -= 0.001 * get_physics_process_delta_time()
	if MAXVELOCITY < 25:
		MAXVELOCITY = 25

func _on_hurtbox_body_entered(body):
	if "type" in body:
		if body.type == ObjectTypes.TYPE.ENEMY:
			if "lasered" in body:
				body.lasered = true
				body.laser_force = laser_force + damage_buff
			else:
				print("Error: Enemy body cannot be lasered")

func _on_hurtbox_body_exited(body):
	if "type" in body:
		if body.type == ObjectTypes.TYPE.ENEMY:
			if "lasered" in body:
				body.lasered = false

func _on_tesla_lock_on_body_entered(body):
	if "type" in body:
		if body.type == ObjectTypes.TYPE.ENEMY and body.alive:
			tesla_objects.append(body)

func _on_tesla_lock_on_body_exited(body):
	tesla_objects.erase(body)
