extends Node3D

# Holder of this node must have the following metadata:
# custom_targeting : bool = true
# targets : NodePath = ../../Friendlies (or Enemies)

@onready var pause_interval = get_parent().get_meta("pause_interval")
@onready var y_retarget = $YRetarget

const MAXVELOCITY = 30
const INERTIAJUMPMULTIPLIER = 0.2
var SKYBOUNDS = [1,1]

var thrust_power : float = 90000
var jump_power : float = 60000
var floor_power : float = 120000

var input : Vector3 = Vector3.ZERO
var paused : bool = false
var y_level : float

var strafe_start_coords : Vector3 = Vector3.ZERO
var strafe_target_coords : Vector3 = Vector3.ZERO
var started_strafe : bool = false

func _ready():
	await Engine.get_main_loop().process_frame
	SKYBOUNDS[0] = get_parent().get_parent().get_parent().SKYBOUNDS[0] + 60
	SKYBOUNDS[1] = get_parent().get_parent().get_parent().SKYBOUNDS[1] + 80
	randf_range(pause_interval-0.5,pause_interval+0.5)
	y_level = SKYBOUNDS[1]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	# Keep enemy from going too high into the air
	if get_parent().global_position.y >= get_parent().get_parent().get_parent().SKYBOUNDS[1] + 50:
		get_parent().global_position.y = get_parent().get_parent().get_parent().SKYBOUNDS[1] + 50
	
	if not started_strafe:
		retarget()
	
	# Maintain correct Y level
	if get_parent().global_position.y > y_level:
		input.y = -1
	elif get_parent().global_position.y < y_level:
		input.y = 1
	else:
		input.y = 0

	# Strafe
	if get_parent().alive:
		get_parent().apply_central_force(input * thrust_power * Vector3(1,1,1) * delta)
		get_parent().look_at(strafe_target_coords, Vector3.UP, true)

	# End strafe conditions
	if started_strafe:
		if input.x == -1:
			if get_parent().global_position.x < strafe_target_coords.x - 100:
				started_strafe = false
				retarget()
				print("Finished strafe")
		elif input.x == 1: 
			if get_parent().global_position.x > strafe_target_coords.x + 100:
				started_strafe = false
				retarget()
				print("Finished strafe")
		if input.z == -1:
			if get_parent().global_position.z < strafe_target_coords.z - 100:
				started_strafe = false
				retarget()
				print("Finished strafe")
		elif input.z == 1:
			if get_parent().global_position.z > strafe_target_coords.z + 100:
				started_strafe = false
				retarget()
				print("Finished strafe")

	# Set maximum speed
	if get_parent().linear_velocity.x > MAXVELOCITY:
		get_parent().linear_velocity.x = MAXVELOCITY
	elif get_parent().linear_velocity.x < -MAXVELOCITY:
		get_parent().linear_velocity.x = -MAXVELOCITY
	if get_parent().linear_velocity.y > MAXVELOCITY * 3:
		get_parent().linear_velocity.y = MAXVELOCITY * 3
	elif get_parent().linear_velocity.y < -MAXVELOCITY:
		get_parent().linear_velocity.y = -MAXVELOCITY
	if get_parent().linear_velocity.z > MAXVELOCITY:
		get_parent().linear_velocity.z = MAXVELOCITY
	elif get_parent().linear_velocity.z < -MAXVELOCITY:
		get_parent().linear_velocity.z = -MAXVELOCITY

func retarget():
	started_strafe = true
	
	# Choose random target
	get_parent().target = get_parent().targets.get_child(randi_range(0, get_parent().targets.get_child_count() - 1))
	
	strafe_target_coords = get_parent().target.global_position
	print("Strafe target coordinates: " + str(strafe_target_coords))
	strafe_target_coords.y = get_parent().global_position.y
	
	# Choose strafe direction
	strafe_start_coords = get_parent().global_position
	if get_parent().global_position.x > strafe_target_coords.x:
		input.x = -1
	elif get_parent().global_position.x < strafe_target_coords.x:
		input.x = 1
	else:
		input.x = 0
	if get_parent().global_position.z > strafe_target_coords.z:
		input.z = -1
	elif get_parent().global_position.z < strafe_target_coords.z:
		input.z = 1
	else:
		input.z = 0
	print("Strafe Direction:" + str(input.x) + str(input.z))
	

func retarget_y():
	y_level = randf_range(SKYBOUNDS[0],SKYBOUNDS[1])

func _on_y_retarget_timeout():
	retarget_y()
