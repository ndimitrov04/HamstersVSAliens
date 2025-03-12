extends RigidBody3D

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var camera = $TwistPivot/PitchPivot/Camera
@onready var floor_detector = $FloorDetector
@onready var enemy_detector = $Ship/EnemyDetector
@onready var floor_marker = $FloorMarker
@onready var hover_decal = $FloorMarker/HoverDecal
@onready var sphere = $Sphere
@onready var ship = $Ship
@onready var shoot_point = $Ship/ShootPoint

@onready var hud = $"../../HUD"
@onready var player_data = $"../../HUD/PlayerData"

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

var speedboost : float = 1

var homing_target = null
var target_hit : bool = false

var hp : int = 100
var type : ObjectTypes.TYPE = ObjectTypes.TYPE.FRIENDLY

# Called when the node enters the scene tree for the first time.
func _ready():
	#Capture mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	#Detect death
	if hp <= 0:
		pass #die here
	
	hud.hp_bar.value = lerp(hud.hp_bar.value, float(hp), 0.1)
	hud.hp_label.text = str(int(lerp(hud.hp_bar.value, float(hp), 0.1)))
	
	var input = Vector3.ZERO
	input.x = Input.get_axis("move_left","move_right")
	input.z = Input.get_axis("move_forward","move_backward")
	#Move on axes via keyboard input, relative to camera twist
	apply_central_force(twist_pivot.basis * input * thrust_power * delta * speedboost)

	#Set maximum speed
	if linear_velocity.x > MAXVELOCITY:
		linear_velocity.x = MAXVELOCITY
	elif linear_velocity.x < -MAXVELOCITY:
		linear_velocity.x = -MAXVELOCITY
	if linear_velocity.y > MAXVELOCITY * 3:
		linear_velocity.y = MAXVELOCITY * 3
	elif linear_velocity.y < -MAXVELOCITY:
		linear_velocity.y = -MAXVELOCITY
	if linear_velocity.z > MAXVELOCITY:
		linear_velocity.z = MAXVELOCITY
	elif linear_velocity.z < -MAXVELOCITY:
		linear_velocity.z = -MAXVELOCITY

	#Stick to ground if on ground
	if Input.is_action_pressed("floorslide") and floor_detector.is_colliding():
		apply_central_force(Vector3(0,-1,0) * floor_power * delta)
		
	#Jump if on ground
	if Input.is_action_just_pressed("jump") and floor_detector.is_colliding():
		var jumpInertia = max(abs(linear_velocity.x), abs(linear_velocity.y), abs(linear_velocity.z)) * INERTIAJUMPMULTIPLIER
		print(jumpInertia)
		print((jump_power * jumpInertia))
		apply_central_impulse(Vector3(0,1,0) * (jump_power * jumpInertia) * delta)

	if Input.is_action_just_pressed("shoot"):
		shoot(BULLET)
	if Input.is_action_just_pressed("debug_shoot"):
		shoot(DEBUG_ENEMY_BULLET)

	#Lock on if looking at enemy and homing attack on right click
	if enemy_detector.is_colliding():
		var object = enemy_detector.get_collider(0)
		if "type" in object:
			if object.type == ObjectTypes.TYPE.ENEMY and object.alive:
				object.lock_marker.visible = true
				if Input.is_action_just_pressed("homing"):
					homing_attack()
		
	#if floor_marker.is_colliding():
	hover_decal.position.y = floor_marker.get_collision_point().y
		
	#Toggle mouse focus
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Input.is_action_just_pressed("ui_accept"):
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
	
	player_data.text = (
		"HamstersVSAliens Pre-Alpha Ver 0.01" + "\n" +
		"Linear Velocity: " + str(linear_velocity) + "\n" +
		"Angluar Velocity: " + str(angular_velocity) + "\n" +
		"Input: " + str(twist_pivot.basis * input * thrust_power * delta) + "\n" +
		"OnFloor?: " + str(floor_detector.is_colliding())
		)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			twist_input = -event.relative.x * mouse_sensitivity
			pitch_input = -event.relative.y * mouse_sensitivity

func homing_attack(homingRepeat : int = 175, homing_refresh : float = 0.01):
	homing_target = enemy_detector.get_collider(0)
	for i in range(0,homingRepeat):
		if target_hit:
			break
		if homing_target:
			var enemy_position = homing_target.global_position
			linear_velocity = Vector3(0,0,0)
			var distance = abs(position.x - enemy_position.x) + abs(position.y - enemy_position.y) + abs(position.z - enemy_position.z)
			print(distance)
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
			print("Target hit")
