extends Area3D

func _on_body_entered(body):
	if body:
		if body.name != "WorldBorder" and body.name != "BTerrain":
			print_debug(body.name + "destroyed (killzone).")
			body.queue_free()
