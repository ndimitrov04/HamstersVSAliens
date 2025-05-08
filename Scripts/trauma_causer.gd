extends Area3D

@onready var hitbox = $Hitbox

@onready var trauma_amount = 2
@onready var strength = 2000

func _on_area_entered(area):
	if area.has_method("add_trauma"):
		area.add_trauma(trauma_amount)
		queue_free()

func _on_body_entered(body):
	if "type" in body:
		if body.type == ObjectTypes.TYPE.ENEMY:
			body.apply_central_impulse(global_position.direction_to(body.global_position) * 
										clampf(8/global_position.distance_to(body.global_position),0.1,0.6) *
										trauma_amount * strength
										)
		if body.type == ObjectTypes.TYPE.FRIENDLY:
			if body.name == "Player":
				body.apply_central_impulse(global_position.direction_to(body.global_position) * 
										clampf(8/global_position.distance_to(body.global_position),0.1,0.6) *
										trauma_amount * strength
										)
				print(clampf(10/global_position.distance_to(body.global_position),0.1,0.6))
				print(global_position.distance_to(body.global_position))


func _on_timer_timeout():
	queue_free()
