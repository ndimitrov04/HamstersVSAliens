extends Node3D

@onready var pause_time = get_parent().get_meta("pause_time")
@onready var pause_interval = get_parent().get_meta("pause_interval")
@onready var pause_timer = $PauseTimer
@onready var y_retarget = $YRetarget

const MAXVELOCITY = 25
const INERTIAJUMPMULTIPLIER = 0.2
const SKYBOUNDS = [20,50]

var thrust_power : float = 60000
var jump_power : float = 60000
var floor_power : float = 120000

var input : Vector3 = Vector3.ZERO
var paused : bool = false
var y_level : float

func _ready():
	randf_range(pause_interval-0.5,pause_interval+0.5)
	y_level = global_position.y

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if get_parent().global_position.x > get_parent().target.global_position.x:
		input.x = -1
	elif get_parent().global_position.x < get_parent().target.global_position.x:
		input.x = 1
	else:
		input.x = 0
	if get_parent().global_position.y > y_level:
		input.y = -1
	elif get_parent().global_position.y < y_level:
		input.y = 1
	else:
		input.y = 0
	if get_parent().global_position.z > get_parent().target.global_position.z:
		input.z = -1
	elif get_parent().global_position.z < get_parent().target.global_position.z:
		input.z = 1
	else:
		input.z = 0

	if get_parent().alive and not paused:
		get_parent().apply_central_force(input * thrust_power * Vector3(1,0.1,1) * delta)

	#Set maximum speed
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

func pause_movement(internal_pause_time : float):
	paused = true
	await get_tree().create_timer(internal_pause_time).timeout
	paused = false

func retarget_y():
	y_level = randf_range(SKYBOUNDS[0],SKYBOUNDS[1])

func _on_pause_timer_timeout():
	pause_movement(pause_time)

func _on_y_retarget_timeout():
	retarget_y()
