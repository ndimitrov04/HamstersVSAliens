extends Node3D

@onready var pause_time = get_parent().get_meta("pause_time")
@onready var pause_interval = get_parent().get_meta("pause_interval")
@onready var pause_timer = $PauseTimer

const MAXVELOCITY = 25
const INERTIAJUMPMULTIPLIER = 0.2

var thrust_power : float = 60000
var jump_power : float = 60000
var floor_power : float = 120000

var input : Vector3 = Vector3.ZERO
var paused : bool = false

func _ready():
	randf_range(pause_interval-0.5,pause_interval+0.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if get_parent().global_position.x > get_parent().target.global_position.x:
		input.x = -1
	elif get_parent().global_position.x < get_parent().target.global_position.x:
		input.x = 1
	else:
		input.x = 0
	if get_parent().global_position.z > get_parent().target.global_position.z:
		input.z = -1
	elif get_parent().global_position.z < get_parent().target.global_position.z:
		input.z = 1
	else:
		input.z = 0

	if get_parent().alive and not paused:
		get_parent().apply_central_force(input * thrust_power * delta)

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

func _on_pause_timer_timeout():
	pause_movement(pause_time)
