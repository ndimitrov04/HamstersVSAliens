extends Node3D

@onready var player = get_tree().root.get_child(get_tree().root.get_child_count()-1).player

const MAXVELOCITY = 25
const INERTIAJUMPMULTIPLIER = 0.2

var thrust_power : float = 60000
var jump_power : float = 60000
var floor_power : float = 120000

var input = Vector3.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if get_parent().global_position.x > player.global_position.x:
		input.x = -1
	elif get_parent().global_position.x < player.global_position.x:
		input.x = 1
	else:
		input.x = 0
	if get_parent().global_position.z > player.global_position.z:
		input.z = -1
	elif get_parent().global_position.z < player.global_position.z:
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
	if get_parent().linear_velocity.y > MAXVELOCITY * 3:
		get_parent().linear_velocity.y = MAXVELOCITY * 3
	elif get_parent().linear_velocity.y < -MAXVELOCITY:
		get_parent().linear_velocity.y = -MAXVELOCITY
	if get_parent().linear_velocity.z > MAXVELOCITY:
		get_parent().linear_velocity.z = MAXVELOCITY
	elif get_parent().linear_velocity.z < -MAXVELOCITY:
		get_parent().linear_velocity.z = -MAXVELOCITY
