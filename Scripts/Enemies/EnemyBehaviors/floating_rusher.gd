extends Node3D

const MAXVELOCITY = 30
const INERTIAJUMPMULTIPLIER = 0.2

var thrust_power : float = 190000
var jump_power : float = 190000
var floor_power : float = 120000

var input : Vector3 = Vector3.ZERO

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if get_parent().target == null:
		return
		
	if get_parent().global_position.x > get_parent().target.global_position.x:
		input.x = -1
	elif get_parent().global_position.x < get_parent().target.global_position.x:
		input.x = 1
	else:
		input.x = 0
	if get_parent().global_position.y > get_parent().target.global_position.y:
		input.y = -1
	elif get_parent().global_position.y < get_parent().target.global_position.y:
		input.y = 1
	else:
		input.y = 0
	if get_parent().global_position.z > get_parent().target.global_position.z:
		input.z = -1
	elif get_parent().global_position.z < get_parent().target.global_position.z:
		input.z = 1
	else:
		input.z = 0

	if get_parent().alive:
		get_parent().apply_central_force(input * thrust_power * delta)

	#Set maximum speed
	if get_parent().linear_velocity.x > MAXVELOCITY:
		get_parent().linear_velocity.x = MAXVELOCITY
	elif get_parent().linear_velocity.x < -MAXVELOCITY:
		get_parent().linear_velocity.x = -MAXVELOCITY
	if get_parent().linear_velocity.y > MAXVELOCITY:
		get_parent().linear_velocity.y = MAXVELOCITY
	elif get_parent().linear_velocity.y < -MAXVELOCITY:
		get_parent().linear_velocity.y = -MAXVELOCITY
	if get_parent().linear_velocity.z > MAXVELOCITY:
		get_parent().linear_velocity.z = MAXVELOCITY
	elif get_parent().linear_velocity.z < -MAXVELOCITY:
		get_parent().linear_velocity.z = -MAXVELOCITY
