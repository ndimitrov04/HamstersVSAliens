extends Node3D

@onready var building = null
@onready var build_text = $BuildText

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	pass

func _on_buy_area_body_entered(body):
	if body.name == "Player":
		body.build_spot = self
		build_text.text = "Use the menu to build here"
		body.hud.buy_menu.show()

func _on_buy_area_body_exited(body):
	if body.name == "Player":
		body.build_spot = null
		build_text.text = "Empty"
		body.hud.buy_menu.hide()
