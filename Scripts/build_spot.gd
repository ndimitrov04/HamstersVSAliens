extends Node3D

@onready var building = null
@onready var build_text = $BuildText

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if building == null:
		build_text.show()
	else:
		build_text.hide()

func _on_buy_area_body_entered(body):
	if body.name == "Player":
		# If build spot is empty, show tower purchase menu
		# Else show tower upgrade menu
		if building == null:
			body.build_spot = self
			build_text.text = "Use the menu to build here"
			body.hud.buy_menu.show()
		else:
			if not building.upgraded:
				body.hud.upgrade_menu.upgrade_description_1.text = building.upgrade_description_1
				body.hud.upgrade_menu.upgrade_description_2.text = building.upgrade_description_2
				body.hud.upgrade_menu.upgrade_button_1.text = "Upgrade: " + str(building.upgrade_cost_1) + "G" 
				body.hud.upgrade_menu.upgrade_button_2.text = "Upgrade: " + str(building.upgrade_cost_2) + "G" 
				body.hud.upgrade_menu.upgradable_tower = building
				body.hud.upgrade_menu.show()

func _on_buy_area_body_exited(body):
	if body.name == "Player":
		body.build_spot = null
		build_text.text = "Empty"
		body.hud.buy_menu.hide()
		body.hud.upgrade_menu.hide()
