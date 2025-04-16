extends Area3D

@onready var hitbox = $Hitbox

@onready var trauma_amount = 2

func _on_area_entered(area):
	if area.has_method("add_trauma"):
		area.add_trauma(trauma_amount)
		queue_free()
