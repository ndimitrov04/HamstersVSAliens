extends Area3D

@onready var HEALTH_PARTICLE = preload("res://Scenes/Particles/health_particle.tscn")

@onready var regen_timer = $RegenTimer

var regen_amount
var friendlies = []

# Called when the node enters the scene tree for the first time.
func _ready():
	await get_tree().create_timer(0.1).timeout
	regen_timer.wait_time = get_meta("regen_wait_time")
	regen_amount = get_meta("regen_amount")

func _on_body_entered(body):
	if body.get_parent().name == "Friendlies":
		friendlies.append(body)

func _on_body_exited(body):
	if body.get_parent().name == "Friendlies":
		friendlies.erase(body)

func _on_regen_timer_timeout():
	for friendly_unit in friendlies:
		friendly_unit.hp += regen_amount
		var health_particle = HEALTH_PARTICLE.instantiate()
		friendly_unit.add_child(health_particle)
		health_particle.global_position = friendly_unit.global_position
		health_particle.emitting = true
